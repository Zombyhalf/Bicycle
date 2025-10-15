-- -----------------------------------------------
-- 1. СОЗДАНИЕ ИСХОДНЫХ ТАБЛИЦ
-- -----------------------------------------------

-- Создание базы данных (опционально)
-- CREATE DATABASE BicycleRental;
-- GO
-- USE BicycleRental;
-- GO

-- Таблица велосипедов
CREATE TABLE [Bicycle]
(
   [Id] INT IDENTITY(1,1) NOT NULL,
   [Brand] NVARCHAR(50) NOT NULL, -- изменено на NVARCHAR для поддержки любых символов
   [RentPrice] INT NOT NULL, -- цена аренды
   PRIMARY KEY(Id)
);

-- Таблица клиентов
CREATE TABLE [Client]
(
   [Id] INT IDENTITY(1,1) NOT NULL,
   [Name] NVARCHAR(100) NOT NULL, -- изменено на NVARCHAR(100) сразу
   [Passport] VARCHAR(50) NOT NULL,
   [Phone number] VARCHAR(50) NOT NULL,
   [Country] NVARCHAR(50) NOT NULL, -- изменено на NVARCHAR
   PRIMARY KEY(Id)
);

-- Таблица сотрудников
CREATE TABLE [Staff]
(
   [Id] INT IDENTITY(1,1) NOT NULL,
   [Name] NVARCHAR(100) NOT NULL, -- изменено на NVARCHAR(100) сразу
   [Passport] VARCHAR(50) NOT NULL,
   [Date] DATE NOT NULL, -- дата начала работы
   PRIMARY KEY(Id)
);

-- Таблица запчастей
CREATE TABLE [Detail]
(
   [Id] INT IDENTITY(1,1) NOT NULL,
   [Brand] NVARCHAR(50) NOT NULL, -- изменено на NVARCHAR
   [Type] NVARCHAR(50) NOT NULL, -- изменено на NVARCHAR
   [Name] NVARCHAR(50) NOT NULL, -- изменено на NVARCHAR
   [Price] INT NOT NULL,
   PRIMARY KEY(Id)
);

-- Список деталей подходящих к велосипедам
CREATE TABLE [DetailForBicycle]
(
   [BicycleId] INT NOT NULL,
   [DetailId] INT NOT NULL,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
);

-- Сервисное обслуживание велосипедов
CREATE TABLE [ServiceBook]
(
   [BicycleId] INT NOT NULL,
   [DetailId] INT NOT NULL,
   [Date] DATE NOT NULL,
   [Price] INT NOT NULL, -- цена работы
   [StaffId] INT NOT NULL,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
);

-- Аренда велосипеда клиентом
CREATE TABLE [RentBook]
(
   [Id] INT IDENTITY(1,1) NOT NULL,
   [Date] DATE NOT NULL, -- дата аренды
   [Time] INT NOT NULL, -- время аренды в часах
   [Paid] BIT NOT NULL, -- 1 оплатил; 0 не оплатил 
   [BicycleId] INT NOT NULL,
   [ClientId] INT NOT NULL,
   [StaffId] INT NOT NULL,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([ClientId]) REFERENCES [Client] ([Id])
);
GO
