/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM `Facilities`
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name)
FROM `Facilities`
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
    facid,
    name,
    membercost,
    monthlymaintenance
FROM `Facilities`
WHERE
    membercost > 0
    AND membercost <= (monthlymaintenance * 20%);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
    name,
    monthlymaintenance,
    CASE 
        WHEN monthlymaintenance > 100 
            THEN 'expensive'
    ELSE 'cheap' END AS cost
FROM `Facilities`;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM `Members`
WHERE joindate = 
    (
    SELECT MAX(joindate)
    FROM `Members`
    );

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 
    DISTINCT f.name, 
    m.firstname, 
    m.surname
FROM `Bookings` AS b
LEFT JOIN `Members` AS m
USING (memid)
LEFT JOIN `Facilities` AS f
USING (facid);

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
    f.name,
    CONCAT_WS(' ', m.firstname, m.surname) AS member_name,
    CASE
        WHEN b.memid = 0 THEN (b.slots * f.guestcost) 
        ELSE (b.slots * f.membercost) END AS cost
FROM `Bookings` AS b
LEFT JOIN `Members` AS m
USING (memid)
LEFT JOIN `Facilities` AS f
USING (facid)
WHERE DATE(b.starttime) = '2012-09-14'
HAVING cost > 30;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
    Sept14_2012_costs.name,
    CONCAT_WS(' ', m.firstname, m.surname) AS member_name,
    cost
FROM (
    SELECT
        b.memid,
        f.name,
        (CASE
        WHEN b.memid = 0 THEN (b.slots * f.guestcost) 
        ELSE (b.slots * f.membercost) 
        END) AS cost
    FROM `Bookings` AS b
    LEFT JOIN `Facilities` AS f
    USING (facid)
    WHERE DATE(b.starttime) = '2012-09-14'
    ) AS Sept14_2012_costs
LEFT JOIN `Members` AS m
USING (memid)
WHERE cost >30;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

import sqlite3
import pandas as pd
con = sqlite3.connect('sqlite_db_pythonsqlite.db')
queryq10 = """
SELECT
    f.name,
    SUM((CASE
    WHEN b.memid = 0 THEN (b.slots * f.guestcost) 
    ELSE (b.slots * f.membercost) 
    END)) AS revenue
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f
USING (facid)
GROUP BY f.name
"""
resultq10 = pd.read_sql(queryq10, con)
resultq10


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

import sqlite3
import pandas as pd
con = sqlite3.connect('sqlite_db_pythonsqlite.db')
queryq11 = """
SELECT 
    m1.memid,
    m1.surname, 
    m1.firstname,
    CASE WHEN m1.recommendedby IS NULL THEN "NONE"
        ELSE CONCAT(m2.firstname, ' ', m2.surname) 
        END AS RecommendedBy
FROM `Members` AS m1
LEFT JOIN `Members` AS m2 ON m1.recommendedby = m2.memid
ORDER BY m1.surname, m2.firstname
"""
resultq11 = pd.read_sql(queryq11, con)
resultq11

/* Q12: Find the facilities with their usage by member, but not guests */

import sqlite3
import pandas as pd
con = sqlite3.connect('sqlite_db_pythonsqlite.db')
queryq12 = """
SELECT
    f.name,
    CONCAT(m.firstname, ' ', m.surname) AS member,
    COUNT(b.bookid) AS times_used
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f
USING (facid)
LEFT JOIN `Members` AS m
USING (memid)
WHERE b.memid != 0
GROUP BY f.name, b.memid
"""
resultq12 = pd.read_sql(queryq12, con)
resultq12

/* Q13: Find the facilities usage by month, but not guests */

import sqlite3
import pandas as pd
con = sqlite3.connect('sqlite_db_pythonsqlite.db')
queryq13 = """
SELECT
    f.name,
    strftime('%m', b.starttime) AS month,
    COUNT(b.bookid) AS times_used
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f
USING (facid)
GROUP BY f.name, month
"""
resultq13 = pd.read_sql(queryq13, con)
resultq13