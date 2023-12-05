/*=================================================
Queries
=================================================*/

-- Query 1: Get Inventory/Book Information
SELECT
    B.BOOK_TITLE AS "Title",
    A.AUTH_FNAME || ' ' || A.AUTH_LNAME AS "Author",
    G.PRIMARY_GENRE_NAME AS "Genre",
    P.PUBLISHER_NAME AS "Publisher",
    B.BOOK_ISBN AS "ISBN",
    B.BOOK_RELDATE AS "Date of Publication",
    COUNT(B.BOOK_ID) AS "Total Copies",
    SUM(CASE WHEN RD.RENTAL_RETURNED = 'N' THEN 1 ELSE 0 END) AS "Copies On Loan",
    SUM(CASE WHEN B.IN_CIRCULATION = 'N' THEN 1 ELSE 0 END) AS "Copies Lost"
FROM BOOK B
LEFT JOIN BOOK_AUTHOR BA ON B.BOOK_ID = BA.BOOK_ID
LEFT JOIN AUTHOR A ON BA.AUTH_ID = A.AUTH_ID
LEFT JOIN PRIMARY_GENRE G ON B.PRIMARY_GENRE_ID = G.PRIMARY_GENRE_ID
LEFT JOIN PUBLISHER P ON B.PUBLISHER_ID = P.PUBLISHER_ID
LEFT JOIN RENTAL_DETAIL RD ON B.BOOK_ID = RD.BOOK_ID
GROUP BY
    B.BOOK_TITLE,
    A.AUTH_FNAME,
    A.AUTH_LNAME,
    G.PRIMARY_GENRE_NAME,
    P.PUBLISHER_NAME,
    B.BOOK_ISBN,
    B.BOOK_RELDATE;
    
    
-- Query 2: Reporting Information

/*===========================================
Get info on books outstanding
============================================*/
SELECT 
    B.BOOK_TITLE,
    COUNT(RD.BOOK_ID) AS "Outstanding Count"
FROM 
    RENTAL_DETAIL RD
LEFT JOIN
    BOOK B ON RD.BOOK_ID = B.BOOK_ID
WHERE 
    RD.RENTAL_RETURN_DATE < CURRENT_DATE
    AND RD.RENTAL_RETURNED = 'N'
GROUP BY 
    B.BOOK_TITLE
ORDER BY 
    COUNT(RD.BOOK_ID) DESC;
    
    
/*===========================================
Get info on top ten books
============================================*/
SELECT
    B.BOOK_TITLE,
    COUNT(RD.BOOK_ID) AS "Loan Count"
FROM
    RENTAL_DETAIL RD
LEFT JOIN
    BOOK B ON RD.BOOK_ID = B.BOOK_ID
JOIN
    RENTAL R ON RD.RENTAL_ID = R.RENTAL_ID
WHERE
    R.RENTAL_DATE BETWEEN TO_DATE('2023-01-01', 'YYYY-MM-DD') AND TO_DATE('2023-12-31', 'YYYY-MM-DD')
    AND ROWNUM <=10
GROUP BY
    B.BOOK_TITLE
ORDER BY
    COUNT(RD.BOOK_ID) DESC;

-- Query 3: Member information
SELECT * FROM MEMBER_INFORMATION;


-- Query 4: Penalty fee information
SELECT MEMBER_NAME, "Total Amount Owed"
FROM MEMBER_INFORMATION
WHERE "Total Amount Owed" IS NOT NULL;


-- Query 5: Librarian information
SELECT 
STAFF_ID, STAFF_NAME, LIB_USERNAME AS "USERNAME", LIB_PASSWORD AS "PASSWORD", IS_ADMIN
FROM STAFF_INFORMATION
WHERE STAFF_TYPE = 'L';


-- Query 6: Author information
SELECT DISTINCT AUTHOR, COUNT(AUTHOR) AS "Number of books in library"
FROM BOOK_DETAILS
GROUP BY AUTHOR;


-- Query 7: Genre information
SELECT DISTINCT PRIMARY_GENRE_NAME, COUNT(PRIMARY_GENRE_NAME) AS "Number of books in library"
FROM BOOK_DETAILS
GROUP BY PRIMARY_GENRE_NAME;


-- Query 8: Reservation information
SELECT B.BOOK_TITLE, M.MEM_FNAME, R. RESERVATION_DATE
FROM reservation R
JOIN BOOK B on R.BOOK_ID = B.BOOK_ID
JOIN MEMBER M on R.MEM_ID = M.MEM_ID
WHERE RESERVATION_DATE > SYSDATE;


-- Query 9: Inventory Management query
SELECT * 
FROM BOOK 
WHERE UPPER(BOOK_TITLE) LIKE UPPER('%&Keyword%') OR BOOK_ID LIKE '%&Keyword%';



/*=================================================
Old Reports
=================================================*/

-- Show all books on record
SELECT B.BOOK_TITLE, A.AUTH_FNAME FROM 
    BOOK B
LEFT JOIN 
    BOOK_AUTHOR BA ON B.BOOK_ID = BA.BOOK_ID
LEFT JOIN 
    AUTHOR A ON BA.AUTH_ID = A.AUTH_ID;


-- Show all book information
SELECT
    B.BOOK_TITLE AS "Title",
    A.AUTH_FNAME || ' ' || A.AUTH_LNAME AS "Author",
    G.PRIMARY_GENRE_NAME AS "Genre",
    P.PUBLISHER_NAME AS "Publisher",
    B.BOOK_ISBN AS "ISBN",
    B.BOOK_RELDATE AS "Date of Publication",
    COUNT(B.BOOK_ID) AS "Total Copies",
    SUM(CASE WHEN RD.RENTAL_RETURNED = 'N' THEN 1 ELSE 0 END) AS "Copies On Loan",
    SUM(CASE WHEN B.IN_CIRCULATION = 'N' THEN 1 ELSE 0 END) AS "Copies Lost"
FROM
    BOOK B
LEFT JOIN
    BOOK_AUTHOR BA ON B.BOOK_ID = BA.BOOK_ID
LEFT JOIN
    AUTHOR A ON BA.AUTH_ID = A.AUTH_ID
LEFT JOIN
    PRIMARY_GENRE G ON B.PRIMARY_GENRE_ID = G.PRIMARY_GENRE_ID
LEFT JOIN
    PUBLISHER P ON B.PUBLISHER_ID = P.PUBLISHER_ID
LEFT JOIN
    RENTAL_DETAIL RD ON B.BOOK_ID = RD.BOOK_ID
GROUP BY
    B.BOOK_TITLE,
    A.AUTH_FNAME,
    A.AUTH_LNAME,
    G.PRIMARY_GENRE_NAME,
    P.PUBLISHER_NAME,
    B.BOOK_ISBN,
    B.BOOK_RELDATE;


-- Show Outstanding Books (Books out on loan after return date)
SELECT 
    B.BOOK_TITLE,
    COUNT(RD.BOOK_ID) AS "Outstanding Count"
FROM 
    RENTAL_DETAIL RD
LEFT JOIN
    BOOK B ON RD.BOOK_ID = B.BOOK_ID
WHERE 
    RD.RENTAL_RETURN_DATE < CURRENT_DATE
    AND RD.RENTAL_RETURNED = 'N'
GROUP BY 
    B.BOOK_TITLE
ORDER BY 
    COUNT(RD.BOOK_ID) DESC;


-- How many of each title is out on loan
SELECT
    B.BOOK_TITLE,
    COUNT(RD.BOOK_ID) AS "Loan Count"
FROM
    RENTAL_DETAIL RD
LEFT JOIN
    BOOK B ON RD.BOOK_ID = B.BOOK_ID
JOIN
    RENTAL R ON RD.RENTAL_ID = R.RENTAL_ID
WHERE
    R.RENTAL_DATE BETWEEN TO_DATE('2023-01-01', 'YYYY-MM-DD') AND TO_DATE('2023-12-31', 'YYYY-MM-DD')
    --AND ROWNUM <=3
GROUP BY
    B.BOOK_TITLE
ORDER BY
    COUNT(RD.BOOK_ID) DESC;


-- Fees owed for books
SELECT BF.FEE_NUM, BF.RENTAL_ID, BF.BOOK_ID, BF.FEE_AMOUNT
FROM BOOK_FEE BF
INNER JOIN RENTAL_DETAIL RD ON BF.RENTAL_ID = RD.RENTAL_ID AND BF.BOOK_ID = RD.BOOK_ID
WHERE BF.FEE_PAID = 'N' AND RD.RENTAL_RETURNED = 'N';


-- Shows current reservations
SELECT * FROM RESERVATION WHERE RESERVATIONDATE > SYSDATE;

-- Shows current reservations - Improved
SELECT
B.BOOK_TITLE, M.MEM_FNAME, R.reservationdate
FROM
reservation R
LEFT JOIN BOOK B on R.BOOK_ID = B.BOOK_ID
LEFT JOIN MEMBER M on R.MEM_ID = M.MEM_ID
WHERE
reservationdate > SYSDATE;


-- Displays the most rented (most popular) books
SELECT BOOK_ID, COUNT(*) AS TOTAL_RENTALS
FROM RENTAL_DETAIL
GROUP BY BOOK_ID
HAVING COUNT(*) < 1;


-- Displays books that have never been rented out
SELECT B.BOOK_TITLE, COUNT(*) AS TOTAL_RENTALS
FROM RENTAL_DETAIL RD
JOIN BOOK B ON RD.BOOK_ID = B.BOOK_ID
GROUP BY B.BOOK_TITLE
HAVING COUNT(*) < 1;


-- Displays staff information using view
SELECT * FROM STAFF_INFORMATION;


-- Displays member information using view
SELECT * FROM MEMBER_INFORMATION;


/*=================================================
Old Misc. Reports
=================================================*/

-- Search for a book
SELECT * FROM BOOK WHERE BOOK_TITLE LIKE '%&Keyword%' OR BOOK_ID LIKE '%&Keyword%';


SELECT ROUND(salary, 2) AS rounded_salary, TRUNC(salary) AS truncated_salary
FROM TECHNICAL_STAFF;


SELECT FEE_NUM, RENTAL_ID, BOOK_ID, ROUND(FEE_AMOUNT, 1) AS ROUNDED_FEE
FROM BOOK_FEE;


SELECT PRIMARY_GENRE_ID, COUNT(*) AS TOTAL_BOOKS
FROM BOOK
GROUP BY PRIMARY_GENRE_ID;


SELECT MEM_FNAME, MEM_LNAME
FROM MEMBER
WHERE MEM_ID IN (
    SELECT MEM_ID
    FROM RENTAL
    WHERE RENTAL_DATE >= (SELECT MAX(RENTAL_DATE) FROM RENTAL)
);