-- ЗАПРОС 3: Анализ клиентов по странам
-- (общие затраты, количество аренд, средняя продолжительность)
-- Затрагивает 3 таблицы: Client, RentBook, Bicycle
SELECT 
    c.Country,
    COUNT(DISTINCT c.Id) AS ClientCount, -- количество клиентов
    COUNT(r.Id) AS TotalRents, -- всего аренд
    SUM(r.Time) AS TotalHours, -- всего часов аренды
    AVG(CAST(r.Time AS DECIMAL(10,2))) AS AvgHoursPerRent, -- среднее время аренды
    SUM(r.Time * b.RentPrice) AS TotalSpent, -- общая сумма
    AVG(r.Time * b.RentPrice) AS AvgSpentPerRent -- средний чек
FROM [Client] c
JOIN [RentBook] r ON c.Id = r.ClientId AND r.Paid = 1
JOIN [Bicycle] b ON r.BicycleId = b.Id
GROUP BY c.Country
ORDER BY TotalSpent DESC;
GO
