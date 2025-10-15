-- 2. СОЗДАНИЕ ХРАНИМОЙ ПРОЦЕДУРЫ

CREATE OR ALTER PROCEDURE [dbo].[LoadStaffBonusReport]
    @Year INT = NULL, -- если NULL, то текущий год
    @Month INT = NULL -- если NULL, то загружаем все месяцы года
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Устанавливаем год по умолчанию (текущий)
    IF @Year IS NULL
        SET @Year = YEAR(GETDATE());
    
    -- Объявляем переменные
    DECLARE @StartMonth INT;
    DECLARE @EndMonth INT;
    
    -- Если месяц не указан, загружаем все месяцы года
    IF @Month IS NULL
    BEGIN
        SET @StartMonth = 1;
        SET @EndMonth = 12;
    END
    ELSE
    BEGIN
        SET @StartMonth = @Month;
        SET @EndMonth = @Month;
    END
    
    -- Временная таблица для хранения рассчитанных премий
    CREATE TABLE #TempBonuses
    (
        [Year] INT,
        [Month] INT,
        [StaffId] INT,
        [StaffName] NVARCHAR(100),
        [BonusAmount] DECIMAL(10,2),
        [RentRevenue] DECIMAL(10,2),
        [ServiceRevenue] DECIMAL(10,2),
        [ExperiencePercent] DECIMAL(5,2)
    );
    
    -- Заполняем временную таблицу расчетом премий
    -- Цикл по месяцам
    DECLARE @CurrentMonth INT = @StartMonth;
    
    WHILE @CurrentMonth <= @EndMonth
    BEGIN
        -- Вставляем данные по каждому сотруднику за текущий месяц
        INSERT INTO #TempBonuses
        SELECT 
            @Year AS [Year],
            @CurrentMonth AS [Month],
            s.Id AS StaffId,
            s.Name AS StaffName,
            -- Формула премии: X = (P1*X1 + P2*X2)*X0
            (
                (ISNULL(SUM(r.Time * b.RentPrice), 0) * 0.30) + -- P1*X1: 30% от аренды
                (ISNULL(SUM(sb.Price), 0) * 0.80) -- P2*X2: 80% от ремонта
            ) * 
            -- X0: процент от стажа
            CASE 
                WHEN DATEDIFF(YEAR, s.HireDate, DATEFROMPARTS(@Year, @CurrentMonth, 1)) < 1 THEN 0.05 -- до 1 года - 5%
                WHEN DATEDIFF(YEAR, s.HireDate, DATEFROMPARTS(@Year, @CurrentMonth, 1)) < 2 THEN 0.10 -- 1-2 года - 10%
                ELSE 0.15 -- от 2 лет - 15%
            END AS BonusAmount,
            ISNULL(SUM(r.Time * b.RentPrice), 0) AS RentRevenue, -- выручка от аренды
            ISNULL(SUM(sb.Price), 0) AS ServiceRevenue, -- выручка от ремонтов
            -- Процент от стажа
            CASE 
                WHEN DATEDIFF(YEAR, s.HireDate, DATEFROMPARTS(@Year, @CurrentMonth, 1)) < 1 THEN 5.00
                WHEN DATEDIFF(YEAR, s.HireDate, DATEFROMPARTS(@Year, @CurrentMonth, 1)) < 2 THEN 10.00
                ELSE 15.00
            END AS ExperiencePercent
        FROM [Staff] s
        LEFT JOIN [RentBook] r ON s.Id = r.StaffId 
            AND r.Paid = 1 
            AND YEAR(r.RentDate) = @Year 
            AND MONTH(r.RentDate) = @CurrentMonth
        LEFT JOIN [Bicycle] b ON r.BicycleId = b.Id
        LEFT JOIN [ServiceBook] sb ON s.Id = sb.StaffId 
            AND YEAR(sb.ServiceDate) = @Year 
            AND MONTH(sb.ServiceDate) = @CurrentMonth
        WHERE s.HireDate <= DATEFROMPARTS(@Year, @CurrentMonth, 1) -- только сотрудники, работавшие в этом месяце
        GROUP BY s.Id, s.Name, s.HireDate;
        
        -- Переходим к следующему месяцу
        SET @CurrentMonth = @CurrentMonth + 1;
    END
    
    -- Начинаем транзакцию для безопасной загрузки
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Удаляем старые данные за указанный период
        DELETE FROM [StaffBonusReport]
        WHERE [Year] = @Year 
            AND [Month] BETWEEN @StartMonth AND @EndMonth;
        
        -- Вставляем новые данные из временной таблицы
        INSERT INTO [StaffBonusReport] 
            ([Year], [Month], [StaffId], [StaffName], [BonusAmount], 
             [RentRevenue], [ServiceRevenue], [ExperiencePercent], [LoadDate])
        SELECT 
            [Year], 
            [Month], 
            [StaffId], 
            [StaffName], 
            [BonusAmount],
            [RentRevenue],
            [ServiceRevenue],
            [ExperiencePercent],
            GETDATE() AS LoadDate
        FROM #TempBonuses;
        
        -- Фиксируем транзакцию
        COMMIT TRANSACTION;
        
        -- Возвращаем информацию о загруженных данных
        SELECT 
            @Year AS LoadedYear,
            @StartMonth AS StartMonth,
            @EndMonth AS EndMonth,
            COUNT(*) AS RecordsLoaded,
            SUM(BonusAmount) AS TotalBonusAmount
        FROM #TempBonuses;
        
        PRINT 'Данные успешно загружены в витрину StaffBonusReport';
        
    END TRY
    BEGIN CATCH
        -- В случае ошибки откатываем транзакцию
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Выводим информацию об ошибке
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    
    -- Удаляем временную таблицу
    DROP TABLE #TempBonuses;
END
GO
