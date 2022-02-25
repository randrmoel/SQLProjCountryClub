/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a PythON cONnectiON.

This is Tier 1 of the CASE study, which means that there'll be more guidance for you about how to 
setup your local SQLite cONnectiON in PART 2 of the CASE study. 

The questiONs in the CASE study are exactly the same AS with Tier 2. 

PART 1: PHPMyAdmin
You will complete questiONs 1-9 below in the PHPMyAdmin interface. 
Log in by pASting the following URL into your browser, and
using the following Username and PASsword:

URL: https://sql.springboard.com/
Username: student
PASsword: learn_sql@springboard

The data you need is in the "country_club" databASe. This databASe
cONtains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this CASE study, you'll be ASked a series of questiONs. You can
solve them using the platform, but for the final deliverable,
pASte the code for each solutiON into this script, and upload it
to your GitHub.

Before starting with the questiONs, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name FROM `Facilities` WHERE membercost = 0;
/*
name
Badminton Court
Table Tennis
Snooker Table
Pool Table
*/

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(name) FROM `Facilities` WHERE membercost = 0;
/*4*/

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
WHERE the fee is less than 20% of the facility's mONthly maintenance cost.
Return the facid, facility name, member cost, and mONthly maintenance of the
facilities in questiON. */

SELECT facid, name, membercost, monthlymaintenance 
FROM `Facilities`
WHERE membercost < .2 * monthlymaintenance AND membercost >0

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM `Facilities` 
WHERE facid IN (1,5);


/* Q5: Produce a list of facilities, with each labelled AS
'cheap' or 'expensive', depending ON if their mONthly maintenance cost is
more than $100. Return the name and mONthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
ELSE 'cheap' END AS cost_label
FROM `Facilities`;


/* Q6: You'd LIKE to get the first and lASt name of the lASt member(s)
who signed up. Try not to USE the LIMIT claUSE for your solutiON. */
WITH r AS (
SELECT RANK() OVER(ORDER BY joindate) AS joinrank, joindate FROM members
)
SELECT joindate, joinrank 
FROM r
WHERE joinrank = 1


/* Q7: Produce a list of all members who have USEd a tennis court.
Include in your output the name of the court, and the name of the member
formatted AS a single column. Ensure no duplicate data, and order by
the member name. */
USE countryclub;
SELECT distinct cONcat(m.firstname, " ", m.surname) AS `Member Name`, f.name
FROM bookings AS b
LEFT JOIN facilities AS f
ON b.facid = f.facid
LEFT JOIN members AS m
ON m.memid = b.memid
WHERE name LIKE "%Tennis Court%"
ORDER BY CONCAT(m.surname, m.firstname)  


/* Q8: Produce a list of bookings ON the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest USEr's ID is always 0. Include in your output the name of the
facility, the name of the member formatted AS a single column, and the cost.
Order by descending cost, and do not USE any subqueries. */

select case when m.memid =0 then 'Guest'
else concat(m.firstname, " ", m.surname) end as `Member Name`, f.name as `Facility Name`, 
case when b.memid = 0 then round(f.guestcost * b.slots,2)
else round(f.membercost * b.slots,2) end as `Booked Cost`  
from bookings as b
left join members as m
on m.memid = b.memid
left join facilities as f
on f.facid = b.facid
where 
case when b.memid = 0 then round(f.guestcost * b.slots,2)
else round(f.membercost * b.slots,2) end > 30 and left(starttime, 10) = '2012-09-14'
order by `Booked Cost` DESC; 

/* Q9: This time, produce the same result AS in Q8, but using a subquery. */
use countryclub;
with s as (
select case when m.memid =0 then 'Guest'
else concat(m.firstname, " ", m.surname) end as `Member Name`, f.name as `Facility Name`, 
case when b.memid = 0 then round(f.guestcost * b.slots,2)
else round(f.membercost * b.slots,2) end as `Booked Cost`,
LEFT(b.starttime,10) as `Booked Date`  
from bookings as b
left join members as m
on m.memid = b.memid
left join facilities as f
on f.facid = b.facid
)
select `Member Name`, `Facility Name`, `Booked Cost` 
from s
where `Booked Cost`>30 and `Booked Date` = '2012-09-14'
order by `Booked Cost` DESC; 


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database ON your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing these files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output FROM the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
with r as (
select f.name, 
case 
	when b.memid = 0 then f.guestcost * b.slots
    else f.membercost * b.slots end as fac_rev
from facilities as f
left join bookings as b
on f.facid = b.facid
)
select name, sum(fac_rev) as tot_rev
from r
group by name
having sum(fac_rev) < 1000
order by tot_rev
[('Table Tennis', 180), ('Snooker Table', 240), ('Pool Table', 270)]
1
​

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
select r.firstname||" "||r.surname as Recommndee, l.firstname||" "||l.surname as Recomender
from members as l
left join members as r
on l.memid = r.recommendedby
where r.recommendedby is not null and l.memid <> 0
order by r.surname||r.firstname
[('Florence Bader', 'Ponder Stibbons'), ('Anne Baker', 'Ponder Stibbons'), ('Timothy Baker', 'Jemima Farrell'), ('Tim Boothe', 'Tim Rownam'), ('Gerald Butters', 'Darren Smith'), ('Joan Coplin', 'Timothy Baker'), ('Erica Crumpet', 'Tracy Smith'), ('Nancy Dare', 'Janice Joplette'), ('Matthew Genting', 'Gerald Butters'), ('John Hunt', 'Millicent Purview'), ('David Jones', 'Janice Joplette'), ('Douglas Jones', 'David Jones'), ('Janice Joplette', 'Darren Smith'), ('Anna Mackenzie', 'Darren Smith'), ('Charles Owen', 'Darren Smith'), ('David Pinker', 'Jemima Farrell'), ('Millicent Purview', 'Tracy Smith'), ('Henrietta Rumney', 'Matthew Genting'), ('Ramnaresh Sarwin', 'Florence Bader'), ('Jack Smith', 'Darren Smith'), ('Ponder Stibbons', 'Burton Tracy'), ('Henry Worthington-Smyth', 'Tracy Smith')]

/* Q12: Find the facilities with their usage by member, but not guests */
select f.name, count(b.memid) as Useage
from bookings as b
left join facilities as f
on f.facid = b.facid
where b.memid <> 0
group by f.name
order by f.name
[('Badminton Court', 344), ('Massage Room 1', 421), ('Massage Room 2', 27), ('Pool Table', 783), ('Snooker Table', 421), ('Squash Court', 195), ('Table Tennis', 385), ('Tennis Court 1', 308), ('Tennis Court 2', 276)]


/* Q13: Find the facilities usage by month, but not guests */
select substr(b.starttime,1, 7) as `Year-Month`, count(b.memid) as Useage 
from bookings as b
left join facilities as f
on f.facid = b.facid
where b.memid <> 0
group by `Year-Month`
order by `Year-Month`
[('2012-07', 480), ('2012-08', 1168), ('2012-09', 1512)]

