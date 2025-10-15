-- ЗАПРОС 1: Топ-5 наиболее рентабельных велосипедов
-- (минимальные траты на ремонт и максимальная выручка за аренду)
-- Затрагивает 3 таблицы: Bicycle, RentBook, ServiceBook
SELECT TOP 5
    b.Id AS BicycleId,
    b.Brand AS BicycleBrand,
    ISNULL(SUM(r.Time * b.RentPrice), 0) AS TotalRevenue, -- общая выручка
    ISNULL(SUM(s.Price), 0) AS TotalServiceCost, -- общие затраты на ремонт
    ISNULL(SUM(r.Time * b.RentPrice), 0) - ISNULL(SUM(s.Price), 0) AS NetProfit, -- чистая прибыль
    COUNT(DISTINCT r.Id) AS RentCount, -- количество аренд
    COUNT(DISTINCT s.Id) AS ServiceCount -- количество ремонтов
FROM [Bicycle] b
LEFT JOIN [RentBook] r ON b.Id = r.BicycleId AND r.Paid = 1
LEFT JOIN [ServiceBook] s ON b.Id = s.BicycleId
GROUP BY b.Id, b.Brand
ORDER BY NetProfit DESC;
GO
