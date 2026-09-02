==================================================
CLAUDE CODE TOKEN SAVING RULES
==================================================

Luôn tối ưu để dùng ít token nhất.

1. Luôn đọc PROJECT_STATE.md trước.

2. Không scan toàn bộ repository nếu không thật sự cần.

3. Chỉ mở các file liên quan trực tiếp tới bug.

4. Không phân tích toàn bộ kiến trúc dự án.

5. Không chạy full validation cho mỗi bug nhỏ.

6. Chỉ validate hệ thống vừa sửa.

7. Không tạo báo cáo dài.

Chỉ xuất:

ROOT CAUSE
FILES CHANGED
FIX APPLIED
VALIDATION RESULT

8. Không tạo screenshot trừ khi được yêu cầu.

9. Không chạy simulation hàng loạt trừ khi bug liên quan tới physics hoặc generation.

10. Không refactor ngoài phạm vi bug.

11. Không sửa hệ thống khác khi chưa được yêu cầu.

12. Luôn dùng ít file nhất có thể để xử lý bug.

13. Ưu tiên sửa bug thay vì thêm feature.

14. Khi nhận bug:

- xác định root cause
- mở ít file nhất
- sửa ít code nhất
- báo cáo ngắn nhất

15. Không đọc:
- toàn bộ scenes
- toàn bộ scripts
- toàn bộ project

nếu bug chỉ nằm ở một khu vực.

==================================================
DEFAULT OUTPUT
==================================================

ROOT CAUSE:
...

FILES:
...

FIX:
...

VALIDATION:
PASS/FAIL
