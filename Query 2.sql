-- query 2
-- this table lists all the users who are family members
WITH FamilyMembers AS (
    SELECT
        DISTINCT ua.phone_number,
        rt.reid AS family_id
    FROM
        USER_ACCOUNT ua
        INNER JOIN USER_RELATIONSHIP ur ON (ua.Phone_Number = ur.Person1_Phone_Number OR ua.phone_number = ur.Person2_Phone_Number)
        INNER JOIN RELATIONSHIP_TYPE rt ON ur.reid = rt.reid
    WHERE
        rt.Type_of_Relationship = 'Family Member'
) ,

-- for each family, sum the total number of dine activities for each family member
TotalActivities_DINE AS (
    SELECT
        fm.family_id,
        COUNT(dr.Phone_Number)  AS num_dine
    FROM
        FamilyMembers fm
        LEFT JOIN Dine_record dr ON fm.Phone_Number = dr.Phone_Number
    GROUP BY
        fm.family_id
) ,

-- for each family, sum the total number of shop activities for each family member
TotalActivities_SHOP AS (
    SELECT
        fm.family_id,
		COUNT(sr.Phone_Number) AS num_shop
    FROM
        FamilyMembers fm
        LEFT JOIN Shop_record sr ON fm.Phone_Number = sr.Phone_Number
    GROUP BY
        fm.family_id
) ,

-- we sum up the dine and shop activiites for each family member
TotalActivities AS (
	SELECT 
		tad.family_id,
		tad.num_dine + tas.num_shop AS total_activities
	FROM TotalActivities_DINE tad
		FULL OUTER JOIN TotalActivities_SHOP tas ON tad.family_id = tas.family_id 
) ,

-- Calculate the size of each family
FamilySize AS (
    SELECT
        family_id,
        COUNT(*) AS total_members
    FROM
        FamilyMembers
    GROUP BY
        family_id
) ,

-- Count unique attendance of family members at each restaurant and time
DineAttendance AS (
    SELECT
        fm.family_id,
        dr.OID,
        dr.Date_Time_In,
        COUNT(DISTINCT fm.phone_number) AS numAttendees
    FROM
        dine_record dr
        JOIN FamilyMembers fm ON dr.phone_number = fm.phone_number
    GROUP BY
        fm.family_id, dr.OID, dr.Date_Time_In
) ,

-- Find dine records where attendance matches the family size (every single family member attended)
MatchingDineRecords AS (
    SELECT
        da.family_id,
        da.oid,
        da.date_time_in
    FROM
        DineAttendance da
        JOIN FamilySize fs ON da.family_id = fs.family_id
    WHERE
        da.numAttendees = fs.total_members
) ,

-- for each family, sum the total number of dine_records that all members attended (multiplies by size of family)
DineActivities_Together AS (
    SELECT
        mdr.family_id,
        COUNT(*) * fs.total_members AS countDine
    FROM
        MatchingDineRecords mdr
        INNER JOIN FamilySize fs ON mdr.family_id = fs.family_id
    GROUP BY
        mdr.family_id, fs.total_members
) ,

-- Count unique attendance of family members at each shop and time
ShopAttendance AS (
    SELECT
        fm.family_id,
        sr.sid,
        sr.date_time_in,
        COUNT(DISTINCT fm.phone_number) AS numAttendees
    FROM
        shop_record sr
        JOIN FamilyMembers fm ON sr.phone_number = fm.phone_number
    GROUP BY
        fm.family_id, sr.sid, sr.Date_time_in
) ,

-- Find shop records where attendance matches the family size (every single family member attended)
MatchingShopRecords AS (
    SELECT
        sa.family_id,
        sa.sid,
        sa.date_time_in
    FROM
        ShopAttendance sa
        JOIN FamilySize fs ON sa.family_id = fs.family_id
    WHERE
        sa.numAttendees = fs.total_members
) ,

-- for each family, sum the total number of shop_records that all members attended (multiplies by size of family)
ShopActivities_Together AS (
    SELECT
        msr.family_id,
        COUNT(*) * fs.total_members AS countShop
  FROM
        MatchingShopRecords msr
        INNER JOIN FamilySize fs ON msr.family_id = fs.family_id
    GROUP BY
        msr.family_id, fs.total_members
) ,

-- for each family, sum the total number of shop and dine activities that all members attended
TotalActivities_Together AS (
    SELECT 
        dat.family_id,
        countDine + countShop AS total_activities
    FROM 
        DineActivities_Together dat
        INNER JOIN ShopActivities_Together sat ON dat.family_id = sat.family_id
),

-- this table returns the families that shopped and dined frequently together
FrequentFamilies AS (
	SELECT TotalActivities_Together.family_id
	FROM TotalActivities_Together
	INNER JOIN TotalActivities ON TotalActivities_Together.family_id = TotalActivities.family_id
	WHERE TotalActivities_Together.total_activities * 2 > TotalActivities.total_activities
) ,

-- this table finds out the number of family members who signed up for day packages
FamilyPackages AS (
    SELECT fm.Phone_Number, fm.family_id, su.DID
    FROM FamilyMembers fm
    LEFT OUTER JOIN SIGN_UP su ON fm.Phone_Number = su.Phone_Number
) ,

-- this table finds out the 
CommonPackages AS (
    SELECT
        fp1.family_id,
        fp1.DID
    FROM
        FamilyPackages fp1
    GROUP BY
        fp1.family_id, fp1.did
    HAVING
        COUNT(DISTINCT fp1.Phone_Number) = (
            SELECT COUNT(DISTINCT Phone_Number) 
            FROM FamilyPackages fp3 
            WHERE fp3.family_id = fp1.family_id
        )
) ,

-- this table finds out the families that used day packages
FamilyUsedPackage AS(
    SELECT
        cp.family_id ,
        cp.did
    FROM
        CommonPackages cp
	WHERE cp.did IS NOT NULL
    GROUP BY
        cp.family_id, cp.did
)

-- this table finds out the frequent families who used day packages, and returns yes
-- for the frequent families who did not use day packages, it returns no
SELECT
    COALESCE(ff.family_id, fup.family_id) AS family_id,
    CASE
        WHEN fup.family_id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS 'does the family use day package'
FROM
    FrequentFamilies ff
FULL OUTER JOIN
    FamilyUsedPackage fup ON ff.family_id = fup.family_id;
