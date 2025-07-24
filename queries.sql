-- Данный запрос вполняет функцию подсчета 
--полей в столбце customer_id из таблицы customers
SELECT COUNT(customer_id) AS customers_count FROM customers;


-- запрос возвращает топ 10 работников 
--по критерию дохода, с указанием количества успешных сделок

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
ORDER BY FLOOR(SUM(s.quantity * p.price)) DESC
LIMIT 10;


-- запрос возвращает список работников, средний доход которых ниже уровня 
--среднего дохода среди всех работников
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
HAVING
    FLOOR(AVG(s.quantity * p.price))
    < (
        SELECT AVG(s2.quantity * p2.price)
        FROM sales AS s2
        LEFT JOIN products AS p2 ON s2.product_id = p2.product_id
    )
ORDER BY FLOOR(AVG(s.quantity * p.price)) ASC;


-- запрос возвращает суммарынй доход каждого сотрудника за каждый день недели
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
GROUP BY
    CONCAT(e.first_name, ' ', e.last_name),
    TO_CHAR(s.sale_date, 'day'),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date) ASC,
    CONCAT(e.first_name, ' ', e.last_name) ASC;

-- запрос, который возвращает количество клиентов в каждой возрастной категории
SELECT
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers AS c
GROUP BY
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
    END
ORDER BY
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
    END;


-- запрос возвращает колчисевто уникалных покупателей и общую выручку по месяцам
SELECT
    TO_CHAR(s.sale_date, 'yyyy-mm') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'yyyy-mm')
ORDER BY TO_CHAR(s.sale_date, 'yyyy-mm') ASC;


-- запрос возвращает список покупателей 
-- первая покупка которых пришлась на время акций
SELECT DISTINCT ON (s.customer_id)
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    (s.sale_date) AS sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM sales AS s
LEFT JOIN customers AS c
    ON s.customer_id = c.customer_id
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
WHERE p.price = 0
ORDER BY s.customer_id;
