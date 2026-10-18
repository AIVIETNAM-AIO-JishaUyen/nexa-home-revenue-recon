"""make_figures.py – Sinh hình (PNG) và bảng LaTeX cho báo cáo từ file Excel Power Query đã làm mới.
Số trong báo cáo lấy từ đây, không gõ tay. Chạy lại mỗi khi làm mới file Excel.

Chạy:  D:/Anaconda/python.exe -I report/figures_src/make_figures.py
Ra:    report/generated/*.png, report/generated/*.tex
"""
import re
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[2]
XLSX = ROOT / "excel" / "Nexa_Home_Recon_PQ.xlsx"
OUT = ROOT / "report" / "generated"
OUT.mkdir(parents=True, exist_ok=True)

# Màu: xám cho phần nền, một màu nhấn cho điều cần chú ý (slide 14)
GREY = "#a9a8a3"
ACCENT = "#2a78d6"
INK = "#0b0b0b"
INK2 = "#52514e"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10, "axes.edgecolor": INK2,
                     "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2})


def sheet(name):
    """Đọc bảng nạp từ Power Query: tiêu đề ở ô A1, bảng bắt đầu ở dòng 3."""
    return pd.read_excel(XLSX, name, header=2)


def vn(x, d=0):
    """Số kiểu Việt Nam: dấu chấm ngăn nghìn, dấu phẩy thập phân; dấu trừ thật (−)."""
    x = round(float(x), d) + 0.0                                       # tránh in "−0,00"
    s = f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return s.replace("-", "−")


def pct(x, d=2):
    return vn(x * 100, d) + r"\%"


def esc(s):
    s = re.sub(r"(^|[\s(=])-(?=\d)", lambda m: m.group(1) + "−", str(s))
    for a, b in [("\\", r"\textbackslash{}"), ("&", r"\&"), ("%", r"\%"), ("_", r"\_"), ("#", r"\#"), ("→", r"$\rightarrow$")]:
        s = s.replace(a, b)
    return s


def write(name, text):
    # Dấu trừ "−" (Unicode) chưa có trong bộ mã T1 của LaTeX: đổi sang dấu trừ dạng toán
    (OUT / name).write_text(text.replace("−", "$-$"), encoding="utf-8")
    print("ghi", name)


# ---------------------------------------------------------------- Bảng kiểm tra tổng (sheet Kiem_tra)
k = sheet("Kiem_tra")
NGUON = {"POS": "POS", "WEB": "WEB", "Finance": "Sổ cái", "Sales": "Flash"}
rows = []
for r in k.itertuples():
    fmt = lambda v: vn(v, 2) if isinstance(v, float) and not float(v).is_integer() else (vn(v) if isinstance(v, (int, float)) else esc(v))
    nguon = next((v for key, v in NGUON.items() if str(r.file).startswith(key)), esc(r.file))
    rows.append(f"{r.stt} & {nguon} & {esc(r.chi_tieu)} & {fmt(r.gia_tri_de)} & {fmt(r.gia_tri_nhom)} & {vn(r.chenh_lech, 2)} & {'Đạt' if r.dat else 'Sai'} \\\\")
write("bang_kiem_tra.tex", "\n".join([
    r"\begin{longtable}{@{}r p{1.1cm} p{5.0cm} >{\raggedleft\arraybackslash}p{2.5cm} >{\raggedleft\arraybackslash}p{2.5cm} r c@{}}",
    r"\toprule", r"STT & Nguồn & Chỉ tiêu & Đề (QC\_Summary) & Nhóm & Lệch & Kết quả \\", r"\midrule", r"\endhead",
    *rows, r"\bottomrule", r"\end{longtable}", ""]))

# ---------------------------------------------------------------- Bảng 5 bẫy (sheet Bay_du_lieu)
t = sheet("Bay_du_lieu")
def ten_truy_van(text):
    """In tên truy vấn (q_...) bằng phông máy chữ, phần còn lại giữ chữ thường."""
    return re.sub(r"(q\\_[A-Za-z]+(?:\\_[A-Za-z]+)*)", r"\\texttt{\1}", esc(text))


rows = [f"{r.stt} & {esc(r.bay)} & {ten_truy_van(r.truy_van)}: {esc(r.buoc_xu_ly)} & {esc(r.truoc_khi_xu_ly)} & {esc(r.sau_khi_xu_ly)} \\\\ \\midrule"
        for r in t.itertuples()]
write("bang_bay.tex", "\n".join([
    r"{\small", r"\begin{longtable}{@{}p{0.4cm} p{2.6cm} p{3.4cm} p{4.2cm} p{4.2cm}@{}}",
    r"\toprule", r"\# & Bẫy & Truy vấn và bước xử lý & Trước khi xử lý & Sau khi xử lý \\", r"\midrule", r"\endhead",
    *rows, r"\end{longtable}}", ""]))

# ---------------------------------------------------------------- Bảng và hình chênh lệch theo tháng (sheet Chenh_lech_thang)
m = sheet("Chenh_lech_thang")
months = m[m.period.str.match(r"^\d{4}-\d{2}$")].copy()
year = m[m.period == "Cả năm"].iloc[0]
rows = [f"Tháng {int(r.period[-2:])} & {vn(r.flash_usd)} & {vn(r.gl_usd, 2)} & {vn(r.delta_usd, 2)} & {pct(r.delta_pct_flash)} \\\\" for r in months.itertuples()]
write("bang_thang.tex", "\n".join([
    r"\begin{tabular}{@{}l r r r r@{}}", r"\toprule",
    r"Tháng & Flash & Sổ cái & Chênh lệch & \% so với Flash \\", r"\midrule", *rows, r"\midrule",
    f"\\textbf{{Cả năm}} & \\textbf{{{vn(year.flash_usd)}}} & \\textbf{{{vn(year.gl_usd, 2)}}} & \\textbf{{{vn(year.delta_usd, 2)}}} & \\textbf{{{pct(year.delta_pct_flash)}}} \\\\",
    r"\bottomrule", r"\end{tabular}", ""]))

fig, ax = plt.subplots(figsize=(8.6, 3.9), dpi=200)
x = list(range(len(months)))
vals = months.delta_usd / 1000
colors = [ACCENT if v > 0 else GREY for v in vals]
ax.bar(x, vals, color=colors, width=0.62, zorder=2)
ax.axhline(0, color=INK2, linewidth=0.8, zorder=3)
ax.set_ylim(vals.min() * 1.15, max(vals.max(), 0) * 1.3 + 10)   # chừa chỗ cho nhãn số
ax.set_xticks(x, [str(int(p[-2:])) for p in months.period])
ax.set_xlabel("Tháng (năm 2025)")
ax.set_ylabel("Nghìn USD (sổ cái − Flash)")
ax.grid(axis="y", color="#e6e5e0", linewidth=0.6, zorder=0)
for side in ["top", "right"]:
    ax.spines[side].set_visible(False)
# Nhãn số chỉ cho tháng 3 (ngược chiều) và tháng lệch nhiều nhất
imax = vals.idxmin()
for i, (idx, v) in enumerate(vals.items()):
    if v > 0 or idx == imax:
        ax.annotate(vn(v), (i, v), xytext=(0, 4 if v > 0 else -12), textcoords="offset points", ha="center", color=INK, fontsize=9)
pos = months[months.delta_usd > 0]
ax.set_title(f"Sổ cái thấp hơn Flash ở {len(months) - len(pos)}/{len(months)} tháng; riêng tháng 3 cao hơn {vn(pos.delta_usd.sum() / 1000)} nghìn USD",
             loc="left", fontsize=11, color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(OUT / "hinh_chenh_lech_thang.png")
plt.close(fig)
print("ghi hinh_chenh_lech_thang.png")

# ---------------------------------------------------------------- Bảng theo kênh (sheet Chenh_lech_kenh)
c = sheet("Chenh_lech_kenh")
body = c[~c.channel_code.isin(["TOTAL", "CHECK_2CH", "CHECK_ALL"])]
tot = c[c.channel_code == "TOTAL"].iloc[0]
chk2 = c[c.channel_code == "CHECK_2CH"].iloc[0]
rows = [f"{esc(r.channel_name)} & {vn(r.flash_usd)} & {vn(r.gl_usd, 2)} & {vn(r.delta_usd, 2)} & {pct(r.delta_pct_flash) if pd.notna(r.delta_pct_flash) else '--'} \\\\" for r in body.itertuples()]
write("bang_kenh.tex", "\n".join([
    r"\begin{tabular}{@{}l r r r r@{}}", r"\toprule",
    r"Kênh & Flash & Sổ cái & Chênh lệch & \% so với Flash \\", r"\midrule", *rows, r"\midrule",
    f"\\textbf{{Tổng}} & \\textbf{{{vn(tot.flash_usd)}}} & \\textbf{{{vn(tot.gl_usd, 2)}}} & \\textbf{{{vn(tot.delta_usd, 2)}}} & \\textbf{{{pct(tot.delta_pct_flash)}}} \\\\",
    f"\\multicolumn{{3}}{{@{{}}l}}{{\\textit{{Kiểm tra: sổ cái cửa hàng + online − tổng sổ cái}}}} & \\textit{{{vn(chk2.gl_usd, 2)}}} & \\\\",
    r"\bottomrule", r"\end{tabular}", ""]))

# ---------------------------------------------------------------- Bảng chất lượng dữ liệu (sheet Chat_luong_du_lieu)
q = sheet("Chat_luong_du_lieu")
CAN_XEM = r"\textbf{Cần xem}"
rows = [f"{r.stt} & {esc(r.kiem_tra)} & {int(r.so_luong)} & {'Đạt' if r.trang_thai == 'Đạt' else CAN_XEM} & {esc(r.chi_tiet) if pd.notna(r.chi_tiet) else ''} \\\\"
        for r in q.itertuples()]
write("bang_chat_luong.tex", "\n".join([
    r"{\small", r"\begin{longtable}{@{}r L{6.4cm} r c L{4.6cm}@{}}", r"\toprule",
    r"STT & Phép kiểm tra & Số lượng & Trạng thái & Chi tiết \\", r"\midrule", r"\endhead",
    *rows, r"\bottomrule", r"\end{longtable}}", ""]))
gd = sheet("Giao_dich_chung")

# ---------------------------------------------------------------- Đối soát cửa hàng (sheet Doi_soat_CH_ngay, So_ngay_ban_ngay_ghi_so, Doi_soat_CH_thang, Lech_ngay_ghi_so)
rcd = sheet("Doi_soat_CH_ngay")
rcc = sheet("So_ngay_ban_ngay_ghi_so")
rcm = sheet("Doi_soat_CH_thang")
rct = sheet("Lech_ngay_ghi_so")
rcm25 = rcm[rcm.period.isin(months.period)]
co = rcm25.groupby("period")[["flag_raw", "flag_norm"]].sum()
tim = rct.set_index("period")
rows = []
for r in rcc[rcc.period.isin(months.period)].itertuples():
    rows.append(f"Tháng {int(r.period[-2:])} & {vn(r.cells_posting)} & {int(r.mismatch_posting)} & {vn(r.mismatch_sale_date)} & "
                f"{int(co.flag_raw.get(r.period, 0))} & {int(co.flag_norm.get(r.period, 0))} & {vn(tim.store_posting_usd.get(r.period, 0), 2)} \\\\")
cy = rcc[rcc.period == "Cả năm"].iloc[0]
write("bang_cua_hang.tex", "\n".join([
    r"\begin{tabular}{@{}l r r r r r r@{}}", r"\toprule",
    r" & \multicolumn{3}{c}{Ô cửa hàng $\times$ ngày} & \multicolumn{2}{c}{Cửa hàng vượt ngưỡng} & \\",
    r"\cmidrule(lr){2-4}\cmidrule(lr){5-6}",
    r"Tháng & Số ô & \makecell[r]{Lệch theo\\ngày ghi sổ} & \makecell[r]{Lệch theo\\ngày bán} & \makecell[r]{Chưa\\xử lý} & \makecell[r]{Sau\\xử lý} & \makecell[r]{Lệch ngày\\ghi sổ (USD)} \\",
    r"\midrule", *rows, r"\midrule",
    f"\\textbf{{Cả năm}} & \\textbf{{{vn(cy.cells_posting)}}} & \\textbf{{{int(cy.mismatch_posting)}}} & \\textbf{{{vn(cy.mismatch_sale_date)}}} & "
    f"\\textbf{{{int(co.flag_raw.sum())}}} & \\textbf{{{int(co.flag_norm.sum())}}} & \\textbf{{{vn(tim.store_posting_usd['Cả năm'], 2)}}} \\\\",
    r"\bottomrule", r"\end{tabular}", ""]))
lech = rcd[rcd.match_status != "Khớp"]
nov = rcm25[rcm25.period.str.endswith("-11")].set_index("store_code")
pairs = tim[(tim.moved_out_usd < 0) & tim.index.isin(months.period)]

# ---------------------------------------------------------------- Đối soát online, hàng trả, 5 lý do, 4 nhóm
rwd = sheet("Doi_soat_online")
rrt = sheet("Doi_soat_hang_tra")
rwm = sheet("Doi_soat_online_thang").set_index("period")
wt = sheet("Lech_thoi_diem_online").set_index("period")
nld = sheet("Nam_ly_do")
dmk = sheet("Danh_muc_khoan")
wtm = wt.loc[wt.index.isin(months.period)]
rows = [f"Tháng {int(p[-2:])} & {vn(r.online_timing_usd, 2)} & {vn(rwm.loc[p, 'diff_raw_usd'], 2)} & {'Có' if rwm.loc[p, 'flag_raw'] else ''} & "
        f"{vn(rwm.loc[p, 'diff_norm_usd'], 2)} \\\\" for p, r in wtm.iterrows()]
write("bang_online_thang.tex", "\n".join([
    r"\begin{tabular}{@{}l r r c r@{}}", r"\toprule",
    r" & & \multicolumn{3}{c}{Sổ cái $-$ WEB, USD theo tỷ giá cuối tháng} \\", r"\cmidrule(lr){3-5}",
    r"Tháng & \makecell[r]{Lệch thời điểm\\online (USD)} & \makecell[r]{Theo tháng đặt\\(chưa xử lý)} & \makecell[c]{Vượt\\ngưỡng} & \makecell[r]{Theo tháng giao,\\trừ hàng trả} \\",
    r"\midrule", *rows, r"\midrule",
    f"\\textbf{{Cả năm}} & \\textbf{{{vn(wt.loc['Cả năm', 'online_timing_usd'], 2)}}} & \\textbf{{{vn(rwm.diff_raw_usd.sum(), 2)}}} & \\textbf{{{int(rwm.flag_raw.sum())}}} & \\textbf{{{vn(rwm.diff_norm_usd.sum(), 2)}}} \\\\",
    r"\bottomrule", r"\end{tabular}", "",
]))

# Hình: lệch thời điểm online theo tháng; tháng 3 (dương lớn nhất) tô màu nhấn
fig, ax = plt.subplots(figsize=(8.6, 3.4), dpi=200)
vals = wtm.online_timing_usd / 1000
x = list(range(len(vals)))
ax.bar(x, vals, color=[ACCENT if v == vals.max() else GREY for v in vals], width=0.62, zorder=2)
ax.axhline(0, color=INK2, linewidth=0.8, zorder=3)
ax.set_xticks(x, [str(int(p[-2:])) for p in wtm.index])
ax.set_xlabel("Tháng (năm 2025)")
ax.set_ylabel("Nghìn USD")
ax.grid(axis="y", color="#e6e5e0", linewidth=0.6, zorder=0)
for side in ["top", "right"]:
    ax.spines[side].set_visible(False)
imax = int(vals.values.argmax())
ax.annotate(vn(vals.iloc[imax]), (imax, vals.iloc[imax]), xytext=(0, 4), textcoords="offset points", ha="center", color=INK, fontsize=9)
ax.set_ylim(vals.min() * 1.2, vals.max() * 1.2)
ax.set_title(f"Tháng {int(wtm.index[imax][-2:])} nhận về nhiều hơn chuyển đi {vn(vals.iloc[imax])} nghìn USD, mức lệch lớn nhất trong năm",
             loc="left", fontsize=11, color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(OUT / "hinh_lech_thoi_diem_online.png")
plt.close(fig)
print("ghi hinh_lech_thoi_diem_online.png")

# Bảng 5 lý do
def so(v, d=0):
    return "" if pd.isna(v) else vn(v, d)


rows = []
for r in nld.itertuples():
    sl = "" if pd.isna(r.so_luong) else (vn(r.so_luong, 1 if r.so_luong != int(r.so_luong) else 0) + " " + esc(r.don_vi))
    # Tháng trong cột chữ ghi "tháng 3" thay cho "2025-03" (quy ước viết của báo cáo)
    bc = re.sub(r"\b\d{4}-(\d{2})\b", lambda m: f"tháng {int(m.group(1))}", str(r.bang_chung))
    rows.append(f"{esc(r.ly_do) if r.stt.endswith(('a', '2')) or r.stt == '2' else ''} & {r.stt} & {esc(bc)} & {sl} & {so(r.usd, 2)} \\\\")
write("bang_nam_ly_do.tex", "\n".join([
    r"{\small", r"\begin{longtable}{@{}L{2.2cm} l L{6.9cm} r r@{}}", r"\toprule",
    r"Lý do & Dòng & Bằng chứng trên dữ liệu & Số lượng & USD \\", r"\midrule", r"\endhead",
    *rows, r"\bottomrule", r"\end{longtable}}", ""]))

# Bảng 4 nhóm: mỗi khoản cầu nối thuộc nhóm nào, vì sao
mid = dmk[dmk.item_group.notna() & (dmk.item_group != "")]
rows = [f"{int(r.item_order)} & {esc(r.item_name)} & {esc(r.item_group)} & {esc(r.vi_sao_nhom)} \\\\" for r in mid.itertuples()]
write("bang_bon_nhom.tex", "\n".join([
    r"{\small", r"\begin{longtable}{@{}r L{3.6cm} L{2.6cm} L{8.0cm}@{}}", r"\toprule",
    r"Thứ tự & Khoản & Nhóm & Vì sao xếp vào nhóm này \\", r"\midrule", r"\endhead",
    *rows, r"\bottomrule", r"\end{longtable}}", ""]))

# ---------------------------------------------------------------- Bảng cầu nối (sheet BR_Long, Canh_bao_cau_noi)
br = sheet("BR_Long")
brc = sheet("Canh_bao_cau_noi")
co_br = br[br.bridge == "COMPANY"]
piv = co_br.pivot_table(index=["item_order", "item_code", "item_name"], columns="period", values="usd", aggfunc="sum").reset_index()
mcols = [c for c in piv.columns if isinstance(c, str) and re.match(r"^\d{4}-\d{2}$", c)]
piv["year"] = piv[mcols].sum(axis=1)
piv = piv.sort_values("item_order")
grp = dmk.set_index("item_code").item_group
show = [c for c in mcols if c[-2:] in ("03", "11", "12")]           # 3 tháng mốc của đề: tháng 3, 11, 12


def dong(r, bold=False):
    cells = [esc(r.item_name)] + [vn(r[c], 2) for c in ["year"] + show]
    if bold:
        cells = [f"\\textbf{{{x}}}" if x else x for x in cells]
    return " & ".join(cells) + r" \\"


rows = []
for _, r in piv.iterrows():
    if r.item_code in ("gl", "check"):
        continue
    rows.append(dong(r, bold=r.item_code == "flash"))
rows += [r"\midrule", dong(piv[piv.item_code == "gl"].iloc[0], bold=True), dong(piv[piv.item_code == "check"].iloc[0])]
write("bang_cau_noi.tex", "\n".join([
    r"\begin{tabular}{@{}L{6.0cm} r r r r@{}}", r"\toprule",
    "Khoản & Cả năm & " + " & ".join(f"Tháng {int(c[-2:])}" for c in show) + r" \\", r"\midrule",
    *rows, r"\bottomrule", r"\end{tabular}", ""]))

# Hình thác nước cả năm: Flash → từng khoản → sổ cái; khoản giảm màu xám, khoản tăng màu nhấn
steps = piv[~piv.item_code.isin(["flash", "gl", "check", "channel_reclass"])]
steps = steps[steps.year.abs() >= 0.005]
fl, gl_y = piv.loc[piv.item_code == "flash", "year"].iloc[0], piv.loc[piv.item_code == "gl", "year"].iloc[0]
SHORT = {"discount": "Chiết khấu", "pos_duplicate": "Dòng trùng", "cancelled": "Đơn hủy", "online_timing": "Thời điểm\nonline",
         "store_posting": "Ngày ghi sổ\ncửa hàng", "transfer_error": "Lỗi chuyển\ndữ liệu", "returns": "Hàng trả", "shipping": "Phí vận\nchuyển",
         "fx": "Tỷ giá", "rounding": "Làm tròn", "unexplained": "Chưa giải\nthích (ADJ)"}
fig, ax = plt.subplots(figsize=(8.6, 4.0), dpi=200)
labels, run = ["Flash"], fl
ax.bar(0, fl / 1e6, color=INK2, width=0.62, zorder=2)
for i, (_, r) in enumerate(steps.iterrows(), start=1):
    v = r.year
    ax.bar(i, v / 1e6, bottom=run / 1e6, color=ACCENT if v > 0 else GREY, width=0.62, zorder=2)
    # Nhãn: số USD đầy đủ (làm tròn đến USD), khoản dưới 1.000 USD giữ 2 chữ số thập phân; không dùng ký hiệu "k"
    ax.annotate(vn(v) if abs(v) >= 1000 else vn(v, 2), (i, (run + max(v, 0)) / 1e6), xytext=(0, 3), textcoords="offset points",
                ha="center", fontsize=7.5, color=INK)
    run += v
    labels.append(SHORT.get(r.item_code, r.item_code))
ax.bar(len(labels), gl_y / 1e6, color=INK2, width=0.62, zorder=2)
labels.append("Sổ cái")
ax.set_xticks(range(len(labels)), labels, fontsize=7.5)
ax.set_ylim(28.0, 31.4)
ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda y, _: vn(y, 1)))   # dấu phẩy thập phân kiểu Việt Nam
ax.set_ylabel("Triệu USD")
ax.grid(axis="y", color="#e6e5e0", linewidth=0.6, zorder=0)
for side in ["top", "right"]:
    ax.spines[side].set_visible(False)
ax.set_title(f"Chiết khấu, hàng trả, đơn hủy giải thích phần lớn chênh lệch {vn((gl_y - fl) / 1e6, 2)} triệu USD",
             loc="left", fontsize=11, color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(OUT / "hinh_cau_noi_nam.png")
plt.close(fig)
print("ghi hinh_cau_noi_nam.png")

# Câu hỏi riêng 2: chênh lệch còn lại sau khi trừ các khoản quy tắc ghi nhận, theo tháng
rule = [c for c in dmk.item_code if grp.get(c) == "Quy tắc ghi nhận" and c != "channel_reclass"]
other = [c for c in dmk.item_code if grp.get(c) in ("Lỗi dữ liệu", "Chưa giải thích được", "Sai số chấp nhận")]
rem = co_br[co_br.item_code.isin(other)].pivot_table(index="period", columns="item_code", values="usd", aggfunc="sum").reindex(columns=other).fillna(0)
rem["con_lai"] = rem.sum(axis=1)
rem["vuot"] = rem.con_lai.abs() > 200
rows = [f"Tháng {int(p[-2:])} & {vn(r.pos_duplicate + r.transfer_error, 2)} & {vn(r.unexplained, 2)} & {vn(r.rounding, 2)} & "
        f"{vn(r.con_lai, 2)} & {'Có' if r.vuot else ''} \\\\" for p, r in rem.iterrows()]
write("bang_con_lai.tex", "\n".join([
    r"\begin{tabular}{@{}l r r r r c@{}}", r"\toprule",
    r"Tháng & Lỗi dữ liệu & \makecell[r]{Chưa giải\\thích được} & \makecell[r]{Sai số\\chấp nhận} & \makecell[r]{Còn lại sau khi trừ\\quy tắc ghi nhận} & \makecell[c]{Vượt\\200 USD} \\",
    r"\midrule", *rows, r"\bottomrule", r"\end{tabular}", ""]))

# ---------------------------------------------------------------- Nhật ký ngoại lệ (sheet Nhat_ky_du_lieu) và bảng đổi thứ tự (sheet Doi_thu_tu)
nk = sheet("Nhat_ky_du_lieu")
rows = [f"{r['Mã']} & {esc(r['Mô tả'])} & {vn(r['Ảnh hưởng (USD)'], 2)} & {esc(r['Kỳ'])} & {esc(r['Phân loại'])} & {esc(r['Hướng xử lý'])} & "
        f"{esc(r['Người phụ trách'])}; {esc(r['Trạng thái'])} \\\\" for _, r in nk.iterrows()]
write("bang_nhat_ky.tex", "\n".join([
    r"{\scriptsize", r"\begin{longtable}{@{}L{0.85cm} L{4.05cm} r L{1.6cm} L{1.6cm} L{2.85cm} L{1.7cm}@{}}", r"\toprule",
    r"Mã & Mô tả & USD & Kỳ & Phân loại & Hướng xử lý & Phụ trách; trạng thái \\", r"\midrule", r"\endhead",
    *rows, r"\midrule", f"& \\textbf{{Tổng (= chênh lệch sổ cái $-$ Flash cả năm)}} & \\textbf{{{vn(nk['Ảnh hưởng (USD)'].sum(), 2)}}} & & & & \\\\",
    r"\bottomrule", r"\end{longtable}}", ""]))
od = sheet("Doi_thu_tu")
rows = []
for r in od.itertuples():
    # Mỗi cách đổi: một dòng tên in nghiêng trải hết bảng, rồi hai khoản bị ảnh hưởng
    rows.append(f"\\multicolumn{{4}}{{@{{}}l}}{{\\textit{{{r.stt}. {esc(r.cach_doi)}}}}} \\\\")
    rows.append(f"\\quad {esc(r.khoan_1)} & {vn(r.cu_1, 2)} & {vn(r.moi_1, 2)} & {vn(r.moi_1 - r.cu_1, 2)} \\\\")
    rows.append(f"\\quad {esc(r.khoan_2)} & {vn(r.cu_2, 2)} & {vn(r.moi_2, 2)} & {vn(r.moi_2 - r.cu_2, 2)} \\\\")
    rows.append(r"\midrule")
write("bang_doi_thu_tu.tex", "\n".join([
    r"{\small", r"\begin{tabular}{@{}l r r r@{}}", r"\toprule",
    r"Cách đổi thứ tự và khoản bị ảnh hưởng & Thứ tự đã chốt & Khi đổi & Thay đổi \\", r"\midrule",
    *rows[:-1], r"\bottomrule", r"\end{tabular}}", ""]))

# ---------------------------------------------------------------- Vài con số dùng trong lời văn (macro LaTeX), để không gõ tay
web = body[body.channel_code == "WEB"].iloc[0]
macros = {
    "SoFlashNam": vn(year.flash_usd), "SoSoCaiNam": vn(year.gl_usd, 2), "SoChenhLechNam": vn(year.delta_usd, 2),
    "SoPctNam": pct(year.delta_pct_flash), "SoThangThap": str(len(months) - len(pos)),
    "SoThangBaChenhLech": vn(months.loc[months.period.str.endswith("-03"), "delta_usd"].sum(), 2),
    "SoThangBaPct": pct(months.loc[months.period.str.endswith("-03"), "delta_pct_flash"].sum()),
    "SoThangLechNhatPct": f"tháng {int(months.loc[months.delta_pct_flash.idxmin(), 'period'][-2:])} ({pct(months.delta_pct_flash.min())})",
    "SoThangLechNhatTien": f"tháng {int(months.loc[months.delta_usd.idxmin(), 'period'][-2:])} ({vn(months.delta_usd.min(), 2)})",
    "SoOnlineChenhLech": vn(web.delta_usd, 2), "SoOnlineTyTrong": pct(web.delta_usd / tot.delta_usd, 0),
    "SoChuaGanKenh": vn(-chk2.gl_usd, 2),
    "SoQCDat": str(int(k.dat.sum())), "SoQCTong": str(len(k)),
    "SoDongGiaoDich": vn(len(gd)), "SoDongPOS": vn((gd.channel == "STORE").sum()), "SoDongWEB": vn((gd.channel == "WEB").sum()),
    "SoKiemTraChatLuong": str(len(q)), "SoKiemTraCanXem": str(int((q.trang_thai != "Đạt").sum())),
}
# Số của phần đối soát cửa hàng
n11 = rcc[rcc.period.str.endswith("-11") & rcc.period.isin(months.period)].iloc[0]
x57 = nov.loc["NX057"]
macros.update({
    "SoOCuaHang": vn(len(rcd)), "SoOCuaHangKhop": vn((rcd.match_status == "Khớp").sum()), "SoOCuaHangLech": str(len(lech)),
    "SoOLechNgayBanNam": vn(cy.mismatch_sale_date), "SoOThangMuoiMot": vn(n11.cells_posting), "SoOLechNgayBanTMM": vn(n11.mismatch_sale_date),
    "SoCHVuotTruocTMM": str(int(nov.flag_raw.sum())), "SoCHVuotSauTMM": str(int(nov.flag_norm.sum())),
    "SoNXNamBayLech": vn(x57.diff_norm_usd, 2), "SoNXNamBayPct": pct(x57.pct_norm),
    "SoNXNamBaySoCai": vn(x57.gl_usd, 2), "SoNXNamBayPOS": vn(x57.pos_norm_usd, 2), "SoNXNamBayTruoc": vn(x57.diff_raw_usd, 2),
    "SoNXKhongTamTruoc": vn(nov.loc["NX008"].diff_raw_usd, 2), "SoNXKhongTamSau": vn(nov.loc["NX008"].diff_norm_usd, 2),
    "SoCHVuotTruocNam": str(int(co.flag_raw.sum())), "SoCHVuotSauNam": str(int(co.flag_norm.sum())),
    "SoCapThang": "; ".join(f"tháng {int(p[-2:])} sang tháng {int(r["to_period"][-2:])}: {vn(-r.moved_out_usd, 2)} USD ({int(r.lines_out)} dòng)"
                            for p, r in pairs.iterrows()),
    "SoSoCapThang": str(len(pairs)), "SoDongSangThang": vn(tim.lines_out["Cả năm"]),
})
# Số của phần đối soát online, hàng trả
inw, inr = rwd[rwd.match_status != "Ngoài kỳ đối soát"], rrt[rrt.match_status != "Ngoài kỳ đối soát"]
w11 = rwm.loc[[p for p in rwm.index if p.endswith("-11")][0]]
r3 = wtm.online_timing_usd.idxmax()
L = nld.set_index("stt")
macros.update({
    "SoOOnline": vn(len(inw)), "SoOOnlineKhop": vn((inw.match_status == "Khớp").sum()), "SoDonGiao": vn(inw.orders.sum()),
    "SoOOnlineNgoaiKy": vn(len(rwd) - len(inw)),
    "SoOHangTra": vn(len(inr)), "SoOHangTraKhop": vn((inr.match_status == "Khớp").sum()), "SoDonTra": vn(inr.orders.sum()),
    "SoOHangTraNgoaiKy": vn(len(rrt) - len(inr)),
    "SoOnlineTMMTruoc": vn(w11.diff_raw_usd, 2), "SoOnlineTMMSau": vn(w11.diff_norm_usd, 2), "SoOnlineTMMPct": pct(w11.pct_raw),
    "SoOnlineSauMax": vn(rwm.diff_norm_usd.abs().max(), 2),
    "SoOnlineVuotTruoc": str(int(rwm.flag_raw.sum())), "SoOnlineVuotSau": str(int(rwm.flag_norm.sum())),
    "SoLechOnlineNam": vn(wt.loc["Cả năm", "online_timing_usd"], 2), "SoLechOnlineThangMax": f"tháng {int(r3[-2:])}",
    "SoLechOnlineMax": vn(wtm.online_timing_usd.max(), 2),
    "SoLechOnlineMaxVao": vn(wtm.loc[r3, "moved_in_usd"], 2), "SoLechOnlineMaxDonVao": vn(wtm.loc[r3, "orders_in"]),
    "SoLechOnlineMaxRa": vn(-wtm.loc[r3, "moved_out_usd"], 2),
    "SoLechOnlineMaxThangTruoc": f"tháng {(int(r3[-2:]) - 2) % 12 + 1}", "SoLechOnlineMaxThangSau": f"tháng {int(r3[-2:]) % 12 + 1}",
    # Chênh lệch sổ cái − Flash của tháng đó nếu bỏ khoản lệch thời điểm online
    "SoLechOnlineMaxBoKhoan": vn(months.loc[months.period == r3, "delta_usd"].sum() - wtm.online_timing_usd.max(), 2),
    "SoVatDauKy": vn(wt.loc["Trong đó: đặt trước kỳ, giao trong kỳ", "online_timing_usd"], 2),
    "SoDonVatDauKy": vn(wt.loc["Trong đó: đặt trước kỳ, giao trong kỳ", "orders_in"]),
    "SoVatCuoiKy": vn(wt.loc["Trong đó: đặt trong kỳ, giao sau kỳ", "online_timing_usd"], 2),
    "SoDonVatCuoiKy": vn(wt.loc["Trong đó: đặt trong kỳ, giao sau kỳ", "orders_out"]),
    "SoDonHuy": vn(L.loc["3a", "so_luong"]), "SoTienHuy": vn(L.loc["3a", "usd"], 2),
    "SoDonTraTrongKy": vn(L.loc["3b", "so_luong"]), "SoTienTra": vn(L.loc["3b", "usd"], 2),
    "SoTienTraNgayTra": vn(L.loc["4b", "usd"], 2), "SoTienTraSoCai": vn(L.loc["4c", "usd"], 2),
    "SoChietKhau": vn(L.loc["2", "usd"], 2), "SoTyGia": vn(L.loc["4a", "usd"], 2), "SoPhiVanChuyen": vn(L.loc["3c", "usd"], 2),
    "SoLamTron": vn(L.loc["5d", "usd"], 2),
})
# Số của bảng cầu nối
Y = piv.set_index("item_code").year
canh = brc[brc.trang_thai != "Đạt"]
macros.update({
    "SoBRChietKhau": vn(Y["discount"], 2), "SoBRTyGia": vn(Y["fx"], 2), "SoBRLamTron": vn(Y["rounding"], 2),
    "SoBRKiemTraMax": vn(brc.check_usd.abs().max(), 2), "SoBRLamTronMax": vn(brc.rounding_usd.abs().max(), 2),
    "SoBRCanhBao": str(len(canh)),
    "SoBRCanhBaoChiTiet": "; ".join(f"bảng {dict(COMPANY='toàn công ty', STORE='cửa hàng', WEB='online', UNALLOCATED='chưa gắn kênh')[r.bridge]} tháng {int(r.period[-2:])}"
                                    for r in canh.itertuples()),
    "SoBRDongDai": vn(len(br)),
    "SoThangConLai": str(int(rem.vuot.sum())),
    "SoThangConLaiDS": ", ".join(f"tháng {int(p[-2:])}" for p in rem.index[rem.vuot]),
    "SoQuyTacNam": vn(Y[rule].sum(), 2), "SoConLaiNam": vn(rem.con_lai.sum(), 2),
})
# Số của nhật ký ngoại lệ và bảng đổi thứ tự
tt = nk["Trạng thái"].value_counts()
O = od.set_index("stt")
macros.update({
    "SoNhatKyDong": str(len(nk)), "SoNhatKyTong": vn(nk["Ảnh hưởng (USD)"].sum(), 2),
    "SoNhatKyTrangThai": "; ".join(f"{k}: {v}" for k, v in tt.items()),
    "SoDoiTrungMoi": vn(O.loc[1, "moi_1"], 2), "SoDoiHuyMoi": vn(O.loc[2, "moi_1"], 2), "SoDoiTraMoi": vn(O.loc[3, "moi_1"], 2),
    "SoDoiTyGiaMoi": vn(O.loc[3, "moi_2"], 2),
})
write("so_lieu.tex", "\n".join(f"\\newcommand{{\\{n}}}{{{v}}}" for n, v in macros.items()) + "\n")
