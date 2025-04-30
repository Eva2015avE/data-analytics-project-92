select COUNT(*) as customers_count
from customers;
--общее количество покупателей из таблицы customers, 
--результат возвращается в колонке customers_count.


select 
    CONCAT(employees.first_name, ' ', employees.last_name) as seller,
    COUNT(sales.sales_id) as operations,
    FLOOR(SUM(products.price * sales.quantity)) as income
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
    FLOOR(AVG(products.price * sales.quantity)) as average_income --средняя выручка для каждого продавца
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
    employees.first_name || ' ' || employees.last_name as seller,
    LOWER(TO_CHAR(sales.sale_date, 'Day')) as day_of_week,
    FLOOR(SUM(products.price * sales.quantity)) as income -- расчет выручки
from
    sales 
join employees  on sales.sales_person_id = employees.employee_id
join products  on sales.product_id = products.product_id
group by 
    employees.first_name || ' ' || employees.last_name,
    TO_CHAR(sales.sale_date, 'Day'), -- возврацает название дня недели
    EXTRACT(ISODOW FROM sales.sale_date)
order by 
    EXTRACT(ISODOW FROM sales.sale_date), --сортировка по дням недели
    employees.first_name || ' ' || employees.last_name; -- сортировка по имени продавца
    
    --Отчет с данными по выручке по каждому продавцу и дню недели



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
    FLOOR(SUM(products.price * sales.quantity)) as income -- общая выручка 
from sales 
    join products on sales.product_id = products.product_id 
group by   TO_CHAR(sales.sale_date, 'YYYY-MM')  
order by selling_month;
--Количество покупателей и выручка по месяцам.




with first_offer_purchases as (
  select 
    customers.customer_id,
    CONCAT(customers.first_name,' ',  customers.last_name) as customer,-- используем конкатенацию для обьединения имени и фамилии 
    sales.sale_date,
    CONCAT(employees.first_name,  ' ' , employees.last_name) as seller,
    ROW_NUMBER() over (
      partition by customers.customer_id 
       order by sales.sale_date, customers.customer_id
    ) as purchase_rank
  from 
    sales 
    join customers  on sales.customer_id = customers.customer_id
    join employees  on sales.sales_person_id = employees.employee_id
    join products  on sales.product_id = products.product_id
  WHERE 
    products.price = 0
)
SELECT 
  customer,
  sale_date,
  seller
FROM 
  first_offer_purchases
WHERE 
  purchase_rank = 1
ORDER BY 
  customer_id;
-- Покупатели, первая покупка которых пришлась на время проведения специальных акций.