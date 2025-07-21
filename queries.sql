-- Данный запрос вполняет функцию подсчета 
--полей в столбце customer_id из таблицы customers
select COUNT(customer_id) as customers_count from customers;


-- запрос возвращает топ 10 работников 
--по критерию дохода, с указанием количества успешных сделок

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


-- запрос возвращает список работников, средний доход которых ниже уровня 
--среднего дохода среди всех работников
select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    FLOOR(AVG(s.quantity * p.price)) as average_income
from sales as s
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
group by 1
having
    FLOOR(AVG(s.quantity * p.price))
    < (
        select AVG(s2.quantity * p2.price)
        from sales as s2
        left join products as p2 on s2.product_id = p2.product_id
    )
order by 2 asc;


-- запрос возвращает суммарынй доход каждого сотрудника за каждый день недели
select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    TRIM(TO_CHAR(s.sale_date, 'day')) as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
left join employees as e
    on s.sales_person_id = e.employee_id
group by CONCAT(e.first_name, ' ', e.last_name)
order by
    MIN(EXTRACT(isodow from s.sale_date)) asc, 
    CONCAT(e.first_name, ' ', e.last_name) asc;

-- запрос, который возвращает количество клиентов в каждой возрастной категории
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        when c.age > 40 then '40+'
    end as age_category,
    COUNT(c.customer_id) as age_count
from customers as c
group by 1
order by 1;


-- запрос возвращает колчисевто уникалных покупателей и общую выручку по месяцам
select
    TRIM(TO_CHAR(s.sale_date, 'yyyy-mm')) as selling_month,
    COUNT(distinct s.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
group by 1
order by 1 asc;


-- запрос возвращает список покупателей 
-- первая покупка которых пришлась на время акций
select
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    MIN(s.sale_date) as sale_date,
    CONCAT(e.first_name, ' ', e.last_name) as seller
from (
    select distinct on (s.customer_id) *
    from sales as s
    order by s.customer_id, s.sale_date
) as s
left join customers as c
    on s.customer_id = c.customer_id
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
where p.price = 0
group by CONCAT(c.first_name, ' ', c.last_name), 
	s.customer_id, CONCAT(e.first_name, ' ', e.last_name)
order by s.customer_id;
