-- 3. ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ ХРАНИМОЙ ПРОЦЕДУРЫ

-- Пример 1: Загрузка данных за весь 2024 год
EXEC [dbo].[LoadStaffBonusReport] @Year = 2024, @Month = NULL;
GO

-- Пример 2: Загрузка данных за конкретный месяц (октябрь 2024)
EXEC [dbo].[LoadStaffBonusReport] @Year = 2024, @Month = 10;
GO

-- Пример 3: Загрузка данных за текущий год (параметры по умолчанию)
EXEC [dbo].[LoadStaffBonusReport];
GO

-- 4. ПРОВЕРКА РЕЗУЛЬТАТОВ В ВИТРИНЕ

-- Просмотр всех данных в витрине
SELECT 
    [Year],
    [Month],
    [StaffName],
    [BonusAmount],
    [RentRevenue],
    [ServiceRevenue],
    [ExperiencePercent],
    [LoadDate]
FROM [StaffBonusReport]
ORDER BY [Year], [Month], [StaffName];
GO

-- Сводная информация по премиям за год
SELECT 
    [Year],
    [StaffName],
    SUM([BonusAmount]) AS TotalYearBonus,
    AVG([BonusAmount]) AS AvgMonthBonus,
    SUM([RentRevenue]) AS TotalRentRevenue,
    SUM([ServiceRevenue]) AS TotalServiceRevenue
FROM [StaffBonusReport]
WHERE [Year] = 2024
GROUP BY [Year], [StaffName]
ORDER BY TotalYearBonus DESC;
GO
