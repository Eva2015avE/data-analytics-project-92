select COUNT(*) as customers_count
from customers;
--общее количество покупателей из таблицы customers, 
--результат возвращается в колонке customers_count.


select 
    CONCAT(employees.first_name, ' ', employees.last_name) as seller,
    COUNT(sales.sales_id) as operations,
    ROUND(SUM(products.price * sales.quantity)) as income
from
    sales 
    join employees  on  sales.sales_person_id = employees.employee_id
    join products  on sales.product_id = products.product_id
group by 
    employees.first_name, employees.last_name
order by 
    income desc
limit 10;
-- Топ-10 продавцов по суммарной выручке
-- Количество сделок и суммарная выручка для каждого продавца.


select 
    CONCAT(employees.first_name, ' ', employees.last_name) as seller,
    ROUND(AVG(products.price * sales.quantity)) as average_income --средняя выручка для каждого продавца
from 
    sales 
    join employees  on sales.sales_person_id = employees.employee_id
    join products  on sales.product_id = products.product_id
group by 
    employees.first_name, employees.last_name
having 
    AVG(products.price * sales.quantity) < (select AVG(products.price * sales.quantity)--общая средняя выручка
                                             from sales  
                                             join products  on sales.product_id = products.product_id)
order by 
    average_income asc;

--Продавцы, чья выручка ниже средней выручки всех продавцов



select
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    TO_CHAR(sales.sale_date, 'day') AS day_of_week,
    ROUND(SUM(products.price * sales.quantity)) AS income
from
    sales 
    join employees  on sales.sales_person_id = employees.employee_id
    join products  on sales.product_id = products.product_id
group by 
    employees.first_name, 
    employees.last_name, 
    TO_CHAR(sales.sale_date, 'day'), 
    extract(ISODOW from sales.sale_date)
order by 
    extract(ISODOW from sales.sale_date),  -- Сортировка по ISO дню недели (пн=1)
    employees.last_name,
    employees.first_name;
--Выручка по каждому продавцу и дню недели