-- 2. УЛУЧШЕНИЯ СХЕМЫ БД (ALTER ЗАПРОСЫ)

-- УЛУЧШЕНИЕ 1: Добавление первичного ключа в DetailForBicycle
-- ПРИЧИНА: Таблица связи должна иметь первичный ключ для предотвращения дублирования и улучшения производительности запросов
ALTER TABLE [DetailForBicycle]
ADD CONSTRAINT PK_DetailForBicycle PRIMARY KEY ([BicycleId], [DetailId]);
GO

-- УЛУЧШЕНИЕ 2: Добавление составного первичного ключа в ServiceBook
-- ПРИЧИНА: Нужна уникальная идентификация каждой записи о ремонте
-- Один велосипед может ремонтироваться несколько раз в один день разными деталями
ALTER TABLE [ServiceBook]
ADD [Id] INT IDENTITY(1,1) NOT NULL;
GO
ALTER TABLE [ServiceBook]
ADD CONSTRAINT PK_ServiceBook PRIMARY KEY ([Id]);
GO

-- УЛУЧШЕНИЕ 3: Тип данных уже NVARCHAR при создании
-- Если таблицы уже были созданы с VARCHAR, то используем ALTER:
-- ALTER TABLE [Client]
-- ALTER COLUMN [Name] NVARCHAR(100) NOT NULL;
-- ALTER TABLE [Staff]
-- ALTER COLUMN [Name] NVARCHAR(100) NOT NULL;
-- ПРИЧИНА: VARCHAR(10) не поддерживает Unicode

-- УЛУЧШЕНИЕ 4: Изменение названия колонки телефона
-- ПРИЧИНА: Пробелы в названиях колонок - плохая практика, требуют квадратных скобок
EXEC sp_rename 'Client.[Phone number]', 'PhoneNumber', 'COLUMN';
GO

-- УЛУЧШЕНИЕ 5: Изменение типа данных для цен на DECIMAL
-- ПРИЧИНА: INT не позволяет хранить дробные значения, DECIMAL(10,2) позволяет хранить копейки
ALTER TABLE [Bicycle]
ALTER COLUMN [RentPrice] DECIMAL(10,2) NOT NULL;
GO
ALTER TABLE [Detail]
ALTER COLUMN [Price] DECIMAL(10,2) NOT NULL;
GO
ALTER TABLE [ServiceBook]
ALTER COLUMN [Price] DECIMAL(10,2) NOT NULL;
GO

-- УЛУЧШЕНИЕ 6: Переименование колонки Date 
-- ПРИЧИНА: "Date" - зарезервированное слово, лучше использовать более описательное название
EXEC sp_rename 'Staff.Date', 'HireDate', 'COLUMN';
GO
EXEC sp_rename 'ServiceBook.Date', 'ServiceDate', 'COLUMN';
GO
EXEC sp_rename 'RentBook.Date', 'RentDate', 'COLUMN';
GO

-- УЛУЧШЕНИЕ 7: Добавление уникального индекса на паспорт клиента
-- ПРИЧИНА: Один паспорт не может быть у двух клиентов
CREATE UNIQUE INDEX UX_Client_Passport ON [Client]([Passport]);
GO

-- УЛУЧШЕНИЕ 8: Добавление уникального индекса на паспорт сотрудника
-- ПРИЧИНА: Один паспорт не может быть у двух сотрудников
CREATE UNIQUE INDEX UX_Staff_Passport ON [Staff]([Passport]);
GO

-- УЛУЧШЕНИЕ 9: Добавление индексов для улучшения производительности запросов
-- ПРИЧИНА: Часто будем делать JOIN и фильтровать по датам
CREATE INDEX IX_RentBook_RentDate ON [RentBook]([RentDate]);
CREATE INDEX IX_RentBook_StaffId ON [RentBook]([StaffId]);
CREATE INDEX IX_ServiceBook_ServiceDate ON [ServiceBook]([ServiceDate]);
CREATE INDEX IX_ServiceBook_StaffId ON [ServiceBook]([StaffId]);
GO

-- УЛУЧШЕНИЕ 10: Добавление ограничения CHECK для цен и времени
ALTER TABLE [Bicycle]
ADD CONSTRAINT CK_Bicycle_RentPrice CHECK ([RentPrice] >= 0);
GO
ALTER TABLE [Detail]
ADD CONSTRAINT CK_Detail_Price CHECK ([Price] >= 0);
GO
ALTER TABLE [ServiceBook]
ADD CONSTRAINT CK_ServiceBook_Price CHECK ([Price] >= 0);
GO
ALTER TABLE [RentBook]
ADD CONSTRAINT CK_RentBook_Time CHECK ([Time] > 0);
GO
