-- Данный запрос вполняет функцию подсчета полей в столбце customer_id из таблицы customers
select COUNT(customer_id) as customers_count from customers;


-- запрос возвращает топ 10 работников по критерию дохода, с указанием количества успешных сделок

select 
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	COUNT(s.sales_id) as operations,
	FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join employees as e
on s.sales_person_id = e.employee_id
left join products as p
on s.product_id = p.product_id
group by 1
order by 3 desc
limit 10;


-- запрос возвращает список работников, средний доход которых ниже уровня среднего дохода среди всех работников
select
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	FLOOR(AVG(s.quantity * p.price)) as average_income
from sales as s
left join employees as e
on s.sales_person_id = e.employee_id 
left join products as p
on s.product_id = p.product_id
group by 1
having FLOOR(AVG(s.quantity * p.price)) < (select avg(s2.quantity * p2.price) from sales as s2 left join products as p2 on s2.product_id = p2.product_id)
order by 2 asc;


-- запрос возвращает суммарынй доход каждого сотрудника за каждый день недели
select
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	TRIM(to_char( s.sale_date, 'Day')) as day_of_week,
	FLOOR(SUM(s.quantity * p.price))as income
from sales as s
left join products as p
on s.product_id = p.product_id
left join employees as e 
on s.sales_person_id = e.employee_id
group by 1, 2
order by MIN(extract(ISODOW from s.sale_date)) ASC, CONCAT(e.first_name, ' ', e.last_name) ASC;