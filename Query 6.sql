-- top 3 highest earning restaurant chains
SELECT TOP 3
ro.RID, SUM (dr.Amount_Spent) AS Total_Earning
FROM RESTAURANT_OUTLET ro
LEFT OUTER JOIN DINE_RECORD dr ON dr.OID = ro.OID
LEFT OUTER JOIN RESTAURANT_CHAIN rc ON rc.RID = ro.RID
GROUP BY ro.RID
ORDER BY Total_Earning DESC

-- top 3 highest earning malls (malls have both shops and restaurants)
WITH MALL_SHOP_EARNING AS (
  SELECT
    m.MID,
    COALESCE(SUM(sr.Amount_Spent), 0) AS Total_Earning
  FROM
    MALL m
    LEFT JOIN SHOP s ON s.MID = m.MID
    LEFT JOIN SHOP_RECORD sr ON sr.SID = s.SID
  GROUP BY
    m.MID
),

MALL_RESTAURANT_EARNING AS (
  SELECT
    m.MID,
    COALESCE(SUM(dr.Amount_Spent), 0) AS Total_Earning
  FROM
    MALL m
    LEFT JOIN RESTAURANT_OUTLET ro ON ro.MID = m.MID
    LEFT JOIN DINE_RECORD dr ON dr.OID = ro.OID
  GROUP BY
    m.MID
)

SELECT TOP 3
  mse.MID,
  mre.Total_Earning + mse.Total_Earning AS Total_Earnings
FROM
  MALL_SHOP_EARNING mse
  JOIN MALL_RESTAURANT_EARNING mre on mse.MID = mre.MID
ORDER BY
  Total_Earnings DESC

