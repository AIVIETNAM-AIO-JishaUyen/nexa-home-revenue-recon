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
write("so_lieu.tex", "\n".join(f"\\newcommand{{\\{n}}}{{{v}}}" for n, v in macros.items()) + "\n")
