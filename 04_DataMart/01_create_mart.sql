-- 1. СОЗДАНИЕ ТАБЛИЦЫ-ВИТРИНЫ

-- Создание таблицы для хранения премий сотрудников по месяцам
CREATE TABLE [StaffBonusReport]
(
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Year] INT NOT NULL, -- год
    [Month] INT NOT NULL, -- месяц (1-12)
    [StaffId] INT NOT NULL, -- ID сотрудника
    [StaffName] NVARCHAR(100) NOT NULL, -- имя сотрудника
    [BonusAmount] DECIMAL(10,2) NOT NULL, -- размер премии
    [RentRevenue] DECIMAL(10,2) NOT NULL, -- выручка от аренды
    [ServiceRevenue] DECIMAL(10,2) NOT NULL, -- выручка от ремонтов
    [ExperiencePercent] DECIMAL(5,2) NOT NULL, -- процент от стажа
    [LoadDate] DATETIME NOT NULL DEFAULT GETDATE(), -- дата загрузки данных
    CONSTRAINT PK_StaffBonusReport PRIMARY KEY ([Id]),
    CONSTRAINT FK_StaffBonusReport_Staff FOREIGN KEY ([StaffId]) REFERENCES [Staff]([Id])
);
GO

-- Создание индекса для быстрого поиска по году, месяцу и сотруднику
CREATE UNIQUE INDEX UX_StaffBonusReport_YearMonthStaff 
ON [StaffBonusReport]([Year], [Month], [StaffId]);
GO
