-- ЗАПРОС 5: Анализ аренды по месяцам 2024 года
-- (сезонность спроса, выручка, количество аренд)
SELECT 
    YEAR(r.RentDate) AS Year,
    MONTH(r.RentDate) AS Month,
    DATENAME(MONTH, r.RentDate) AS MonthName,
    COUNT(r.Id) AS RentCount, -- количество аренд
    SUM(r.Time) AS TotalHours, -- всего часов
    SUM(r.Time * b.RentPrice) AS TotalRevenue, -- общая выручка
    AVG(r.Time * b.RentPrice) AS AvgRevenue, -- средний доход с аренды
    COUNT(DISTINCT r.ClientId) AS UniqueClients, -- уникальных клиентов
    COUNT(DISTINCT r.BicycleId) AS UniqueBicycles -- использованных велосипедов
FROM [RentBook] r
JOIN [Bicycle] b ON r.BicycleId = b.Id
WHERE r.Paid = 1 AND YEAR(r.RentDate) = 2024
GROUP BY YEAR(r.RentDate), MONTH(r.RentDate), DATENAME(MONTH, r.RentDate)
ORDER BY Year, Month;
GO
