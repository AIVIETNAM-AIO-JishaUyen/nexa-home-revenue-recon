"""python_check.py – Bảng tính kiểm tra NỘI BỘ (không nộp): tính lại từng khoản của bảng cầu nối theo tháng và theo kênh
từ 4 file dữ liệu gốc, theo đúng định nghĩa ở docs/cau_truc_du_lieu.md mục 7. Đây là một cách tính độc lập với Power Query,
chỉ dùng để so: số nộp bài phải ra từ Power Query.

Chạy:  D:/Anaconda/python.exe -I checks/python_check.py
Ra:    checks/python_bridge.csv        bảng cầu nối dạng dài (cùng dạng BR_Long)
       checks/python_check_result.txt  kết quả tự so với checks/numbers_of_record.csv và dashboard mẫu của mentor

Quy ước: chênh lệch = Sổ cái − Flash; khoản làm Flash cao hơn sổ cái ghi số âm.
Mọi số USD (đô la Mỹ) đổi từ nội tệ ÷ tỷ giá (tỷ giá là số ngoại tệ đổi được 1 USD), KHÔNG làm tròn từng dòng.
Từ viết tắt: POS (Point of Sale) = bán tại cửa hàng; NX = mã cửa hàng bên kế toán; MJ (Manual Journal) = bút toán tay,
gồm MJ-SHIP (phí vận chuyển), MJ-RCL (chuyển kênh), MJ-ADJ (bút toán điều chỉnh ADJ-0925).

Lưu ý khi đọc kết quả: với các định nghĩa này, dòng kiểm tra luôn bằng 0 nếu dữ liệu đủ, kể cả khi một khoản bị xếp nhầm
tháng (dòng tỷ giá sẽ "hút" phần sai). Vì vậy script còn so với số chuẩn, tính tỷ giá theo cách thứ hai từ giao dịch,
và kiểm tra từng ô online, hàng trả với sổ cái; các phép so này mới bắt được lỗi xếp nhầm tháng.
"""
import json
import sys
from pathlib import Path

import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUT_CSV = ROOT / "checks" / "python_bridge.csv"
OUT_TXT = ROOT / "checks" / "python_check_result.txt"

# Danh mục khoản cầu nối (docs/cau_truc_du_lieu.md mục 7): mã, thứ tự, tên, nhóm
ITEMS = [
    ("flash", 0, "Doanh số Flash", ""),
    ("discount", 1, "Chiết khấu", "Quy tắc ghi nhận"),
    ("pos_duplicate", 2, "Dòng POS bị trùng", "Lỗi dữ liệu"),
    ("cancelled", 3, "Đơn online bị hủy", "Quy tắc ghi nhận"),
    ("online_timing", 4, "Lệch thời điểm online", "Quy tắc ghi nhận"),
    ("store_posting", 5, "Lệch ngày ghi sổ của cửa hàng", "Quy tắc ghi nhận"),
    ("transfer_error", 6, "Lỗi chuyển dữ liệu từ POS sang sổ cái", "Lỗi dữ liệu"),
    ("returns", 7, "Hàng trả lại", "Quy tắc ghi nhận"),
    ("shipping", 8, "Phí vận chuyển (bút toán tay MJ-SHIP)", "Quy tắc ghi nhận"),
    ("channel_reclass", 9, "Chuyển kênh (bút toán tay MJ-RCL)", "Quy tắc ghi nhận"),
    ("fx", 10, "Tỷ giá", "Quy tắc ghi nhận"),
    ("rounding", 11, "Làm tròn", "Sai số chấp nhận"),
    ("unexplained", 12, "Chưa giải thích được (bút toán ADJ-0925)", "Chưa giải thích được"),
    ("gl", 13, "Doanh thu theo sổ cái", ""),
    ("check", 14, "Kiểm tra (Flash + các khoản − sổ cái)", ""),
]
MIDDLE = [c for c, o, n, g in ITEMS if c not in ("flash", "gl", "check")]


def vn(x, d=2):
    """Viết số kiểu Việt Nam: dấu chấm ngăn nghìn, dấu phẩy thập phân."""
    return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")


# ---------------------------------------------------------------- 1. Đọc dữ liệu
def load():
    md = DATA / "Nexa_Home_Master_Data.xlsx"
    store = pd.read_excel(md, "store_master")
    cal = pd.read_excel(md, "calendar")
    fxd = pd.read_excel(md, "fx_daily")
    fxm = pd.read_excel(md, "fx_month_end")
    pos = pd.read_csv(DATA / "POS_Sales_Export_2025.csv", parse_dates=["business_date", "exported_at"])
    web = pd.read_csv(DATA / "WEB_Orders_Export.csv", dtype={"order_date": str, "delivery_date": str, "return_date": str})
    for c in ["order_date", "delivery_date", "return_date"]:          # bẫy 1: ngày kiểu Mỹ MM/DD/YYYY
        web[c] = pd.to_datetime(web[c], format="%m/%d/%Y")
    gl = pd.read_excel(DATA / "Finance_GL_Revenue_FY2025.xlsx")
    raw = pd.read_excel(DATA / "Sales_Flash_Report_2025.xlsx", header=None)
    head = raw.index[raw[0] == "Tháng"][0]                              # bẫy 2: bỏ dòng tiêu đề cho đến dòng "Tháng"
    flash = raw.iloc[head + 1:].copy()
    flash.columns = ["period", "channel_name", "market", "orders", "revenue_usd"]
    flash = flash[flash.period.astype(str).str.match(r"^\d{4}-\d{2}$")]  # bẫy 2: bỏ dòng TỔNG CỘNG
    flash["revenue_usd"] = flash.revenue_usd.astype(float)
    flash["channel"] = flash.channel_name.map({"Cửa hàng": "STORE", "Online": "WEB"})

    # Ngày ghi sổ = ngày làm việc đầu tiên kể từ ngày bán
    work = sorted(cal.loc[cal.working_day == 1, "date"])
    cal["posting_date"] = [next((w for w in work if w >= d), pd.NaT) for d in cal.date]
    post_map = cal.set_index("date").posting_date
    rate = fxd.set_index(["rate_date", "currency"]).usd_to_ccy
    rate_me = fxm.set_index(["period", "currency"]).usd_to_ccy

    # POS: đánh dấu dòng trùng (giữ lần xuất đầu tiên theo giờ xuất), ghép mã NX, ngày ghi sổ, tỷ giá ngày bán
    pos = pos.sort_values("exported_at", kind="stable")
    pos["is_duplicate"] = pos.duplicated(["receipt_no", "line_no"], keep="first")      # bẫy 4
    pos["nx"] = pos.store_id.map(store.set_index("pos_store_id").finance_store_code)
    pos["posting_date"] = pos.business_date.map(post_map)
    pos["rate"] = rate.reindex(list(zip(pos.business_date, pos.currency))).values
    pos["gross_usd"] = pos.line_amount / pos.rate                     # bẫy 5: đổi từng dòng ra USD rồi mới cộng
    pos["disc_usd"] = pos.discount_amount / pos.rate
    pos["net_local"] = pos.line_amount - pos.discount_amount
    pos["net_usd"] = pos.net_local / pos.rate
    pos["m_sale"] = pos.business_date.dt.strftime("%Y-%m")
    pos["m_post"] = pos.posting_date.dt.strftime("%Y-%m")

    # WEB: tỷ giá ngày đặt hàng cho mọi khoản (kể cả hàng trả)
    web["rate"] = rate.reindex(list(zip(web.order_date, web.currency))).values
    web["gross_usd"] = web.gross_amount / web.rate
    web["disc_usd"] = web.discount_amount / web.rate
    web["net_usd"] = web.net_amount / web.rate
    web["m_order"] = web.order_date.dt.strftime("%Y-%m")
    web["m_deliv"] = web.delivery_date.dt.strftime("%Y-%m")
    web["m_return"] = web.return_date.dt.strftime("%Y-%m")

    # Sổ cái: bẫy 3 đổi dấu; USD chưa làm tròn = nội tệ ÷ tỷ giá cuối tháng của chính bút toán
    gl["revenue_usd"] = -gl.amount_usd
    gl["revenue_local"] = -gl.amount_local
    gl["usd_unrounded"] = gl.revenue_local / gl.fx_rate_month_end
    gl["source_ref"] = gl.source_ref.fillna("")
    return dict(pos=pos, web=web, gl=gl, flash=flash, store=store, rate=rate, rate_me=rate_me)


def by_month(series, months):
    """Tổng theo tháng, chỉ giữ các tháng đối soát; tháng không có số thì 0."""
    return series.reindex(months).fillna(0.0)


# ---------------------------------------------------------------- 2. Tính từng khoản
def transfer_cells(d):
    """Ô cửa hàng × ngày ghi sổ: so nội tệ trên bút toán POS_* của sổ cái với POS đã bỏ trùng (ghép đủ 2 bên)."""
    pos, gl, rate = d["pos"], d["gl"], d["rate"]
    g = (gl[gl.journal_type.isin(["POS_DAILY", "POS_CATCHUP"])]
         .groupby(["store_code", "posting_date", "currency"]).revenue_local.sum().rename("gl_local"))
    p = (pos[~pos.is_duplicate].groupby(["nx", "posting_date", "currency"]).net_local.sum()
         .rename("pos_local").rename_axis(["store_code", "posting_date", "currency"]))
    cells = pd.concat([g, p], axis=1).fillna(0.0).reset_index()
    cells["diff_local"] = cells.gl_local - cells.pos_local
    # Quy ước: lỗi chuyển dữ liệu đổi theo tỷ giá ngày của NGÀY GHI SỔ (bút toán không ghi ngày bán)
    cells["rate"] = rate.reindex(list(zip(cells.posting_date, cells.currency))).values
    cells["diff_usd"] = cells.diff_local / cells.rate
    cells["month"] = pd.to_datetime(cells.posting_date).dt.strftime("%Y-%m")
    return cells


def bridges(d):
    pos, web, gl, flash = d["pos"], d["web"], d["gl"], d["flash"]
    M = sorted(flash.period.unique())                                  # các tháng đối soát lấy từ Flash, không ghi cứng năm
    S = lambda s: by_month(s, M)
    nd = pos[~pos.is_duplicate]
    not_cancel = web[web.order_status != "Cancelled"]
    returned = web[web.order_status == "Returned"]
    cells = transfer_cells(d)
    out = {}

    # ---- Bảng cửa hàng (STORE)
    st = pd.DataFrame(index=M)
    st["flash"] = S(flash[flash.channel == "STORE"].groupby("period").revenue_usd.sum())
    st["discount"] = -S(pos.groupby("m_sale").disc_usd.sum())                          # mọi dòng, kể cả dòng trùng
    st["pos_duplicate"] = -S(pos[pos.is_duplicate].groupby("m_sale").net_usd.sum())     # dòng trùng, giá sau giảm giá
    st["cancelled"] = 0.0
    st["online_timing"] = 0.0
    st["store_posting"] = S(nd.groupby("m_post").net_usd.sum()) - S(nd.groupby("m_sale").net_usd.sum())
    st["transfer_error"] = S(cells.groupby("month").diff_usd.sum())
    st["returns"] = 0.0
    st["shipping"] = 0.0
    gl_s = gl[gl.channel == "STORE"]
    st["channel_reclass"] = S(gl_s[gl_s.source_ref.str.startswith("MJ-RCL")].groupby("period").revenue_usd.sum())
    # Tỷ giá tính TRỰC TIẾP: sổ cái (nội tệ ÷ tỷ giá cuối tháng, chưa làm tròn) − cùng giao dịch theo tỷ giá ngày
    gl_pos = gl[gl.journal_type.isin(["POS_DAILY", "POS_CATCHUP"])]
    st["fx"] = S(gl_pos.groupby("period").usd_unrounded.sum()) - (S(nd.groupby("m_post").net_usd.sum()) + st["transfer_error"])
    # Làm tròn = phần Flash làm tròn + phần sổ cái làm tròn từng bút toán
    st["rounding"] = (S(pos.groupby("m_sale").gross_usd.sum()) - st["flash"]) + S((gl_s.revenue_usd - gl_s.usd_unrounded).groupby(gl_s.period).sum())
    st["unexplained"] = 0.0
    st["gl"] = S(gl_s.groupby("period").revenue_usd.sum())
    out["STORE"] = st

    # ---- Bảng online (WEB)
    wb = pd.DataFrame(index=M)
    wb["flash"] = S(flash[flash.channel == "WEB"].groupby("period").revenue_usd.sum())
    wb["discount"] = -S(web.groupby("m_order").disc_usd.sum())                         # mọi đơn đặt trong tháng, kể cả đơn hủy
    wb["pos_duplicate"] = 0.0
    wb["cancelled"] = -S(web[web.order_status == "Cancelled"].groupby("m_order").net_usd.sum())
    wb["online_timing"] = S(not_cancel.groupby("m_deliv").net_usd.sum()) - S(not_cancel.groupby("m_order").net_usd.sum())
    wb["store_posting"] = 0.0
    wb["transfer_error"] = 0.0
    wb["returns"] = -S(returned.groupby("m_return").net_usd.sum())                     # theo tháng nhận hàng trả, tỷ giá ngày đặt
    gl_w = gl[gl.channel == "WEB"]
    wb["shipping"] = S(gl_w[gl_w.source_ref.str.startswith("MJ-SHIP")].groupby("period").revenue_usd.sum())
    wb["channel_reclass"] = S(gl_w[gl_w.source_ref.str.startswith("MJ-RCL")].groupby("period").revenue_usd.sum())
    gl_web_auto = gl[gl.journal_type.isin(["WEB_DELIVERY", "WEB_RETURN"])]
    daily_equiv_w = S(not_cancel.groupby("m_deliv").net_usd.sum()) - S(returned.groupby("m_return").net_usd.sum())
    wb["fx"] = S(gl_web_auto.groupby("period").usd_unrounded.sum()) - daily_equiv_w
    wb["rounding"] = (S(web.groupby("m_order").gross_usd.sum()) - wb["flash"]) + S((gl_w.revenue_usd - gl_w.usd_unrounded).groupby(gl_w.period).sum())
    wb["unexplained"] = 0.0
    wb["gl"] = S(gl_w.groupby("period").revenue_usd.sum())
    out["WEB"] = wb

    # ---- Bảng chưa gắn kênh (UNALLOCATED): chỉ có bút toán ADJ-0925
    un = pd.DataFrame(0.0, index=M, columns=[c for c, *_ in ITEMS if c != "check"])
    gl_u = gl[gl.channel == "UNALLOCATED"]
    un["unexplained"] = S(gl_u[gl_u.source_ref.str.startswith("MJ-ADJ")].groupby("period").revenue_usd.sum())
    un["rounding"] = S((gl_u.revenue_usd - gl_u.usd_unrounded).groupby(gl_u.period).sum())
    un["gl"] = S(gl_u.groupby("period").revenue_usd.sum())
    out["UNALLOCATED"] = un

    # ---- Toàn công ty = cửa hàng + online + chưa gắn kênh; dòng chuyển kênh cộng lại bằng 0 nên bỏ
    co = out["STORE"] + out["WEB"] + out["UNALLOCATED"]
    co["channel_reclass"] = 0.0
    out["COMPANY"] = co

    for k, b in out.items():
        b["check"] = b["flash"] + b[MIDDLE].sum(axis=1) - b["gl"]           # dòng kiểm tra là phần dư, phải ≈ 0
    return out, cells, M


def fx_from_transactions(d, cells, M):
    """Cách tính tỷ giá thứ hai, đi từ từng giao dịch thay vì từ bút toán sổ cái:
    nội tệ × (1 ÷ tỷ giá cuối tháng ghi nhận − 1 ÷ tỷ giá ngày). Nếu một khoản bị xếp nhầm tháng, hai cách sẽ lệch nhau."""
    pos, web, rate_me = d["pos"], d["web"], d["rate_me"]
    S = lambda s: by_month(s, M)
    nd = pos[~pos.is_duplicate]
    me = rate_me.reindex(list(zip(nd.m_post, nd.currency))).values
    store = S((nd.net_local * (1 / me - 1 / nd.rate)).groupby(nd.m_post).sum())
    me_c = rate_me.reindex(list(zip(cells.month, cells.currency))).values
    store = store + S((cells.diff_local * (1 / me_c - 1 / cells.rate)).groupby(cells.month).sum())
    nc = web[(web.order_status != "Cancelled") & web.m_deliv.isin(M)]
    me_d = rate_me.reindex(list(zip(nc.m_deliv, nc.currency))).values
    rt = web[(web.order_status == "Returned") & web.m_return.isin(M)]
    me_r = rate_me.reindex(list(zip(rt.m_return, rt.currency))).values
    webfx = S((nc.net_amount * (1 / me_d - 1 / nc.rate)).groupby(nc.m_deliv).sum()) \
        - S((rt.net_amount * (1 / me_r - 1 / rt.rate)).groupby(rt.m_return).sum())
    return store, webfx


def web_cells(d, M):
    """Ô online: bút toán WEB_DELIVERY (ngày giao × loại tiền) và WEB_RETURN (ngày trả × loại tiền) so với file đơn online, theo nội tệ."""
    web, gl = d["web"], d["gl"]
    g = gl[gl.journal_type == "WEB_DELIVERY"].groupby(["posting_date", "currency"]).revenue_local.sum()
    nc = web[(web.order_status != "Cancelled") & web.m_deliv.isin(M)]
    w = nc.groupby(["delivery_date", "currency"]).net_amount.sum().rename_axis(["posting_date", "currency"])
    deliv = pd.concat([g.rename("gl"), w.rename("web")], axis=1).fillna(0.0)
    gr = gl[gl.journal_type == "WEB_RETURN"].groupby(["posting_date", "currency"]).revenue_local.sum()
    rt = web[(web.order_status == "Returned") & web.m_return.isin(M)]
    wr = (-rt.groupby(["return_date", "currency"]).net_amount.sum()).rename_axis(["posting_date", "currency"])
    ret = pd.concat([gr.rename("gl"), wr.rename("web")], axis=1).fillna(0.0)
    return deliv, ret


def to_long(out, M):
    rows = []
    for bridge in ["COMPANY", "STORE", "WEB", "UNALLOCATED"]:
        for code, order, name, group in ITEMS:
            if bridge == "COMPANY" and code == "channel_reclass":
                continue
            for m in M:
                rows.append((bridge, m, code, order, name, group, round(float(out[bridge].loc[m, code]), 4)))
    return pd.DataFrame(rows, columns=["bridge", "period", "item_code", "item_order", "item_name", "item_group", "usd"])


# ---------------------------------------------------------------- 3. Tự so
def compare(out, cells, d, M):
    rec = pd.read_csv(ROOT / "checks" / "numbers_of_record.csv").set_index("id").value
    co, st, wb = out["COMPANY"], out["STORE"], out["WEB"]
    lines, fails = [], 0

    def chk(label, got, want, tol):
        nonlocal fails
        ok = abs(got - want) <= tol
        fails += 0 if ok else 1
        lines.append(f"{'ĐẠT ' if ok else 'SAI '} {label}: nhóm {vn(got)} | chuẩn {vn(want)} | lệch {vn(got - want)} (cho phép {vn(tol, 3)})")

    lines.append("== 0. Dữ liệu đầu vào")
    chk("dòng POS thiếu tỷ giá", int(d["pos"].rate.isna().sum()), 0, 0)
    chk("đơn online thiếu tỷ giá", int(d["web"].rate.isna().sum()), 0, 0)
    chk("mã POS không ghép được mã NX", int(d["pos"].nx.isna().sum()), 0, 0)
    chk("ô cửa hàng × ngày ghi sổ thiếu tỷ giá", int(cells.rate.isna().sum()), 0, 0)
    chk("số dòng POS trùng", int(d["pos"].is_duplicate.sum()), rec.det_pos_duplicate_lines, 0)

    lines.append("== 1. Cầu nối cả năm, toàn công ty (so numbers_of_record.csv)")
    year = co.sum()
    for code in ["flash", "discount", "pos_duplicate", "cancelled", "online_timing", "store_posting", "transfer_error",
                 "returns", "shipping", "fx", "rounding", "unexplained", "gl"]:
        chk(f"cả năm {code}", year[code], rec[f"br_y_{code}"], 0.005)
    lines.append("== 2. Cầu nối tháng 12, toàn công ty (so slide 36; cho phép 0,01 vì slide làm tròn từng dòng)")
    for code in ["flash", "discount", "pos_duplicate", "cancelled", "online_timing", "store_posting", "transfer_error",
                 "returns", "shipping", "fx", "rounding", "unexplained", "gl"]:
        chk(f"tháng 12 {code}", co.loc["2025-12", code], rec[f"br_m12_{code}"], 0.01)
    lines.append("== 3. Một số tháng có số chuẩn riêng")
    chk("tháng 11 transfer_error", co.loc["2025-11", "transfer_error"], rec.br_m11_transfer_error, 0.005)
    chk("tháng 3 pos_duplicate", co.loc["2025-03", "pos_duplicate"], rec.br_m03_pos_duplicate, 0.005)
    chk("tháng 3 online_timing", co.loc["2025-03", "online_timing"], rec.br_m03_online_timing, 0.005)
    chk("tháng 9 unexplained", co.loc["2025-09", "unexplained"], rec.br_m09_unexplained, 0.005)
    lines.append("== 4. Lệch ngày ghi sổ cửa hàng tự bù trừ theo cặp tháng (tháng trước âm, tháng sau dương)")
    for a, b, key in [("05", "06", "0506"), ("08", "09", "0809"), ("11", "12", "1112")]:
        chk(f"tháng {a} store_posting", st.loc[f"2025-{a}", "store_posting"], -rec[f"tim_store_pair_{key}"], 0.005)
        chk(f"tháng {b} store_posting", st.loc[f"2025-{b}", "store_posting"], rec[f"tim_store_pair_{key}"], 0.005)
    web = d["web"]; nc = web[web.order_status != "Cancelled"]
    start = nc[(nc.order_date.dt.year < 2025) & (nc.delivery_date.dt.year == 2025)]
    end = nc[(nc.order_date.dt.year == 2025) & (nc.delivery_date.dt.year > 2025)]
    lines.append("== 5. Lệch thời điểm online cả năm không về 0 vì đơn vắt qua năm")
    chk("đơn đặt 12/2024 giao 2025", start.net_usd.sum(), rec.tim_web_start, 0.005)
    chk("đơn đặt 2025 giao 2026", -end.net_usd.sum(), rec.tim_web_end, 0.005)
    chk("số đơn đặt 12/2024 giao 2025", len(start), rec.tim_web_start_orders, 0)
    chk("số đơn đặt 2025 giao 2026", len(end), rec.tim_web_end_orders, 0)
    lines.append("== 6. Theo kênh cả năm")
    chk("Flash cửa hàng", st.flash.sum(), rec.ch_flash_store, 0.005)
    chk("Flash online", wb.flash.sum(), rec.ch_flash_web, 0.005)
    chk("Sổ cái cửa hàng", st.gl.sum(), rec.ch_gl_store, 0.005)
    chk("Sổ cái online", wb.gl.sum(), rec.ch_gl_web, 0.005)
    chk("Sổ cái chưa gắn kênh", out["UNALLOCATED"].gl.sum(), rec.ch_gl_unallocated, 0.005)
    lines.append("== 7. Từng ô so với sổ cái (theo nội tệ)")
    mism = cells[cells.diff_local.abs() > 0.005]
    chk("số ô cửa hàng × ngày ghi sổ", len(cells), rec.det_store_cells, 0)
    chk("số ô cửa hàng lệch", len(mism), rec.det_store_cells_mismatch, 0)
    lines.append("   Các ô cửa hàng lệch: " + "; ".join(f"{r.store_code} {pd.Timestamp(r.posting_date):%d/%m/%Y} {vn(r.diff_local)} {r.currency}" for r in mism.itertuples()))
    deliv, ret = web_cells(d, M)
    chk("số ô online (ngày giao × loại tiền)", len(deliv), rec.det_web_delivery_cells, 0)
    chk("số ô online lệch", int(((deliv.gl - deliv.web).abs() > 0.005).sum()), 0, 0)
    chk("số ô hàng trả (ngày trả × loại tiền)", len(ret), rec.det_web_return_cells, 0)
    chk("số ô hàng trả lệch", int(((ret.gl - ret.web).abs() > 0.005).sum()), 0, 0)
    lines.append("== 8. Tỷ giá tính theo cách thứ hai (từ từng giao dịch) so với cách tính từ sổ cái, từng tháng")
    fx_s2, fx_w2 = fx_from_transactions(d, cells, M)
    chk("cửa hàng: lệch lớn nhất 1 tháng (độ lớn)", (st.fx - fx_s2).abs().max(), 0, 0.01)
    chk("online: lệch lớn nhất 1 tháng (độ lớn)", (wb.fx - fx_w2).abs().max(), 0, 0.01)
    lines.append("== 9. Dòng kiểm tra (≤ 1 USD) và dòng làm tròn (≤ 5 USD) mọi tháng, mọi bảng")
    for k, b in out.items():
        chk(f"{k}: kiểm tra lớn nhất (độ lớn)", b.check.abs().max(), 0, 1)
        chk(f"{k}: làm tròn lớn nhất (độ lớn)", b.rounding.abs().max(), 0, 5)

    # So với dashboard mẫu của mentor (tính từ USD đã làm tròn từng dòng nên cho phép lệch ≤ 5 USD mỗi tháng × khoản).
    # Dashboard tính khoản làm tròn = mã "10" + (mã "g" − Flash); khoản "08" ở mức kênh = phí vận chuyển + chuyển kênh.
    lines.append("== 10. So với dashboard mẫu của mentor (docs/template/Nexa_Home_Recon_Dashboard.html), từng tháng × khoản")
    html = (ROOT / "docs" / "template" / "Nexa_Home_Recon_Dashboard.html").read_text(encoding="utf-8")
    j = html.index("{", html.index("window.__D"))
    D, _ = json.JSONDecoder().raw_decode(html[j:])
    rec_h = pd.DataFrame(D["rec"], columns=["mi", "store_key", "code", "usd"])
    rec_h["period"] = rec_h.mi.map(lambda i: D["months"][i])
    rec_h["bridge"] = rec_h.store_key.map(lambda k: "WEB" if k == 999999 else ("UNALLOCATED" if k == -1 else "STORE"))
    fl_h = pd.DataFrame([(D["months"][r[0]], r[1], r[3]) for r in D["flash"]], columns=["period", "bridge", "usd"])
    code_map = {"01": "discount", "02": "pos_duplicate", "03": "cancelled", "04": "online_timing", "05": "store_posting",
                "06": "transfer_error", "07": "returns", "08": "manual_docs", "09": "fx", "10": "rounding", "11": "unexplained",
                "fin": "gl", "g": "gross"}
    rec_h["item"] = rec_h.code.map(code_map)

    def html_bridge(sel):
        h = rec_h[sel(rec_h)].groupby(["period", "item"]).usd.sum().unstack().reindex(M).fillna(0.0)
        f = fl_h[sel(fl_h)].groupby("period").usd.sum().reindex(M).fillna(0.0)
        for c in code_map.values():
            if c not in h:
                h[c] = 0.0
        h["rounding"] = h["rounding"] + (h["gross"] - f)
        return h

    for name, sel, ours in [("toàn công ty", lambda t: t.index == t.index, co),
                            ("cửa hàng", lambda t: t.bridge == "STORE", st),
                            ("online", lambda t: t.bridge == "WEB", wb)]:
        h = html_bridge(sel)
        mine = ours.copy()
        mine["manual_docs"] = mine["shipping"] + mine["channel_reclass"]
        for item in ["discount", "pos_duplicate", "cancelled", "online_timing", "store_posting", "transfer_error",
                     "returns", "manual_docs", "fx", "rounding", "unexplained", "gl"]:
            diff = mine[item] - h[item]
            mx = diff.abs().max()
            ok = mx <= 5
            fails += 0 if ok else 1
            lines.append(f"{'ĐẠT ' if ok else 'SAI '} {name} {item}: lệch lớn nhất 1 tháng {vn(mx)} (tháng {diff.abs().idxmax()}); lệch cả năm (nhóm − mẫu) {vn(diff.sum())}")
    return lines, fails


def main():
    d = load()
    out, cells, M = bridges(d)
    long = to_long(out, M)
    long.to_csv(OUT_CSV, index=False, lineterminator="\n")
    head = [f"Bảng kiểm tra Python – {len(long)} dòng ghi ra {OUT_CSV.relative_to(ROOT).as_posix()}",
            f"Dữ liệu: POS {len(d['pos'])} dòng, WEB {len(d['web'])} đơn, sổ cái {len(d['gl'])} bút toán, Flash {len(d['flash'])} dòng"]
    lines, fails = compare(out, cells, d, M)
    co = out["COMPANY"]
    table = ["", "== Cầu nối toàn công ty theo tháng (USD)", co.T.round(2).to_string()]
    text = "\n".join(head + lines + [f"\nTỔNG KẾT: {fails} dòng SAI"] + table)
    OUT_TXT.write_text(text + "\n", encoding="utf-8")
    print(text)
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
