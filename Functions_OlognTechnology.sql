/*
   FUNCTIONS - QUAN LY NHAN SU VA LUONG
    CONG TY OLOGN TECHNOLOGY
*/

USE QLNhanSuLuong_OlognTechnology;
GO

-- 1. Hàm tính tổng thu nhập thực lĩnh (Lấy trực tiếp cột LuongThucNhan từ bảng BANGLUONG)
CREATE OR ALTER FUNCTION fn_TinhThucLinh
(
    @MaNV VARCHAR(10),
    @Thang INT,
    @Nam INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @ThucLinh DECIMAL(18,2) = 0;

    SELECT @ThucLinh = LuongThucNhan
    FROM BANGLUONG
    WHERE MaNV = @MaNV AND Thang = @Thang AND Nam = @Nam;

    RETURN ISNULL(@ThucLinh, 0);
END;
GO

-- 2. Hàm tính tổng số ngày công trong tháng
CREATE OR ALTER FUNCTION fn_TinhTongNgayCong
(
    @MaNV VARCHAR(10),
    @Thang INT,
    @Nam INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TongNgayCong INT = 0;

    SELECT @TongNgayCong = SoNgayCong
    FROM CHAMCONG
    WHERE MaNV = @MaNV AND Thang = @Thang AND Nam = @Nam;

    RETURN ISNULL(@TongNgayCong, 0);
END;
GO

-- 3. Hàm kiểm tra thời hạn hợp đồng nhân viên (Khớp với cột NgayKetThuc trong bảng HOPDONG)
CREATE OR ALTER FUNCTION fn_KiemTraThoiHanHopDong
(
    @MaNV VARCHAR(10)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @NgayHetHan DATE;
    DECLARE @KetQua NVARCHAR(50);

    SELECT TOP 1 @NgayHetHan = NgayKetThuc
    FROM HOPDONG
    WHERE MaNV = @MaNV
    ORDER BY NgayBatDau DESC;

    IF @NgayHetHan IS NULL
        SET @KetQua = N'Không tìm thấy hợp đồng';
    ELSE IF @NgayHetHan < GETDATE()
        SET @KetQua = N'Đã hết hạn';
    ELSE IF DATEDIFF(DAY, GETDATE(), @NgayHetHan) <= 30
        SET @KetQua = N'Sắp hết hạn (trong 30 ngày)';
    ELSE
        SET @KetQua = N'Còn thời hạn';
        
    RETURN @KetQua;
END;
GO

-- 4. Hàm lấy danh sách nhân viên theo phòng ban
CREATE OR ALTER FUNCTION fn_DanhSachNhanVienTheoPhong
(
    @MaPB VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        nv.MaNV,
        nv.HoTen,
        nv.NgaySinh,
        nv.GioiTinh,
        cv.TenCV
    FROM NHANVIEN nv
    JOIN PHONGBAN pb ON nv.MaPB = pb.MaPB
    LEFT JOIN CHUCVU cv ON nv.MaCV = cv.MaCV
    WHERE pb.MaPB = @MaPB
);
GO