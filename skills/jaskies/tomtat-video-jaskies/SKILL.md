---
name: tomtat-video
description: Tóm tắt nội dung video YouTube từ đường link cung cấp. Sử dụng khi anh Vũ gửi link video và yêu cầu tóm tắt, trích xuất ý chính hoặc phân tích nội dung video đó.
---

# Tóm tắt Video YouTube

Skill này giúp em lấy transcript (phụ đề) từ video YouTube và tóm tắt lại nội dung theo yêu cầu của anh Vũ.

## Quy trình thực hiện

1. **Lấy dữ liệu:** Sử dụng script `scripts/get_transcript.sh` để trích xuất transcript từ URL video.
2. **Xử lý nội dung:** Đọc nội dung transcript (định dạng VTT) và lọc bỏ các mốc thời gian để lấy văn bản thuần túy.
3. **Tóm tắt:** Sử dụng mô hình AI hiện tại để tóm tắt văn bản đó theo các ý chính, cấu trúc logic và dễ hiểu.

## Lệnh thực thi lấy transcript

```bash
bash skills/public/tomtat-video/scripts/get_transcript.sh "<URL_VIDEO>"
```

## Lưu ý
- Skill ưu tiên lấy phụ đề tiếng Việt, nếu không có sẽ lấy tiếng Anh.
- Đối với các video quá dài, em sẽ thực hiện tóm tắt theo từng phần để đảm bảo không mất thông tin quan trọng.
- Luôn trình bày bản tóm tắt một cách chuyên nghiệp và hoạt bát theo phong cách của Thanh Tình.
