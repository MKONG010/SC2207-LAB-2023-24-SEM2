-- query 4
-- we find out the users who shopped in malls during december 2023, and track the number of times they did
WITH VISITED_SHOPS_IN_MALLS AS
(SELECT U.Phone_Number, U.Name, U.DOB, SUM (sr.Amount_Spent) AS Total_Amount_Spent, COUNT(*) AS VISIT_COUNT, m.MID
FROM USER_ACCOUNT U
INNER JOIN SHOP_RECORD sr ON sr.Phone_Number = U.Phone_Number
INNER JOIN SHOP s ON s.SID = sr.SID
INNER JOIN MALL m ON m.MID = s.MID
WHERE sr.Date_time_in BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY U.Phone_Number, m.MID, U.Name, U.DOB
),

-- we find out the users who dined in malls during december 2023, and track the number of times they did
VISITED_RESTURANT_IN_MALLS AS
(SELECT U.Phone_Number, U.Name, U.DOB, SUM (dr.Amount_Spent) AS Total_Amount_Spent, COUNT(*) AS VISIT_COUNT, m.MID
FROM USER_ACCOUNT U
INNER JOIN DINE_RECORD dr ON dr.Phone_Number = U.Phone_Number
INNER JOIN RESTAURANT_OUTLET ro ON ro.OID = dr.OID
INNER JOIN MALL m ON m.MID = ro.MID
WHERE dr.Date_time_in BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY U.Phone_Number, m.MID, U.Name, U.DOB
)

-- finally, we find out the compulsive shoppers in malls during december 2023, sort by date of birth, and select the youngest
SELECT TOP 1
vr.Phone_Number, vr.Name, vr.DOB, vr.Total_Amount_Spent + vm.Total_Amount_Spent AS Total_Amount_Spent --, vr.VISIT_COUNT + vm.VISIT_COUNT AS Total_Visit_Count
FROM VISITED_RESTURANT_IN_MALLS vr
INNER JOIN VISITED_SHOPS_IN_MALLS vm ON (vr.Phone_Number = vm.Phone_Number AND vr.MID = vm.MID)
WHERE vr.VISIT_COUNT + vm.VISIT_COUNT > 5
ORDER BY vr.DOB DESC
