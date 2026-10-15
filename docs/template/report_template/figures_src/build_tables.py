"""Dựng lại các hình dạng bảng của báo cáo từ nguồn 1.941 bản ghi.
Chạy: python3 build_tables.py   (cần playwright + chromium)
Kích thước và tỷ lệ được đặt bám theo ảnh chụp Excel gốc để bố cục LaTeX không đổi."""
import asyncio, os
from playwright.async_api import async_playwright

def css(fs, rowh):
    return f"""<style>
*{{box-sizing:border-box}}
body{{margin:0;padding:0;background:#fff;
     font-family:'Liberation Serif','Times New Roman',serif;}}
table{{border-collapse:collapse;background:#fff;font-size:{fs}px;color:#000;table-layout:fixed}}
td{{padding:0 9px;height:{rowh}px;line-height:{rowh}px;white-space:nowrap;overflow:hidden}}
.hdr td{{font-weight:bold;background:#DCE6F1;border-top:1px solid #95B3D7;border-bottom:1px solid #95B3D7}}
.tot td{{font-weight:bold;background:#DCE6F1;border-top:1px solid #95B3D7;border-bottom:1px solid #95B3D7}}
.r{{text-align:right}} .l{{text-align:left}} .c{{text-align:center}}
.filt{{color:#7F7F7F;font-size:{int(fs*0.72)}px}}
.wrap{{display:inline-block}}
.ds td{{border:1px solid #BFBFBF}}
.ds .cap{{font-style:italic;text-align:center;font-weight:normal}}
</style>"""

DOWN = '&#9660;'

def build(cols, header_rows, body, total=None, aligns=None):
    colgroup = ''.join(f'<col style="width:{w}px">' for w in cols)
    out = f'<div class="wrap"><table style="width:{sum(cols)}px">{colgroup}'
    for hr in header_rows:
        out += '<tr class="hdr">' + hr + '</tr>'
    for r in body:
        out += '<tr>' + ''.join(f'<td class="{aligns[i]}">{c}</td>' for i, c in enumerate(r)) + '</tr>'
    if total:
        out += '<tr class="tot">' + ''.join(f'<td class="{aligns[i]}">{c}</td>' for i, c in enumerate(total)) + '</tr>'
    return out + '</table></div>'

FIGS = {}

# ---------- Hình 3 : cơ cấu lỗi (3 cột giá trị) ----------
rows = [("Other_Faults","673","34,67%","34,67%"),("Bumps","402","20,71%","55,38%"),
        ("K_Scatch","391","20,14%","75,53%"),("Z_Scratch","190","9,79%","85,32%"),
        ("Pastry","158","8,14%","93,46%"),("Stains","72","3,71%","97,17%"),
        ("Dirtiness","55","2,83%","100,00%")]
hdr = (f'<td class="l">Row Labels <span class="filt">{DOWN}</span></td>'
       '<td class="r">Số vết lỗi</td><td class="r">Tỷ lệ</td><td class="r">Lũy kế</td>')
FIGS['fig01_bang_loi'] = (css(15, 23), build([168,122,100,112], [hdr], rows,
       ("Grand Total","1941","100,00%","100,00%"), ['l','r','r','r']))

# ---------- Hình 6 : thống kê mô tả độ dày ----------
ds = [("Mean","78,73776404"),("Standard Error","1,250341713"),("Median","70"),("Mode","40"),
      ("Standard Deviation","55,08603169"),("Sample Variance","3034,470888"),
      ("Kurtosis","4,937838455"),("Skewness","2,206935089"),("Range","260"),
      ("Minimum","40"),("Maximum","300"),("Sum","152830"),("Count","1941")]
body = ''.join(f'<tr><td class="l">{k}</td><td class="r">{v}</td></tr>' for k, v in ds)
FIGS['fig04_thong_ke_do_day'] = (css(13, 25),
    '<div class="wrap ds"><table style="width:406px;table-layout:fixed">'
    '<col style="width:203px"><col style="width:203px">'
    '<tr><td class="cap" colspan="2">Steel_Plate_Thickness</td></tr>'
    '<tr><td class="l">&nbsp;</td><td class="r">&nbsp;</td></tr>'
    f'{body}</table></div>')

# ---------- Hình 8 : độ dày theo loại lỗi ----------
rows = [("K_Scatch","391","40,18","2,20"),("Stains","72","50,69","5,89"),
        ("Z_Scratch","190","74,58","24,70"),("Bumps","402","76,93","38,05"),
        ("Dirtiness","55","84,45","28,66"),("Pastry","158","92,91","51,59"),
        ("Other_Faults","673","102,60","73,85")]
hdr = (f'<td class="l">Row Labels <span class="filt">{DOWN}</span></td>'
       '<td class="r">Số lượng lỗi</td><td class="r">Độ dày trung bình</td>'
       '<td class="r">Độ lệch chuẩn độ dày</td>')
FIGS['fig06_bang_do_day'] = (css(15, 24), build([150,125,175,195], [hdr], rows,
       ("Grand Total","1941","78,74","55,09"), ['l','r','r','r']))

# ---------- Hình 10 : độ dày theo loại lỗi × dòng thép ----------
rows = [("K_Scatch","80,00","40,08"),("Stains","100,00","50,00"),("Bumps","80,88","67,97"),
        ("Dirtiness","77,22","85,87"),("Pastry","89,47","94,45"),
        ("Other_Faults","104,64","101,27"),("Z_Scratch","70,35","115,00")]
h1 = ('<td class="l">Average of Steel_Plate_Thickness</td>'
      f'<td class="l" colspan="2">Column Labels <span class="filt">{DOWN}</span></td>')
h2 = (f'<td class="l">Row Labels <span class="filt">{DOWN}</span></td>'
      '<td class="r">A300</td><td class="r">A400</td>')
FIGS['fig08_bang_do_day_theo_loai_thep'] = (css(14, 22), build([243,110,110], [h1, h2], rows,
       ("Grand Total","87,21","73,08"), ['l','r','r']))

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(device_scale_factor=4)
        for name, (style, html) in FIGS.items():
            await pg.set_content(f'<html><head><meta charset="utf-8">{style}</head><body>{html}</body></html>')
            el = await pg.query_selector('.wrap')
            await el.screenshot(path=f'/home/claude/figs/{name}.png')
        await b.close()
asyncio.run(main())
