"""build_report.py – Sinh các file báo cáo Power BI dạng PBIR (Power BI enhanced report format) trong powerbi/NexaRecon.Report/definition
từ phần mô tả trang và hình ở cuối file. Sửa trang/hình thì sửa file này rồi chạy lại; không sửa tay các file JSON sinh ra.

Dashboard 4 trang theo docs/yeu_cau_dashboard.md: Tổng quan · Cầu nối · Đối soát chi tiết · Hoàn trả, hủy và chất lượng dữ liệu.
Bộ lọc tháng (mặc định 12/2025), kênh, quốc gia đặt ở đầu mỗi trang và đồng bộ giữa các trang. Biểu đồ 12 tháng không bị bộ lọc tháng
tác động (để luôn thấy xu hướng). Công thức DAX (Data Analysis Expressions) nằm trong bảng _Measures, thư mục "5. Dashboard".

Chạy:  D:/Anaconda/python.exe -I powerbi/build_report.py [tên trang mở đầu, mặc định tong_quan]
"""
import json
import shutil
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
REPORT = Path(__file__).resolve().parent / "NexaRecon.Report" / "definition"
SCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition"
M = "_Measures"   # bảng chứa công thức DAX
GREY, BLUE, RED = "#9E9E9E", "#1F6FB2", "#C0392B"
NGUON = ("Nguồn: Nexa_Home_Recon_Dataset.xlsx (dữ liệu mentor chuẩn bị cho Power BI) và Nexa_Home_Recon_PQ.xlsx (bảng cầu nối, kiểm tra chất lượng "
         "của Power Query). Dữ liệu lấy đến ngày 15/01/2026. Chênh lệch = Sổ cái − Flash; số âm: sổ cái thấp hơn Flash. Đơn vị USD.")


# ---------------------------------------------------------------- Hàm phụ dựng JSON
def col(entity, prop, name=None):
    out = {"field": {"Column": {"Expression": {"SourceRef": {"Entity": entity}}, "Property": prop}},
           "queryRef": f"{entity}.{prop}", "nativeQueryRef": prop}
    if name:
        out["displayName"] = name   # tên cột hiện trên hình
    return out


def mea(prop, entity=M, name=None):
    out = {"field": {"Measure": {"Expression": {"SourceRef": {"Entity": entity}}, "Property": prop}},
           "queryRef": f"{entity}.{prop}", "nativeQueryRef": prop}
    if name:
        out["displayName"] = name
    return out


def lit(value):
    """Giá trị cố định trong phần định dạng (chữ đặt trong dấu nháy đơn, số thì giữ nguyên dạng chữ của Power BI)."""
    return {"expr": {"Literal": {"Value": value}}}


def no_axis_title():
    """Ẩn tên trục (tiêu đề hình đã nói rõ hình vẽ gì)."""
    return {"categoryAxis": [{"properties": {"showAxisTitle": lit("false")}}],
            "valueAxis": [{"properties": {"showAxisTitle": lit("false")}}]}


def mexpr(prop):
    """Giá trị lấy từ một công thức (dùng cho tiêu đề có số, màu theo điều kiện)."""
    return {"expr": {"Measure": {"Expression": {"SourceRef": {"Entity": M}}, "Property": prop}}}


def title(text=None, measure=None, size="11"):
    t = lit("'" + text.replace("'", "''") + "'") if text else mexpr(measure)
    return {"title": [{"properties": {"show": lit("true"), "text": t, "fontSize": lit(size + "D")}}]}


def sort(field, desc=False):
    return {"sort": [{"field": field["field"], "direction": "Descending" if desc else "Ascending"}], "isDefaultSort": False}


def where_in(entity, prop, values, negate=False):
    """Bộ lọc của một hình: cột nằm trong (hoặc không nằm trong) danh sách giá trị."""
    cond = {"In": {"Expressions": [{"Column": {"Expression": {"SourceRef": {"Source": "t"}}, "Property": prop}}],
                   "Values": [[{"Literal": {"Value": v}}] for v in values]}}
    if negate:
        cond = {"Not": {"Expression": cond}}
    return {"name": f"f_{entity}_{prop}", "field": col(entity, prop)["field"], "type": "Categorical",
            "filter": {"Version": 2, "From": [{"Name": "t", "Entity": entity, "Type": 0}], "Where": [{"Condition": cond}]}}


def where_measure_eq(prop, value):
    """Bộ lọc của một hình theo công thức: công thức = value."""
    return {"name": "f_measure", "field": mea(prop)["field"], "type": "Advanced",
            "filter": {"Version": 2, "From": [{"Name": "m", "Entity": M, "Type": 0}],
                       "Where": [{"Condition": {"Comparison": {"ComparisonKind": 0,
                                                               "Left": {"Measure": {"Expression": {"SourceRef": {"Source": "m"}}, "Property": prop}},
                                                               "Right": {"Literal": {"Value": value}}}}}]}}


def visual(name, vtype, x, y, w, h, query=None, objects=None, container=None, filters=None, extra=None):
    v = {"visualType": vtype, "drillFilterOtherVisuals": True}
    if query:
        v["query"] = query
    if objects:
        v["objects"] = objects
    if container:
        v["visualContainerObjects"] = container
    if extra:
        v.update(extra)
    out = {"$schema": f"{SCHEMA}/visualContainer/2.0.0/schema.json", "name": name,
           "position": {"x": x, "y": y, "z": 1000, "height": h, "width": w, "tabOrder": 1000}, "visual": v}
    if filters:
        out["filterConfig"] = {"filters": filters}
    return out


def qs(roles, sort_def=None):
    q = {"queryState": {r: {"projections": p} for r, p in roles.items()}}
    if sort_def:
        q["sortDefinition"] = sort_def
    return q


def textbox(name, x, y, w, h, text, size="14pt", bold=False, color=None):
    style = {"fontSize": size}
    if bold:
        style["fontWeight"] = "bold"
    if color:
        style["color"] = color
    return visual(name, "textbox", x, y, w, h, objects={"general": [{"properties": {"paragraphs": [
        {"textRuns": [{"value": text, "textStyle": style}]}]}}]})


def card(name, x, y, w, h, measure, caption=None, size="20", color=None):
    labels = {"fontSize": lit(size + "D"), "labelDisplayUnits": lit("1D")}   # hiện đủ số, không rút gọn thành K/M
    if color:
        labels["color"] = {"solid": {"color": lit(f"'{color}'")}}
    objects = {"labels": [{"properties": labels}], "categoryLabels": [{"properties": {"show": lit("false")}}],
               "wordWrap": [{"properties": {"show": lit("true")}}]}
    return visual(name, "card", x, y, w, h, qs({"Values": [mea(measure)]}), objects=objects,
                  container=title(caption, size="10") if caption else None)


def kpi(prefix, i, measure, caption, change, y=108):
    """Ô số liệu chính: giá trị + dòng so với tháng trước."""
    x = 20 + i * 248
    return [card(f"{prefix}_{i}", x, y, 240, 62, measure, caption, size="18"),
            card(f"{prefix}_{i}_doi", x, y + 62, 240, 30, change, None, size="9", color=GREY)]


def slicers(page):
    """Bộ lọc dùng chung: tháng (mặc định 12/2025), kênh, quốc gia; đồng bộ giữa các trang."""
    def sl(name, x, entity, prop, caption, group, filters, default=None):
        objects = {"data": [{"properties": {"mode": lit("'Dropdown'")}}],
                   "header": [{"properties": {"text": lit(f"'{caption}'"), "fontSize": lit("9D")}}]}
        if default:
            objects["general"] = [{"properties": {"filter": {"filter": {
                "Version": 2, "From": [{"Name": "d", "Entity": entity, "Type": 0}],
                "Where": [{"Condition": {"In": {"Expressions": [{"Column": {"Expression": {"SourceRef": {"Source": "d"}}, "Property": prop}}],
                                                "Values": [[{"Literal": {"Value": default}}]]}}}]}}}}]
        return visual(f"{page}_{name}", "slicer", x, 2, 175, 52, qs({"Values": [col(entity, prop)]}), objects=objects, filters=filters,
                      extra={"syncGroup": {"groupName": group, "fieldChanges": True, "filterChanges": True}})
    return [
        sl("loc_thang", 725, "dim_date", "period", "Tháng", "thang", [where_in("dim_date", "trong_ky_doi_soat", ["true"])], "'2025-12'"),
        sl("loc_kenh", 905, "dim_channel", "channel_name", "Kênh", "kenh", [where_in("dim_channel", "channel_code", ["'UNALLOCATED'"], True)]),
        sl("loc_nuoc", 1085, "dim_store", "country", "Quốc gia (bỏ online)", "nuoc",
           [where_in("dim_store", "country", ["'Online'"], True)]),
    ]


def header(page, text, key_measure):
    """Dòng 1: tên trang (trái) và 3 bộ lọc (phải). Dòng 2: câu "Điểm chính" trải hết chiều ngang."""
    return [textbox(f"{page}_tieu_de", 20, 6, 690, 40, text, "18pt", True),
            *slicers(page),
            card(f"{page}_diem_chinh", 20, 56, 1240, 46, key_measure, "Điểm chính", size="10")]


def footer(page):
    return textbox(f"{page}_nguon", 20, 694, 1240, 24, NGUON, "8pt", color=GREY)


def line(name, x, y, w, h, category, series, title_measure, colors):
    objects = {"labels": [{"properties": {"show": lit("true"), "fontSize": lit("8D"), "labelDisplayUnits": lit("1D")}}],
               "dataPoint": [{"properties": {"fill": {"solid": {"color": lit(f"'{c}'")}}}, "selector": {"metadata": f"{M}.{s}"}}
                             for s, c in zip(series, colors)], **no_axis_title()}
    return visual(name, "lineChart", x, y, w, h, qs({"Category": [category], "Y": [mea(s) for s in series]}, sort(category)),
                  objects=objects, container=title(measure=title_measure), filters=[IN_PERIOD])


def columns(name, x, y, w, h, category, measure, title_measure, color=GREY, color_measure=None):
    fill = {"solid": {"color": mexpr(color_measure) if color_measure else lit(f"'{color}'")}}
    dp = {"properties": {"fill": fill}}
    if color_measure:
        dp["selector"] = {"data": [{"dataViewWildcard": {"matchingOption": 1}}]}
    objects = {"labels": [{"properties": {"show": lit("true"), "fontSize": lit("8D"), "labelDisplayUnits": lit("1D")}}], "dataPoint": [dp],
               **no_axis_title()}
    return visual(name, "clusteredColumnChart", x, y, w, h, qs({"Category": [category], "Y": [mea(measure)]}, sort(category)),
                  objects=objects, container=title(measure=title_measure), filters=[IN_PERIOD])


def table(name, x, y, w, h, columns_, title_text=None, title_measure=None, sort_def=None, filters=None, font_color=None):
    objects = {"total": [{"properties": {"totals": lit("false")}}]}   # bỏ dòng tổng (cộng các chênh lệch, cờ thì vô nghĩa)
    if font_color:
        measure, target = font_color
        objects["values"] = [{"properties": {"fontColor": {"solid": {"color": mexpr(measure)}}},
                               "selector": {"data": [{"dataViewWildcard": {"matchingOption": 1}}], "metadata": target}}]
    return visual(name, "tableEx", x, y, w, h, qs({"Values": columns_}, sort_def), objects=objects,
                  container=title(title_text, title_measure), filters=filters)


PERIOD = col("dim_date", "period", "Tháng")
# Biểu đồ theo tháng chỉ hiện các tháng đối soát (bảng ngày có cả tháng 12 năm trước, tháng 1 năm sau)
IN_PERIOD = where_in("dim_date", "trong_ky_doi_soat", ["true"])
ITEM = col("dim_bridge_item", "item_name", "Khoản")
NOT_FLASH_GL = where_in("dim_bridge_item", "item_code", ["'flash'", "'gl'", "'check'"], True)


def waterfall(name, x, y, w, h, category, title_measure, drop):
    """Thác nước: xanh là khoản làm tăng, xám là khoản làm giảm; cột cuối (tổng) xanh. Ẩn chú thích tiếng Anh, hiện đủ số."""
    objects = {"labels": [{"properties": {"show": lit("true"), "fontSize": lit("7D"), "labelDisplayUnits": lit("1D")}}],
               "legend": [{"properties": {"show": lit("false")}}],
               "sentimentColors": [{"properties": {"increaseFill": {"solid": {"color": lit(f"'{BLUE}'")}},
                                                   "decreaseFill": {"solid": {"color": lit(f"'{GREY}'")}},
                                                   "totalFill": {"solid": {"color": lit(f"'{BLUE}'")}}}}],
               **no_axis_title()}
    return visual(name, "waterfallChart", x, y, w, h,
                  qs({"Category": [category], "Y": [mea("Cầu nối (DAX, cộng các khoản)", name="USD")]}, sort(category)),
                  objects=objects, container=title(measure=title_measure),
                  filters=[where_in("dim_bridge_item", "item_code", [f"'{c}'" for c in drop], True)])

# ---------------------------------------------------------------- Mô tả các trang
P1 = "tong_quan"
P2 = "cau_noi"
P3 = "doi_soat"
P4 = "tra_huy"
PAGES = [
    {"name": P1, "displayName": "1 · Tổng quan",
     "trend": ["p1_duong", "p1_pct", "p1_con_lai"],
     "visuals": [
         *header(P1, "Tổng quan: Flash so với sổ cái", "Điểm chính trang 1"),
         *kpi(P1, 0, "Flash trong kỳ", "Flash (USD)", "Thay đổi so với tháng trước (Flash)"),
         *kpi(P1, 1, "Sổ cái (nghìn USD)", "Sổ cái (nghìn USD)", "Thay đổi so với tháng trước (Sổ cái)"),
         *kpi(P1, 2, "Chênh lệch (USD và %)", "Chênh lệch (USD, % so với Flash)", "Thay đổi so với tháng trước (Chênh lệch)"),
         *kpi(P1, 3, "Nhóm lỗi dữ liệu", "Phần do lỗi dữ liệu (USD)", "Thay đổi so với tháng trước (Lỗi dữ liệu)"),
         *kpi(P1, 4, "Nhóm chưa giải thích được", "Phần chưa giải thích (USD)", "Thay đổi so với tháng trước (Chưa giải thích)"),
         line("p1_duong", 20, 204, 610, 240, PERIOD, ["Flash trong kỳ", "Sổ cái trong kỳ"], "Tiêu đề (Flash và sổ cái)", [GREY, BLUE]),
         # Đúng yêu cầu: Flash → 4 nhóm → sổ cái (cột tổng cuối cùng chính là sổ cái)
         waterfall("p1_thac_nuoc", 650, 204, 610, 240, col("dim_bridge_item", "nhom_thac_nuoc", "Nhóm"),
                   "Tiêu đề (thác nước theo nhóm)", ["gl", "check"]),
         columns("p1_pct", 20, 450, 610, 238, PERIOD, "% chênh lệch trong kỳ", "Tiêu đề (% chênh lệch theo tháng)"),
         columns("p1_con_lai", 650, 450, 610, 238, PERIOD, "Còn lại sau quy tắc ghi nhận", "Tiêu đề (còn lại sau quy tắc)", color_measure="Màu còn lại"),
         footer(P1),
     ]},
    {"name": P2, "displayName": "2 · Cầu nối",
     "trend": ["p2_bang_thang", "p2_doi_chieu"],
     "visuals": [
         *header(P2, "Cầu nối: từ Flash đến sổ cái từng khoản", "Điểm chính trang 2"),
         *kpi(P2, 0, "Flash trong kỳ", "Flash (USD)", "Thay đổi so với tháng trước (Flash)"),
         *kpi(P2, 1, "Nhóm quy tắc ghi nhận", "Quy tắc ghi nhận (USD)", "Thay đổi so với tháng trước (Quy tắc ghi nhận)"),
         *kpi(P2, 2, "Nhóm lỗi dữ liệu", "Lỗi dữ liệu (USD)", "Thay đổi so với tháng trước (Lỗi dữ liệu)"),
         *kpi(P2, 3, "Nhóm chưa giải thích được", "Chưa giải thích (USD)", "Thay đổi so với tháng trước (Chưa giải thích)"),
         *kpi(P2, 4, "Sổ cái trong kỳ", "Sổ cái (USD)", "Thay đổi so với tháng trước (Sổ cái trong kỳ)"),
         # Từng khoản, đi từ 0 đến tổng chênh lệch (Flash và sổ cái đã có ở ô số liệu chính; để cột Flash thì các khoản quá nhỏ, không đọc được)
         waterfall("p2_thac_nuoc", 20, 204, 760, 250, ITEM, "Tiêu đề (thác nước từng khoản)", ["flash", "gl", "check"]),
         visual("p2_xep_hang", "clusteredBarChart", 790, 204, 470, 250,
                qs({"Category": [ITEM], "Y": [mea("% trên độ lớn chênh lệch", name="% độ lớn chênh lệch")]}, sort(mea("% trên độ lớn chênh lệch"), True)),
                objects={"labels": [{"properties": {"show": lit("true"), "fontSize": lit("8D")}}],
                         "dataPoint": [{"properties": {"fill": {"solid": {"color": lit(f"'{GREY}'")}}}}], **no_axis_title()},
                container=title(measure="Tiêu đề (xếp hạng khoản)"), filters=[NOT_FLASH_GL]),
         visual("p2_bang_thang", "pivotTable", 20, 460, 900, 230,
                qs({"Rows": [ITEM], "Columns": [PERIOD], "Values": [mea("Cầu nối (DAX, cộng các khoản)", name="USD")]}, sort(ITEM)),
                objects={"subTotals": [{"properties": {"rowSubtotals": lit("false"), "columnSubtotals": lit("false")}}]},
                container=title("Bảng cầu nối từng tháng (DAX): dòng kiểm tra bằng 0 ở mọi tháng")),
         table("p2_doi_chieu", 930, 460, 330, 230,
               [PERIOD, mea("Tổng các khoản (DAX)", name="DAX"), mea("Tổng các khoản (Power Query)", name="Power Query"),
                mea("Lệch tổng DAX − Power Query", name="Lệch")],
               title_measure="Tiêu đề (đối chiếu)", sort_def=sort(PERIOD)),
         footer(P2),
     ]},
    {"name": P3, "displayName": "3 · Đối soát chi tiết",
     "trend": ["p3_cua_hang", "p3_online"],
     "visuals": [
         *header(P3, "Đối soát chi tiết: cửa hàng × ngày ghi sổ, online × ngày giao", "Điểm chính trang 3"),
         *kpi(P3, 0, "Số ô cửa hàng × ngày", "Số ô cửa hàng × ngày", "Thay đổi so với tháng trước (Số ô cửa hàng × ngày)"),
         *kpi(P3, 1, "Số ô lệch theo ngày bán", "Số ô lệch nếu so theo ngày bán", "Thay đổi so với tháng trước (Số ô lệch theo ngày bán)"),
         *kpi(P3, 2, "Số ô vượt ngưỡng trước xử lý", "Cửa hàng × tháng vượt ngưỡng: chưa xử lý", "Thay đổi so với tháng trước (Số ô vượt ngưỡng trước xử lý)"),
         *kpi(P3, 3, "Số ô vượt ngưỡng sau xử lý", "Cửa hàng × tháng vượt ngưỡng: sau xử lý", "Thay đổi so với tháng trước (Số ô vượt ngưỡng sau xử lý)"),
         *kpi(P3, 4, "Chênh lệch online theo ngày giao", "Chênh lệch online theo ngày giao (USD)", "Thay đổi so với tháng trước (Chênh lệch online theo ngày giao)"),
         line("p3_cua_hang", 20, 204, 610, 220, PERIOD, ["Chênh lệch cửa hàng trước xử lý (trong kỳ)", "Chênh lệch cửa hàng sau xử lý (trong kỳ)"],
              "Tiêu đề (chênh lệch cửa hàng)", [GREY, BLUE]),
         line("p3_online", 650, 204, 610, 220, PERIOD, ["Chênh lệch online theo ngày đặt", "Chênh lệch online theo ngày giao"],
              "Tiêu đề (chênh lệch online)", [GREY, BLUE]),
         table("p3_cua_hang_bang", 20, 430, 610, 260,
               [col("dim_store", "finance_store_code", "Cửa hàng"), mea("Chênh lệch cửa hàng trước xử lý (trong kỳ)", name="Lệch chưa xử lý"),
                mea("Chênh lệch cửa hàng sau xử lý (trong kỳ)", name="Lệch sau xử lý"),
                mea("Độ lớn chênh lệch cửa hàng sau xử lý", name="Độ lớn sau xử lý"), mea("Cờ vượt ngưỡng (ký hiệu)", name="Cờ")],
               title_text="Cửa hàng xếp theo độ lớn chênh lệch sau xử lý; đỏ: vượt 200 USD và 1% sổ cái",
               sort_def=sort(mea("Độ lớn chênh lệch cửa hàng sau xử lý"), True),
               filters=[where_in("dim_store", "channel_code", ["'STORE'"])],
               font_color=("Màu cờ cửa hàng", f"{M}.Cờ vượt ngưỡng (ký hiệu)")),
         table("p3_o_lech", 650, 430, 610, 260,
               [col("dim_store", "finance_store_code", "Cửa hàng"), col("dim_date", "date", "Ngày ghi sổ"), mea("POS theo ngày ghi sổ (nội tệ)", name="POS (nội tệ)"),
                mea("Sổ cái bút toán POS (nội tệ)", name="Sổ cái (nội tệ)"), mea("Lệch ô (nội tệ)", name="Lệch (nội tệ)")],
               title_measure="Tiêu đề (ô còn lệch)", filters=[where_measure_eq("Ô còn lệch", "1L")]),
         footer(P3),
     ]},
    {"name": P4, "displayName": "4 · Hoàn trả, hủy, chất lượng dữ liệu",
     "trend": ["p4_ty_le", "p4_huy"],
     "visuals": [
         *header(P4, "Hoàn trả, hủy và chất lượng dữ liệu", "Điểm chính trang 4"),
         *kpi(P4, 0, "Hàng trả", "Hàng trả (USD)", "Thay đổi so với tháng trước (Hàng trả)"),
         *kpi(P4, 1, "Tỷ lệ hàng trả", "Tỷ lệ hàng trả", "Thay đổi so với tháng trước (Tỷ lệ hàng trả)"),
         *kpi(P4, 2, "Số đơn hủy", "Số đơn hủy (theo tháng đặt)", "Thay đổi so với tháng trước (Số đơn hủy)"),
         *kpi(P4, 3, "Số dòng POS trùng", "Số dòng POS trùng", "Thay đổi so với tháng trước (Số dòng POS trùng)"),
         *kpi(P4, 4, "Số bút toán tay", "Số bút toán tay", "Thay đổi so với tháng trước (Số bút toán tay)"),
         line("p4_ty_le", 20, 204, 610, 200, PERIOD, ["Tỷ lệ hàng trả"], "Tiêu đề (tỷ lệ hàng trả)", [BLUE]),
         columns("p4_huy", 650, 204, 610, 200, PERIOD, "Số đơn hủy", "Tiêu đề (đơn hủy)"),
         table("p4_but_toan_tay", 20, 410, 610, 280,
               [col("fact_gl_entry", "journal_id", "Bút toán"), col("fact_gl_entry", "posting_date", "Ngày ghi sổ"), col("fact_gl_entry", "source_ref", "Mã tham chiếu"),
                mea("Sổ cái", name="USD"), col("fact_gl_entry", "description", "Diễn giải")],
               title_measure="Tiêu đề (bút toán tay)", sort_def=sort(col("fact_gl_entry", "posting_date")),
               filters=[where_in("fact_gl_entry", "journal_type", ["'MANUAL'"])],
               font_color=("Màu bút toán tay", "fact_gl_entry.source_ref")),
         table("p4_chat_luong", 650, 410, 610, 280,
               [col("pq_data_quality", "kiem_tra", "Phép kiểm tra"), col("pq_data_quality", "so_luong", "Số lượng"),
                col("pq_data_quality", "trang_thai", "Trạng thái"), col("pq_data_quality", "chi_tiet", "Chi tiết")],
               title_text="13 phép kiểm tra dữ liệu (cả năm, từ Power Query); đỏ: cần xem", sort_def=sort(col("pq_data_quality", "kiem_tra")),
               font_color=("Màu phép kiểm tra", "pq_data_quality.trang_thai")),
         footer(P4),
     ]},
]


def main():
    start = sys.argv[1] if len(sys.argv) > 1 else P1
    if REPORT.exists():
        shutil.rmtree(REPORT)
    (REPORT / "pages").mkdir(parents=True)

    def dump(path, obj):
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(json.dumps(obj, indent=2, ensure_ascii=False) + "\n")

    dump(REPORT / "version.json", {"$schema": f"{SCHEMA}/versionMetadata/1.0.0/schema.json", "version": "2.0.0"})
    dump(REPORT / "report.json", {
        "$schema": f"{SCHEMA}/report/1.3.0/schema.json",
        "themeCollection": {"baseTheme": {"name": "CY24SU10", "reportVersionAtImport": "5.61", "type": "SharedResources"}},
        "layoutOptimization": "None",
        "resourcePackages": [{"name": "SharedResources", "type": "SharedResources",
                              "items": [{"name": "CY24SU10", "path": "BaseThemes/CY24SU10.json", "type": "BaseTheme"}]}],
        "settings": {"useStylableVisualContainerHeader": True, "defaultFilterActionIsDataFilter": True,
                     "defaultDrillFilterOtherVisuals": True, "allowChangeFilterTypes": True},
    })
    dump(REPORT / "pages" / "pages.json", {"$schema": f"{SCHEMA}/pagesMetadata/1.0.0/schema.json",
                                           "pageOrder": [p["name"] for p in PAGES], "activePageName": start})
    for p in PAGES:
        # Bộ lọc tháng không tác động lên các biểu đồ 12 tháng
        inter = [{"source": f"{p['name']}_loc_thang", "target": t, "type": "NoFilter"} for t in p["trend"]]
        dump(REPORT / "pages" / p["name"] / "page.json", {
            "$schema": f"{SCHEMA}/page/1.4.0/schema.json", "name": p["name"], "displayName": p["displayName"],
            "displayOption": "FitToPage", "height": 720, "width": 1280, "visualInteractions": inter})
        for v in p["visuals"]:
            dump(REPORT / "pages" / p["name"] / "visuals" / v["name"] / "visual.json", v)
    print("Đã sinh", sum(len(p["visuals"]) for p in PAGES), "hình trên", len(PAGES), "trang; trang mở đầu:", start)


if __name__ == "__main__":
    main()
