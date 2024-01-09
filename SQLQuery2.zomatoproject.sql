--creating table goldusers signup

drop table if exists goldusers_signup

create table goldusers_signup (
userid int ,
signup_date date
)

Insert into goldusers_signup (userid  ,signup_date)
values (1,'09-22-2017'),(3,'04-21-2017')

select * from goldusers_signup


-- creating table users 

drop table if exists users

create table users( userid int, signup_date date)

insert into users( userid , signup_date )
values (1,'09-02-2014'),(2,'01-15-2015'),(3,'04-11-2014');

--creating table sales

drop table if exists sales

create table sales (userid int, created_date date, product_id int)

insert into sales( userid, created_date, product_id)
values (1,'04-19-2017',2),(3,'12-18-2019',1),(2,'07-20-2020',3),(1,'10-23-2019',2),
(1,'03-19-2018',3),(3,'12-20-2016',2), (1,'11-09-2016',1), (1,'05-20-2016',3),
(2,'09-24-2017',1), (1,'03-11-2017',2), (1,'03-11-2016',1), (3,'11-10-2016',1), 
(3,'12-07-2017',2), (3,'12-15-2016',2), (2,'11-08-2017',2),(2,'09-10-2018',3);


-- creating table product

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer);

INSERT INTO product(product_id,product_name,price)

VALUES(1,'p1',980),(2,'p2',870),(3,'p3',330);

--- tables
select * from goldusers_signup
select * from product
select * from sales
select * from users
----tables


-- what is the total amount each customer spent on zomato

select  sales.userid, SUM(product.price) as total_price
from sales
inner join product
on sales.product_id=product .product_id
group by sales.userid




--how many days has each customer visited zomato

select userid , COUNT(created_date)
from sales
group by userid

-- what was the first product purchased by each customer

select  sales.userid , sales.created_date
from sales
inner join users
on sales.userid = users.userid
where users.signup_date > 2014-09-02
order by sales.created_date asc 

-- which is the most purchased item in the menu and how many times was it purchased by all customers

select top 1 product_id,count(product_id) as most_purchased
from sales
group by product_id
order by most_purchased desc

-- which is the most purchased item in the menu and how many times was it purchased by each customers
select * from sales

select  userid, count(userid) no_purchased from sales where product_id = (
select top 1 product_id
from sales
group by product_id
order by count(product_id) desc)
group by userid

-- which item was the most popular for each customer

select * from (
select * , rank() over(partition by userid order by num desc)  rank_from 
from (select USERID,PRODUCT_ID,Count(product_id) num
from sales
group by product_id,userid ) a)b
where rank_from  = 1 

-- which item was purchased first after they became a member

select * from (
select * , RANK() over (partition by c.userid order by c.created_date asc ) as rnk from(
select a.userid,a.signup_date,b.created_date , b.product_id
from goldusers_signup a
inner join  sales b
on a.userid = b. userid 
where  created_date >= signup_date) c) d
where rnk  = 1 ;

--which item was purchased just before the customer became a memeber


select * from (
select * , RANK() over (partition by c.userid order by c.created_date desc ) as rnk from(
select a.userid,a.signup_date,b.created_date , b.product_id
from goldusers_signup a
inner join  sales b
on a.userid = b. userid 
where  created_date <= signup_date) c) d
where rnk  = 1 ;


--what is the total orders and amount spent for each member before they became a member 

select userid, COUNT(created_date) totalpurchase,SUM(price) totalprice from
(select a.userid,a.signup_date,b.created_date,b.product_id
from goldusers_signup a
inner join sales b on a.userid = b. userid) c 
inner join product p on c.product_id = p.product_id
where created_date < = signup_date
group by userid


/*If buying each product generates points for eg: p1 5rs = 1 zomato point, p2 10rs = 5 [ie; 2rs = 1]zomato point,
p3 5rs = 1 zomato point . Calculate points collected by each customer  */


select k.userid, sum(k.points) as total_points_collected from
(select h.* ,(h.totprice/h.amount) as points from
(select d.*, case 
when d.product_id = 1 then 5
when d.product_id = 2 then 2
when d.product_id = 3 then 5
else 0 
end as amount
from (select a.userid ,a.product_id, sum(a.price) as totprice from 
(select s.userid, s.product_id,p.price
from sales s
inner join product  p on  p.product_id = s.product_id) a
group by a.userid,a.product_id) d) h) k
group by k.userid 

/* In the first one year after the customer joins the gold program irresptive 
of what the customer has purchased they earn 5 zomato points for every 10rs they
spend . eho earned more points and what was their points earning in the first year */


select c.*,(price/10)*5 as points from 
(select a.userid,a.signup_date,b.created_date,b.product_id  
from goldusers_signup a
join sales b
on a.userid = b. userid
where  created_date >= signup_date and created_date <= DATEADD(YEAR,1,signup_date)) c
inner join product d on c.product_id = d.product_id


-- rank all the transaction of the customer

select * , rank() over(partition by userid order by created_date)  as rnk
from sales 

