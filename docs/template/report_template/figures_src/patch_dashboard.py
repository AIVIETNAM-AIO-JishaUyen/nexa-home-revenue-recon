"""Sửa hai chỗ chữ trên ảnh Dashboard, giữ nguyên toàn bộ thiết kế còn lại.
  1) KPI "Tỷ lệ outlier diện tích": 24,0%  ->  20,35%   (395/1.941)
  2) Nhãn KPI thứ ba: "Số ngày sản xuất" -> "Số ngày mô phỏng"
Chạy: python3 patch_dashboard.py"""
from PIL import Image, ImageDraw, ImageFont
import numpy as np

SRC = '/mnt/user-data/uploads/Thuc_hanh_full_final/fig10_dashboard.jpg'
DST = '/home/claude/figs/fig10_dashboard.jpg'
SERIF = '/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf'
SANS  = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'

im = Image.open(SRC).convert('RGB')
a = np.array(im)
d = ImageDraw.Draw(im)

def bg(box):
    """Màu nền lấy theo giá trị xuất hiện nhiều nhất trong khung."""
    x0, y0, x1, y1 = box
    px = a[y0:y1, x0:x1].reshape(-1, 3)
    vals, cnt = np.unique(px, axis=0, return_counts=True)
    return tuple(int(v) for v in vals[cnt.argmax()])

def put(box, text, font_path, cap_ref, cap_target, top, fill=(0, 0, 0)):
    c = bg(box)
    d.rectangle(list(box), fill=c)
    size = cap_target + 8
    for _ in range(24):
        f = ImageFont.truetype(font_path, size)
        bb = d.textbbox((0, 0), cap_ref, font=f)
        if bb[3] - bb[1] >= cap_target:
            break
        size += 1
    f = ImageFont.truetype(font_path, size)
    bb = d.textbbox((0, 0), text, font=f)
    ref = d.textbbox((0, 0), cap_ref, font=f)
    cx = (box[0] + box[2]) // 2
    d.text((cx - (bb[2] - bb[0]) / 2 - bb[0], top - ref[1]), text, font=f, fill=fill)
    return c, size

print('KPI4 gia tri:', put((1398, 89, 1534, 134), '20,35%', SERIF, '20', 29, 95))
print('KPI3 nhan   :', put((948, 55, 1252, 86), 'Số ngày mô phỏng', SANS, 'S', 20, 58))

im.save(DST, quality=96, subsampling=0)
print('da luu', DST)
