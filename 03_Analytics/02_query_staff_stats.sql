-- ЗАПРОС 2: Статистика по сотрудникам
-- (выручка от аренды и доход от ремонтов за всё время)
-- Затрагивает 3 таблицы: Staff, RentBook, ServiceBook
SELECT 
    st.Id AS StaffId,
    st.Name AS StaffName,
    DATEDIFF(YEAR, st.HireDate, GETDATE()) AS YearsWorked, -- стаж работы
    ISNULL(SUM(r.Time * b.RentPrice), 0) AS RentRevenue, -- выручка от аренды
    COUNT(DISTINCT r.Id) AS RentTransactions, -- количество транзакций аренды
    ISNULL(SUM(sb.Price), 0) AS ServiceRevenue, -- доход от ремонтов
    COUNT(DISTINCT sb.Id) AS ServiceTransactions, -- количество ремонтов
    ISNULL(SUM(r.Time * b.RentPrice), 0) + ISNULL(SUM(sb.Price), 0) AS TotalRevenue -- общая выручка
FROM [Staff] st
LEFT JOIN [RentBook] r ON st.Id = r.StaffId AND r.Paid = 1
LEFT JOIN [Bicycle] b ON r.BicycleId = b.Id
LEFT JOIN [ServiceBook] sb ON st.Id = sb.StaffId
GROUP BY st.Id, st.Name, st.HireDate
ORDER BY TotalRevenue DESC;
GO
