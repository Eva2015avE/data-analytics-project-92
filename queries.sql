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
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller, -- используем конкатенацию для обьединения имени и фамилии
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



select 
case when age between 16 and 25 then '16-25' -- создаем возростные группы
     when age between 26 and 40 then '26-40'
     else '40+'
end as age_category,
count(*) as age_count --  считаем кол-во покупателей в каждой группе 
from customers 
group by age_category
order by MIN(age); 
--Возростные группы покупателей



select 
    TO_CHAR(sales.sale_date, 'YYYY-MM') as selling_month, -- преобразуем дату в нужный формат
    COUNT(distinct sales.customer_id) as total_customers, --подсчитываем кол-во уникальных клиентов за месяц
    ROUND(SUM(products.price * sales.quantity)) as income -- общая выручка 
from sales 
    join products on sales.product_id = products.product_id 
group by   TO_CHAR(sales.sale_date, 'YYYY-MM')  
order by selling_month;
--Количество покупателей и выручка по месяцам.



select 
     CONCAT(customers.first_name,' ',  customers.last_name) as customer, -- используем конкатенацию для обьединения имени и фамилии 
     TO_CHAR (first_purchase.sale_date, 'YYYY-MM-DD') as sale_date, 
     CONCAT(employees.first_name,  ' ' , employees.last_name) as seller
from  customers
join (
    select sales.customer_id, sales.sales_person_id,
    MIN(sales.sale_date) as sale_date -- дата первой покупки
    from sales 
    join products on sales.product_id = products.product_id 
    where price = 0
    group by sales.customer_id, sales.sales_person_id) -- находим первую акционную покупку каждого покупателя
    first_purchase on  customers.customer_id = first_purchase.customer_id   
join employees on first_purchase.sales_person_id = employees.employee_id
order by customer;
-- Покупатели, первая покупка которых пришлась на время проведения специальных акций.