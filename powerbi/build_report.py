"""build_report.py – Sinh các file báo cáo Power BI dạng PBIR (Power BI enhanced report format) trong powerbi/NexaRecon.Report/definition
từ phần mô tả trang và hình ở cuối file. Sửa trang/hình thì sửa file này rồi chạy lại; không sửa tay các file JSON sinh ra.

Chạy:  D:/Anaconda/python.exe -I powerbi/build_report.py
"""
import json
import sys
import shutil
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
REPORT = Path(__file__).resolve().parent / "NexaRecon.Report" / "definition"
SCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition"
M = "_Measures"   # bảng chứa công thức DAX


# ---------------------------------------------------------------- Hàm phụ dựng JSON
def col(entity, prop):
    return {"field": {"Column": {"Expression": {"SourceRef": {"Entity": entity}}, "Property": prop}},
            "queryRef": f"{entity}.{prop}", "nativeQueryRef": prop}


def mea(prop, entity=M):
    return {"field": {"Measure": {"Expression": {"SourceRef": {"Entity": entity}}, "Property": prop}},
            "queryRef": f"{entity}.{prop}", "nativeQueryRef": prop}


def lit(value):
    """Giá trị cố định trong phần định dạng (chữ đặt trong dấu nháy đơn, số thì giữ nguyên dạng chữ của Power BI)."""
    return {"expr": {"Literal": {"Value": value}}}


def title(text):
    return {"title": [{"properties": {"show": lit("true"), "text": lit("'" + text.replace("'", "''") + "'")}}]}


def visual(name, vtype, x, y, w, h, query=None, objects=None, container=None):
    v = {"visualType": vtype, "drillFilterOtherVisuals": True}
    if query:
        v["query"] = {"queryState": query}
    if objects:
        v["objects"] = objects
    if container:
        v["visualContainerObjects"] = container
    return {"$schema": f"{SCHEMA}/visualContainer/2.0.0/schema.json", "name": name,
            "position": {"x": x, "y": y, "z": 1000, "height": h, "width": w, "tabOrder": 1000}, "visual": v}


def card(name, x, y, w, h, measure, caption=None):
    return visual(name, "card", x, y, w, h, {"Values": {"projections": [mea(measure)]}},
                  container=title(caption) if caption else None)


def table(name, x, y, w, h, columns, caption=None):
    return visual(name, "tableEx", x, y, w, h, {"Values": {"projections": columns}},
                  container=title(caption) if caption else None)


def textbox(name, x, y, w, h, text, size="14pt", bold=False):
    style = {"fontSize": size}
    if bold:
        style["fontWeight"] = "bold"
    return visual(name, "textbox", x, y, w, h, objects={"general": [{"properties": {"paragraphs": [
        {"textRuns": [{"value": text, "textStyle": style}]}]}}]})


# ---------------------------------------------------------------- Mô tả các trang
PAGES = [
    {
        "name": "so_tong",
        "displayName": "Số tổng",
        "visuals": [
            textbox("tieu_de", 20, 10, 1240, 50, "Số tổng năm 2025: Flash, sổ cái và chênh lệch (USD)", "20pt", True),
            card("the_flash", 20, 70, 300, 120, "Flash", "Flash (báo cáo nhanh)"),
            card("the_so_cai", 340, 70, 300, 120, "Sổ cái", "Sổ cái"),
            card("the_chenh_lech", 660, 70, 300, 120, "Chênh lệch", "Chênh lệch = Sổ cái − Flash"),
            card("the_pct", 980, 70, 280, 120, "% chênh lệch so với Flash", "% chênh lệch so với Flash"),
            table("bang_thang", 20, 210, 940, 480,
                  [col("dim_date", "period"), mea("Flash"), mea("Sổ cái"), mea("Chênh lệch"), mea("% chênh lệch so với Flash")],
                  "Flash, sổ cái và chênh lệch theo tháng"),
            table("bang_kenh", 980, 210, 280, 200,
                  [col("dim_channel", "channel_name"), mea("Sổ cái")], "Sổ cái theo kênh"),
            textbox("nguon", 20, 695, 1240, 25,
                    "Nguồn: Nexa_Home_Recon_Dataset.xlsx (mentor), lấy dữ liệu ngày 15/01/2026. Công thức: bảng _Measures.", "9pt"),
        ],
    },
]


def main():
    if REPORT.exists():
        shutil.rmtree(REPORT)
    (REPORT / "pages").mkdir(parents=True)

    def dump(path, obj):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

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
                                           "pageOrder": [p["name"] for p in PAGES], "activePageName": PAGES[0]["name"]})
    for p in PAGES:
        dump(REPORT / "pages" / p["name"] / "page.json", {
            "$schema": f"{SCHEMA}/page/1.4.0/schema.json", "name": p["name"], "displayName": p["displayName"],
            "displayOption": "FitToPage", "height": 720, "width": 1280})
        for v in p["visuals"]:
            dump(REPORT / "pages" / p["name"] / "visuals" / v["name"] / "visual.json", v)
    print("Đã sinh", sum(len(p["visuals"]) for p in PAGES), "hình trên", len(PAGES), "trang")


if __name__ == "__main__":
    main()
