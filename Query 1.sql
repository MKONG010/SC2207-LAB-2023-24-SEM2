-- query 1
-- this table lists all day packages signed up by families and clubs and their corresponding number of signups
WITH VALID_DAY_PACKAGE AS
(SELECT DID, COUNT (Phone_Number) AS Num_sign_ups
FROM SIGN_UP su
INNER JOIN USER_RELATIONSHIP ur ON (
    su.Phone_Number = ur.Person1_Phone_Number 
    OR su.Phone_Number = ur.Person2_Phone_Number
)
WHERE ur.reid IN (
		SELECT reid
		FROM RELATIONSHIP_TYPE
		WHERE Type_of_Relationship LIKE '%Member'
		)
GROUP BY su.DID
HAVING COUNT (DISTINCT su.Phone_Number) = (
    SELECT COUNT (*)
    FROM SIGN_UP
    WHERE DID = su.DID
	)
)

-- we select the day package with the maximum number of signups
SELECT DID 
FROM VALID_DAY_PACKAGE
WHERE Num_sign_ups = (
    SELECT MAX(Num_sign_ups) 
    FROM VALID_DAY_PACKAGE
);