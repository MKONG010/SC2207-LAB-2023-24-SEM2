-- query 3
-- select the mall which has the maximum amount of recommendations
-- we inner join mall with restaurant outlet, as recommendation recommends an outlet, which belongs to a mall
SELECT DISTINCT m.MID
FROM MALL m
INNER JOIN RESTAURANT_OUTLET ro ON m.MID = ro.MID
WHERE (
    (SELECT COUNT (*)
    FROM RECOMMENDATION1 r
    WHERE r.OID = ro.OID)
    >= ALL (SELECT COUNT (*)
    FROM RECOMMENDATION1 r
    GROUP BY r.OID)
);