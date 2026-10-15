// Tạo bản Word (.docx) từ các file .md của project.
// Chạy: node tools/build_docx/build.js  (từ thư mục gốc project)
// File .md là bản gốc; file .docx chỉ để đọc, không sửa tay.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execFileSync } = require('child_process');
const { marked } = require('marked');
const {
  Document, Packer, Paragraph, TextRun, ImageRun, Table, TableRow, TableCell,
  Header, Footer, PageNumber, AlignmentType, HeadingLevel, LevelFormat,
  WidthType, BorderStyle, ShadingType, ExternalHyperlink, InternalHyperlink, Bookmark,
  VerticalAlign, TableLayoutType,
} = require('docx');

const ROOT = path.resolve(__dirname, '..', '..');
const OUT_DIR = path.join(ROOT, 'docs', 'word');
const CACHE_DIR = path.join(__dirname, '.cache');

// Các file cần tạo bản Word. toc = có mục lục.
const SOURCES = [
  { md: 'roadmap.md', toc: true },
  { md: 'tu_dien_roadmap.md', toc: true },
  { md: 'docs/hieu_de_bai.md', toc: false },
  { md: 'docs/quy_uoc_va_so_chuan.md', toc: true },
  { md: 'docs/yeu_cau_dashboard.md', toc: false },
  { md: 'docs/ghi_chu_ky_thuat.md', toc: true },
];

// ---------- Trình bày ----------
// Font Times New Roman cho mọi chữ (đơn vị cỡ chữ của Word là nửa điểm: 24 = 12pt).
// Đường viền chỉ dùng ở khối tên tài liệu và ở bảng.
const FONT = 'Times New Roman';
const MONO = 'Times New Roman';
// Mỗi cấp tiêu đề một cỡ chữ riêng: tên tài liệu 20, cấp 1 16, cấp 2 14, cấp 3 13, chữ thường 12.
const SZ = { body: 24, small: 24, h3: 26, h2: 28, h1: 32, title: 40 };
const C = {
  navy: '1F3864', blue: '2E74B5', text: '262626', gray: '7F7F7F',
  headerFill: '1F3864', zebra: 'F2F6FB', border: 'BFC9D9',
  noteFill: 'EAF2FB', codeFill: 'EEEEEE',
};
const PAGE_W = 11906;            // A4, DXA
const MARGIN = 1134;             // 2 cm
const CONTENT_W = PAGE_W - 2 * MARGIN; // 9638 DXA
const PX_PER_DXA = 96 / 1440;
const MAX_IMG_W = Math.floor(CONTENT_W * PX_PER_DXA) - 4; // ~640 px
const MAX_IMG_H = 680; // đủ thấp để sơ đồ nằm cùng trang với tiêu đề mục

// ---------- Mermaid → PNG ----------
const MERMAID_CONFIG = { themeVariables: { fontFamily: 'Times New Roman', fontSize: '18px' } };
function renderMermaid(code) {
  let img = renderMermaidRaw(code);
  if (img.w / img.h > 2.2 && /^\s*flowchart\s+LR/m.test(code)) {
    // Sơ đồ ngang quá rộng: trong Word chữ sẽ quá nhỏ, nên vẽ lại theo chiều dọc (nội dung giữ nguyên).
    img = renderMermaidRaw(code.replace(/^(\s*flowchart\s+)LR/m, '$1TB'));
  }
  return img;
}

function renderMermaidRaw(code) {
  fs.mkdirSync(CACHE_DIR, { recursive: true });
  const hash = crypto.createHash('sha1').update(code + JSON.stringify(MERMAID_CONFIG)).digest('hex').slice(0, 12);
  const mmd = path.join(CACHE_DIR, `${hash}.mmd`);
  const png = path.join(CACHE_DIR, `${hash}.png`);
  if (!fs.existsSync(png)) {
    fs.writeFileSync(mmd, code, 'utf8');
    const cfg = path.join(CACHE_DIR, 'mermaid-config.json');
    fs.writeFileSync(cfg, JSON.stringify(MERMAID_CONFIG), 'utf8');
    execFileSync('npx', ['-y', '@mermaid-js/mermaid-cli@11.4.2', '-i', mmd, '-o', png,
      '-b', 'white', '-s', '2', '-c', cfg], { stdio: 'ignore', shell: true });
  }
  const buf = fs.readFileSync(png);
  const w = buf.readUInt32BE(16), h = buf.readUInt32BE(20);
  return { buf, w, h };
}

// ---------- Chữ trong dòng (inline) ----------
function decode(s) {
  return s.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"').replace(/&#39;/g, "'");
}

// Biến token inline của marked thành danh sách TextRun/ExternalHyperlink.
function inlineRuns(tokens, style = {}) {
  const out = [];
  for (const t of tokens || []) {
    switch (t.type) {
      case 'text':
        if (t.tokens && t.tokens.length) out.push(...inlineRuns(t.tokens, style));
        else out.push(run(decode(t.text), style));
        break;
      case 'escape':
        out.push(run(decode(t.text), style));
        break;
      case 'strong':
        out.push(...inlineRuns(t.tokens, { ...style, bold: true }));
        break;
      case 'em':
        out.push(...inlineRuns(t.tokens, { ...style, italics: true }));
        break;
      case 'del':
        out.push(...inlineRuns(t.tokens, { ...style, strike: true }));
        break;
      case 'codespan':
        out.push(new TextRun({
          text: decode(t.text), font: MONO, size: SZ.body, color: style.color || '9C2B2B',
          bold: style.bold, shading: { type: ShadingType.CLEAR, fill: C.codeFill, color: 'auto' },
        }));
        break;
      case 'link': {
        const href = mdLinkToDocx(t.href);
        out.push(new ExternalHyperlink({
          link: href,
          children: inlineRuns(t.tokens, { ...style, color: C.blue, underline: {} }),
        }));
        break;
      }
      case 'br':
        out.push(new TextRun({ text: '', break: 1 }));
        break;
      case 'html':
        // Thẻ HTML lẻ trong dòng (không phải danh sách) thì bỏ qua thẻ, giữ chữ.
        break;
      default:
        if (t.text) out.push(run(decode(t.text), style));
    }
  }
  return out;
}

function run(text, style) {
  return new TextRun({
    text, font: FONT, bold: style.bold, italics: style.italics, strike: style.strike,
    color: style.color, underline: style.underline, size: style.size,
  });
}

// Link tới file .md khác → link tới file .docx cùng tên (mọi .docx nằm chung thư mục word/).
function mdLinkToDocx(href) {
  if (/^https?:/i.test(href)) return href;
  const base = path.basename(href.split('#')[0]);
  return base.endsWith('.md') ? base.replace(/\.md$/, '.docx') : href;
}

// ---------- Đoạn văn, danh sách ----------
function para(children, opts = {}) {
  return new Paragraph({ children, spacing: { after: 100, line: 276 }, ...opts });
}

// Danh sách: dùng numbering thật của Word.
let orderedInstance = 0;
function listItemParas(items, ordered, level, ctx) {
  const paras = [];
  const inst = ordered ? ++orderedInstance : 0;
  for (const it of items) {
    let first = true;
    for (const tok of it.tokens) {
      if (tok.type === 'list') {
        paras.push(...listItemParas(tok.items, tok.ordered, level + 1, ctx));
      } else if (tok.type === 'text' || tok.type === 'paragraph') {
        const runs = inlineRuns(tok.tokens || [{ type: 'text', text: tok.text }], ctx.style);
        if (first) {
          paras.push(new Paragraph({
            children: runs,
            numbering: ordered
              ? { reference: 'numbers', level, instance: inst }
              : { reference: 'bullets', level },
            spacing: { after: 60, line: 276 },
            ...(ctx.paraOpts || {}),
          }));
          first = false;
        } else {
          // Đoạn thứ hai trong cùng một mục: thụt lề, không có dấu đầu dòng.
          paras.push(new Paragraph({
            children: runs, indent: { left: 360 + 360 * level }, // thẳng hàng với chữ của mục
            spacing: { after: 60, line: 276 }, ...(ctx.paraOpts || {}),
          }));
        }
      } else if (tok.type === 'space') {
        // bỏ qua
      } else {
        paras.push(...blockToChildren(tok, ctx));
      }
    }
  }
  return paras;
}

// ---------- Ô bảng có thẻ <ul>/<ol>/<li> ----------
// Đi qua token inline của ô, dựng các đoạn: đoạn thường hoặc mục danh sách (có cấp, có/không đánh số).
function cellParagraphs(tokens, cellStyle, align) {
  // Tách token html thành từng thẻ riêng.
  const flat = [];
  for (const t of tokens) {
    if (t.type === 'html') {
      const parts = t.raw.split(/(<\/?(?:ul|ol|li)\s*>)/i).filter((x) => x !== '');
      for (const p of parts) {
        if (/^<\/?(ul|ol|li)\s*>$/i.test(p)) flat.push({ tag: p.toLowerCase().replace(/\s/g, '') });
        else flat.push({ type: 'text', text: p });
      }
    } else flat.push(t);
  }
  const paras = [];
  const stack = []; // {ordered, inst}
  let current = null; // {runsTokens, level, ordered, inst}
  let loose = [];     // token ngoài <li>

  const flushLoose = () => {
    const runs = inlineRuns(loose, cellStyle);
    if (runs.length && loose.some((x) => (x.text || x.raw || '').trim() || x.type === 'codespan')) {
      paras.push(new Paragraph({ children: runs, alignment: align, spacing: { after: 40 } }));
    }
    loose = [];
  };
  const flushItem = () => {
    if (!current) return;
    const runs = inlineRuns(current.toks, cellStyle);
    paras.push(new Paragraph({
      children: runs,
      numbering: current.ordered
        ? { reference: 'numbers', level: current.level, instance: current.inst }
        : { reference: 'cellbullets', level: current.level },
      spacing: { after: 30 },
    }));
    current = null;
  };

  for (const t of flat) {
    if (t.tag) {
      if (t.tag === '<ul>' || t.tag === '<ol>') {
        flushLoose();
        flushItem();
        stack.push({ ordered: t.tag === '<ol>', inst: t.tag === '<ol>' ? ++orderedInstance : 0 });
      } else if (t.tag === '</ul>' || t.tag === '</ol>') {
        flushItem();
        stack.pop();
      } else if (t.tag === '<li>') {
        flushItem();
        const top = stack[stack.length - 1] || { ordered: false, inst: 0 };
        current = { toks: [], level: Math.max(0, stack.length - 1), ordered: top.ordered, inst: top.inst };
      } else if (t.tag === '</li>') {
        flushItem();
      }
    } else if (current) current.toks.push(t);
    else loose.push(t);
  }
  flushItem();
  flushLoose();
  if (!paras.length) paras.push(new Paragraph({ children: [] }));
  return paras;
}

function plainLen(tokens) {
  let n = 0;
  for (const t of tokens || []) {
    if (t.type === 'html') n += t.raw.replace(/<[^>]+>/g, '').length;
    else if (t.tokens) n += plainLen(t.tokens);
    else n += (t.text || '').length;
  }
  return n;
}

// Chia độ rộng cột theo độ dài chữ trung bình, có giới hạn trên/dưới.
function columnWidths(token) {
  const ncol = token.header.length;
  const lens = Array.from({ length: ncol }, (_, i) => {
    const vals = [token.header[i], ...token.rows.map((r) => r[i])].map((c) => plainLen(c.tokens));
    const avg = vals.reduce((a, b) => a + b, 0) / vals.length;
    const max = Math.max(...vals);
    return Math.max(6, Math.min(0.6 * avg + 0.4 * Math.min(max, 120), 140));
  });
  const sum = lens.reduce((a, b) => a + b, 0);
  let widths = lens.map((l) => Math.max(1100, Math.round((CONTENT_W * l) / sum)));
  const diff = CONTENT_W - widths.reduce((a, b) => a + b, 0);
  const iMax = widths.indexOf(Math.max(...widths));
  widths[iMax] += diff;
  return widths;
}

function tableBlock(token) {
  const widths = columnWidths(token);
  const border = { style: BorderStyle.SINGLE, size: 4, color: C.border };
  const borders = { top: border, bottom: border, left: border, right: border };
  const alignOf = (i) => (token.align[i] === 'right' ? AlignmentType.RIGHT
    : token.align[i] === 'center' ? AlignmentType.CENTER : AlignmentType.LEFT);

  const headerRow = new TableRow({
    tableHeader: true,
    children: token.header.map((c, i) => new TableCell({
      width: { size: widths[i], type: WidthType.DXA },
      borders,
      shading: { type: ShadingType.CLEAR, fill: C.headerFill, color: 'auto' },
      margins: { top: 80, bottom: 80, left: 110, right: 110 },
      verticalAlign: VerticalAlign.CENTER,
      children: cellParagraphs(c.tokens, { bold: true, color: 'FFFFFF' }, alignOf(i)),
    })),
  });
  const rows = token.rows.map((r, ri) => new TableRow({
    cantSplit: false,
    children: r.map((c, i) => new TableCell({
      width: { size: widths[i], type: WidthType.DXA },
      borders,
      shading: ri % 2 === 1 ? { type: ShadingType.CLEAR, fill: C.zebra, color: 'auto' } : undefined,
      margins: { top: 70, bottom: 70, left: 110, right: 110 },
      children: cellParagraphs(c.tokens, {}, alignOf(i)),
    })),
  }));
  return [
    new Paragraph({ children: [], spacing: { after: 60 } }), // khoảng cách trước bảng
    new Table({
      width: { size: CONTENT_W, type: WidthType.DXA },
      columnWidths: widths,
      layout: TableLayoutType.FIXED,
      rows: [headerRow, ...rows],
    }),
    new Paragraph({ children: [], spacing: { after: 120 } }),
  ];
}

// ---------- Khối (block) ----------
let figureNo = 0;
let lastHeading = '';
let headingNo = 0; // để gắn bookmark cho mục lục
let sectionNo = 0; // số mục lớn (## trong .md); từ mục thứ 2 trở đi bắt đầu ở trang mới

function blockToChildren(tok, ctx) {
  switch (tok.type) {
    case 'heading': {
      const text = tok.text;
      if (tok.depth === 1) return []; // H1 của .md dùng làm tên tài liệu ở khối tiêu đề
      lastHeading = text.replace(/[*`]/g, '');
      const level = tok.depth === 2 ? HeadingLevel.HEADING_1
        : tok.depth === 3 ? HeadingLevel.HEADING_2 : HeadingLevel.HEADING_3;
      headingNo += 1;
      if (tok.depth === 2) sectionNo += 1;
      return [new Paragraph({ heading: level,
        pageBreakBefore: tok.depth === 2 && sectionNo > 1, // mục 1 ở cùng trang với mục lục
        children: [new Bookmark({ id: `muc_${headingNo}`, children: inlineRuns(tok.tokens, {}) })] })];
    }
    case 'paragraph':
      return [para(inlineRuns(tok.tokens, ctx.style || {}), ctx.paraOpts || {})];
    case 'list':
      return listItemParas(tok.items, tok.ordered, 0, ctx);
    case 'table':
      return tableBlock(tok);
    case 'blockquote': {
      const inner = { style: {}, paraOpts: {
        shading: { type: ShadingType.CLEAR, fill: C.noteFill, color: 'auto' },
        indent: { left: 200, right: 200 },
      } };
      return tok.tokens.flatMap((t) => blockToChildren(t, inner));
    }
    case 'hr':
      return [new Paragraph({ children: [], spacing: { before: 120, after: 120 } })];
    case 'code': {
      if (tok.lang === 'mermaid') {
        const img = renderMermaid(tok.text);
        let w = img.w / 2, h = img.h / 2; // ảnh vẽ ở tỉ lệ 2x
        const scale = Math.min(1, MAX_IMG_W / w, MAX_IMG_H / h);
        w = Math.round(w * scale); h = Math.round(h * scale);
        figureNo += 1;
        return [
          new Paragraph({
            alignment: AlignmentType.CENTER, spacing: { before: 120, after: 60 }, keepNext: true,
            children: [new ImageRun({ type: 'png', data: img.buf, transformation: { width: w, height: h } })],
          }),
          new Paragraph({
            alignment: AlignmentType.CENTER, spacing: { after: 200 },
            children: [new TextRun({ text: `Hình ${figureNo}. ${lastHeading.replace(/^\d+(\.\d+)*\.?\s+/, '')}`, italics: true, color: C.gray, size: SZ.small })],
          }),
        ];
      }
      return tok.text.split('\n').map((line) => new Paragraph({
        children: [new TextRun({ text: line, font: MONO, size: SZ.body })],
        shading: { type: ShadingType.CLEAR, fill: C.codeFill, color: 'auto' },
        spacing: { after: 0 },
      }));
    }
    case 'html':
      return [];
    case 'space':
      return [];
    default:
      return tok.text ? [para([run(tok.text, {})])] : [];
  }
}

// ---------- Dựng một tài liệu ----------
function buildDoc(src) {
  const mdPath = path.join(ROOT, src.md);
  const md = fs.readFileSync(mdPath, 'utf8');
  const tokens = marked.lexer(md);
  const h1 = tokens.find((t) => t.type === 'heading' && t.depth === 1);
  const title = h1 ? h1.text.replace(/[*`]/g, '') : path.basename(src.md, '.md');
  figureNo = 0; lastHeading = title; orderedInstance = 0; headingNo = 0; sectionNo = 0;

  const today = new Date();
  const dd = String(today.getDate()).padStart(2, '0');
  const mm = String(today.getMonth() + 1).padStart(2, '0');

  const titleBlock = [
    new Paragraph({
      children: [new TextRun({ text: title, bold: true, size: SZ.title, color: C.navy, font: FONT })],
      spacing: { after: 120 },
    }),
    new Paragraph({
      children: [new TextRun({
        text: `Bản Word để đọc · nội dung gốc ở file ${src.md} · tạo ngày ${dd}/${mm}/${today.getFullYear()}`,
        italics: true, color: C.gray, size: SZ.small, font: FONT,
      })],
      border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: C.blue, space: 6 } },
      spacing: { after: 240 },
    }),
  ];
  // Mục lục tự dựng: link bấm được tới từng mục (không cần Word cập nhật trường).
  const tocItems = [];
  let n = 0;
  for (const t of tokens) {
    if (t.type !== 'heading' || t.depth === 1) continue;
    n += 1;
    if (t.depth > 3) continue;
    tocItems.push(new Paragraph({
      indent: { left: t.depth === 2 ? 0 : 400 },
      spacing: { after: 40 },
      children: [new InternalHyperlink({ anchor: `muc_${n}`, children: [new TextRun({
        text: t.text.replace(/[*`]/g, ''), color: t.depth === 2 ? C.navy : C.blue,
        bold: t.depth === 2, size: SZ.body,
      })] })],
    }));
  }
  const toc = src.toc && tocItems.length ? [
    new Paragraph({ children: [new TextRun({ text: 'Mục lục', bold: true, size: SZ.h1, color: C.navy })], spacing: { after: 80 } }),
    ...tocItems,
    new Paragraph({ children: [], spacing: { after: 120 } }),
  ] : [];

  const body = [];
  for (const t of tokens) body.push(...blockToChildren(t, { style: {} }));

  const bulletLevels = (indentBase, step) => [0, 1, 2, 3].map((lvl) => ({
    level: lvl, format: LevelFormat.BULLET, text: ['●', '○', '▪', '–'][lvl],
    alignment: AlignmentType.LEFT,
    style: { paragraph: { indent: { left: indentBase + step * lvl, hanging: 240 } },
      run: { color: C.blue, font: FONT } },
  }));

  return new Document({
    creator: 'build_docx',
    title,
    description: `Tạo tự động từ ${src.md}`,
    styles: {
      default: { document: { run: { font: FONT, size: SZ.body, color: C.text } } },
      paragraphStyles: [
        { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: SZ.h1, bold: true, color: C.navy, font: FONT },
          paragraph: { spacing: { before: 360, after: 140 }, keepNext: true, keepLines: true, outlineLevel: 0 } },
        { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: SZ.h2, bold: true, color: C.blue, font: FONT },
          paragraph: { spacing: { before: 260, after: 100 }, keepNext: true, keepLines: true, outlineLevel: 1 } },
        { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: SZ.h3, bold: true, color: C.navy, font: FONT },
          paragraph: { spacing: { before: 200, after: 80 }, keepNext: true, keepLines: true, outlineLevel: 2 } },
      ],
    },
    numbering: {
      config: [
        { reference: 'bullets', levels: bulletLevels(360, 360) },
        { reference: 'cellbullets', levels: bulletLevels(260, 280) },
        { reference: 'numbers', levels: [0, 1, 2, 3].map((lvl) => ({
          level: lvl, format: LevelFormat.DECIMAL,
          text: `%${lvl + 1}.`, alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 460 + 400 * lvl, hanging: 460 } } }, // đủ chỗ cho số 2 chữ số
        })) },
      ],
    },
    sections: [{
      properties: { page: { size: { width: PAGE_W, height: 16838 },
        margin: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN } } },
      headers: { default: new Header({ children: [new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [new TextRun({ text: 'Project 1 · Đối soát doanh thu Nexa Home', size: SZ.small, color: C.gray })],
      })] }) },
      footers: { default: new Footer({ children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [
          new TextRun({ text: 'Trang ', size: SZ.small, color: C.gray }),
          new TextRun({ children: [PageNumber.CURRENT], size: SZ.small, color: C.gray }),
          new TextRun({ text: ' / ', size: SZ.small, color: C.gray }),
          new TextRun({ children: [PageNumber.TOTAL_PAGES], size: SZ.small, color: C.gray }),
        ],
      })] }) },
      children: [...titleBlock, ...toc, ...body],
    }],
  });
}

async function main() {
  fs.mkdirSync(OUT_DIR, { recursive: true });
  const only = process.argv.slice(2);
  for (const src of SOURCES) {
    if (only.length && !only.some((o) => src.md.includes(o))) continue;
    const doc = buildDoc(src);
    const out = path.join(OUT_DIR, path.basename(src.md, '.md') + '.docx');
    fs.writeFileSync(out, await Packer.toBuffer(doc));
    console.log('Đã tạo', path.relative(ROOT, out));
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
