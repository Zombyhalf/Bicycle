-- ЗАПРОС 4: Популярность деталей в ремонтах
-- (какие детали чаще всего требуют замены)
SELECT 
    d.Type AS DetailType,
    d.Brand AS DetailBrand,
    d.Name AS DetailName,
    COUNT(sb.Id) AS UsageCount, -- количество использований
    SUM(sb.Price) AS TotalServiceRevenue, -- общий доход от ремонтов с этой деталью
    AVG(sb.Price) AS AvgServicePrice, -- средняя стоимость ремонта
    MIN(sb.ServiceDate) AS FirstUsage, -- первое использование
    MAX(sb.ServiceDate) AS LastUsage -- последнее использование
FROM [Detail] d
JOIN [ServiceBook] sb ON d.Id = sb.DetailId
GROUP BY d.Type, d.Brand, d.Name
ORDER BY UsageCount DESC;
GO
