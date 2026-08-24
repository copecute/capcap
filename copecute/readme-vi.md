# Cap Cap - Ứng dụng chỉnh sửa video miễn phí

## Giới thiệu
Cap Cap là một ứng dụng chỉnh sửa video dễ dùng, hướng đến trải nghiệm nhanh, gọn và thân thiện cho mọi người dùng. Mục tiêu của dự án là giúp người dùng tạo video đẹp trong thời gian ngắn mà không cần kỹ năng chỉnh sửa chuyên sâu.

## Mục tiêu sản phẩm
- Chỉnh sửa video đơn giản, dễ học và dễ sử dụng.
- Miễn phí cho các nhu cầu cơ bản.
- Giao diện hiện đại, đồng nhất trên mobile, tablet và desktop.
- Sẵn sàng mở rộng thêm các tính năng AI trong tương lai.

## Công nghệ sử dụng
- **Frontend / UI:** Flutter
- **Media engine (dự kiến):** C++
- **Quản lý trạng thái:** Provider
- **Lưu cấu hình người dùng:** SharedPreferences

## Tính năng hiện tại (MVP)
- Flow chào mừng gồm 3 bước:
  - Giới thiệu ứng dụng, chọn ngôn ngữ, chọn giao diện Light / Dark / System
  - Xin các quyền cần thiết, trong đó quyền truy cập bộ nhớ là bắt buộc để tiếp tục
  - Đăng nhập Google ở mức demo
- Trang chủ với 4 tab chính:
  - Chỉnh sửa
  - Mẫu
  - Dự án
  - Tài khoản
- Tự động phát hiện ngôn ngữ thiết bị:
  - Nếu là tiếng Việt thì dùng `vi`
  - Nếu không thì dùng `en`

## Định hướng kiến trúc
Dự án được tách thành 2 lớp chính:
- **Lớp giao diện Flutter:** điều hướng, trạng thái, hiển thị và tương tác người dùng
- **Lớp xử lý media C++:** cắt ghép, mã hóa, hiệu ứng, xử lý âm thanh và video

Trong giai đoạn tiếp theo, Flutter sẽ gọi các module C++ thông qua FFI hoặc Platform Channel để xử lý các tác vụ media hiệu năng cao.

## Lộ trình phát triển đề xuất
1. Hoàn thiện flow tạo dự án mới và nhập media.
2. Xây dựng timeline cơ bản: cắt, tách và sắp xếp clip.
3. Thêm tính năng xuất video 720p / 1080p với tiến trình thời gian thực.
4. Tích hợp module C++ cho:
   - Giải mã / mã hóa video
   - Xử lý filter và effect cơ bản
   - Đồng bộ audio / video
5. Tối ưu hiệu năng cho thiết bị tầm trung.

## Cách chạy dự án
```bash
flutter pub get
flutter run
```

Nếu build Android gặp lỗi Kotlin cache trên Windows do project nằm ở ổ `D:` còn pub cache ở ổ `C:`, có thể tắt incremental compilation trong `android/gradle.properties`:

```properties
kotlin.incremental=false
```

## Lưu ý
- Phiên bản hiện tại tập trung vào UI/UX và luồng sử dụng ban đầu.
- Chức năng đăng nhập Google hiện là bản demo.
- Các tính năng xử lý video thực tế sẽ được triển khai dần bằng C++.
