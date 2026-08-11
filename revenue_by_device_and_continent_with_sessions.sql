/*
=============================================================================
Проєкт: Аналіз доходу за континентами та пристроями
Опис: 
    Скрипт агрегує дані про продажі, розподіляючи дохід за континентами 
    та типами пристроїв (Mobile vs Desktop). Додатково розраховується 
    частка доходу кожного континенту від загального показника, а також 
    кількість унікальних акаунтів, верифікованих користувачів та сесій.
Технології: BigQuery SQL (CTEs, Conditional Aggregation, Window Functions, JOINs)

Логіка:
    1. CTE `table_1`: Розрахунок загального доходу та доходу за типами 
       пристроїв (через SUM + CASE WHEN) у розрізі континентів.
    2. CTE `table_2`: Обчислення відсотка доходу кожного континенту 
       від глобального доходу (через Window Function OVER()).
    3. CTE `table_3`: Підрахунок кількості сесій та унікальних/верифікованих 
       акаунтів (через COUNT DISTINCT + CASE WHEN).
    4. Фінальний запит: Об'єднання всіх метрик в одну вітрину даних.
=============================================================================
*/

with table_1 as
(
select
sp.continent as Continent
, round(sum(p.price), 2) as Revenue
, round(sum(case when sp.device = 'mobile' then p.price else 0 end), 2) as `Revenue from Mobile`
, round(sum(case when sp.device = 'desktop' then p.price else 0 end), 2) as `Revenue from Desktop`
from data-analytics-mate.DA.order o
join data-analytics-mate.DA.product p          on o.item_id = p.item_id
join data-analytics-mate.DA.session_params sp  on o.ga_session_id = sp.ga_session_id
group by 1
order by 2 desc
)
, table_2 as
(
select
Continent
 ,round(Revenue * 100.0 / sum(Revenue) over(), 2) as `% Revenue from Total`
from table_1
)
, table_3 as
(
  select
sp.continent as Continent
, count(distinct a.id) as `Account Count`
, count(distinct case when a.is_verified = 1 then a.id else 0 end) as `Verified Account`
, count(distinct sp.ga_session_id) as `Session Count`
from data-analytics-mate.DA.session_params sp
left join data-analytics-mate.DA.account_session sa on sp.ga_session_id = sa.ga_session_id
left join data-analytics-mate.DA.account a                on sa.account_id = a.id
group by 1
)
select
t1.Continent
, t1.Revenue
, t1.`Revenue from Mobile`
, t1.`Revenue from Desktop`
, t2.`% Revenue from Total`
, t3.`Account Count`
, t3.`Verified Account`
, t3.`Session Count`
from table_1 t1
join table_2 t2 on t1.Continent = t2.Continent
join table_3 t3 on t1.Continent = t3.Continent
order by 5 desc;
