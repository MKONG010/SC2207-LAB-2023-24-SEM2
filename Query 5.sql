-- query 5
WITH MALL_RESTAURANT AS(
    -- Count number of restaurants in each mall
    SELECT MID, COUNT(*) AS TOTAL_RESTAURANTS
    FROM RESTAURANT_OUTLET
    GROUP BY MID
), NUM_DISTINCT AS(
    --count # of distinct restaurants user visited by for each mall
    SELECT dr.Phone_Number, ro.MID, COUNT(DISTINCT ro.OID) AS VISITED_RESTAURANTS
    FROM DINE_RECORD AS dr
    LEFT JOIN RESTAURANT_OUTLET AS ro ON ro.OID = dr.OID
    GROUP BY dr.Phone_Number, ro.MID
), DINED_ALL AS (
    -- Check if user visited all restaurants in any mall
    SELECT nd.Phone_Number, nd.MID 
    FROM NUM_DISTINCT AS nd
    INNER JOIN MALL_RESTAURANT AS mr ON mr.MID = nd.MID AND nd.VISITED_RESTAURANTS = mr.TOTAL_RESTAURANTS
), NEVER_DINED AS (
    -- select users who has never visited any restaurants in a mall
    SELECT ua.Phone_Number, m.MID
    FROM USER_ACCOUNT ua
    CROSS JOIN MALL m
    WHERE NOT EXISTS (
        SELECT *
        FROM DINE_RECORD dr
        INNER JOIN RESTAURANT_OUTLET ro ON dr.OID = ro.OID
        WHERE ua.Phone_Number = dr.Phone_Number AND m.MID = ro.MID
    )
)
-- Query, based on users who has dined at all restaurants in one mall, but not in any restaurants in other mall
SELECT DISTINCT da.Phone_Number
FROM DINED_ALL da
JOIN NEVER_DINED nd ON da.Phone_Number = nd.Phone_Number
WHERE da.MID <> nd.MID;
