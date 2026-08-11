--  1. Блок, в якому визначається основна метрика accounts (account_cnt)
-- Підраховується кількість унікальних акаунтів (account_cnt) та групується за датою сесії, країною, інтервалом розсилки, а також статусами верифікації і відписки.
with account_tb as
(
  select
  s.date
  , sp.country
  , a.send_interval
  , a.is_verified
  , a.is_unsubscribed
  , count(distinct a.id) as account_cnt
  from data-analytics-mate.DA.account a
  join data-analytics-mate.DA.account_session sa on a.id = sa.account_id
  join data-analytics-mate.DA.session s          on sa.ga_session_id = s.ga_session_id
  join data-analytics-mate.DA.session_params sp  on s.ga_session_id = sp.ga_session_id
  group by 1, 2, 3, 4, 5
)
-- 2. Блок, в якому визначається основні метрики emails (sent_msg, open_msg, visit_msg) 
, emails_tb as
(
select
date_add(s.date, interval es.sent_date day) as date
 , sp.country
 , a.send_interval
 , a.is_verified
 , a.is_unsubscribed
 , count(distinct es.id_message) as sent_msg
 , count(distinct eo.id_message) as open_msg
 , count(distinct ev.id_message) as visit_msg
from data-analytics-mate.DA.email_sent es
join data-analytics-mate.DA.account a           on es.id_account = a.id
join data-analytics-mate.DA.account_session sa  on a.id = sa.account_id
join data-analytics-mate.DA.session s           on sa.ga_session_id = s.ga_session_id
join data-analytics-mate.DA.session_params sp   on s.ga_session_id = sp.ga_session_id
left join data-analytics-mate.DA.email_open eo  on es.id_message = eo.id_message
left join data-analytics-mate.DA.email_visit ev on es.id_message = ev.id_message
group by 1, 2, 3, 4, 5
)
-- 3. Блок, в якому об'єднуються дані з таблиць account_tb та emails_tb. Використовується union all для злиття даних в одну таблицю. Для метрик, що відсутні в конкретному блоці, підставляється значення 0 для забезпечення однорідності.
, data_aggregation as
(
  select
  date
 , country
 , send_interval
 , is_verified
 , is_unsubscribed
 , account_cnt
 , 0 as sent_msg
 , 0 as open_msg
 , 0 as visit_msg
 from account_tb
 union all
 select
  date
 , country
 , send_interval
 , is_verified
 , is_unsubscribed
 , 0 as account_cnt
 , sent_msg
 , open_msg
 , visit_msg
 from emails_tb
)
-- 4. Блок overall_metrics. Фінальна агрегація та розрахунок загальних підсумків. Спочатку підсумовуються щоденні метрики (акаунти, відправки, відкриття, візити). Далі за допомогою віконної функції (over partition by) розраховується загальна кількість акаунтів та відправлених листів для кожної країни (для подальшого ранжування).
, overall_metrics as
(
  select
 date
 , country
 , send_interval
 , is_verified
 , is_unsubscribed
 , sum(account_cnt) as account_cnt
 , sum(sent_msg) as sent_msg
 , sum(open_msg) as open_msg
 , sum(visit_msg) as visit_msg
 , sum(sum(account_cnt)) over(partition by country) as total_country_account_cnt
 , sum(sum(sent_msg)) over(partition by country) as total_country_sent_cnt
from data_aggregation
group by 1, 2, 3, 4, 5
)
-- 5. Блок final: Ранжування країн. Використовується функція dense_rank() для створення двох рейтингів: один — за загальною кількістю акаунтів, інший — за кількістю відправлених листів.
, final as
(
 select *
 , dense_rank() over(order by total_country_account_cnt desc) as rank_total_country_account_cnt
 , dense_rank() over(order by total_country_sent_cnt desc) as rank_total_country_sent_cnt
 from overall_metrics
)
-- 6. Фінальний запит + фільтрування. Залишаємо лише ті рядки, де країна входить у ТОП-10 за кількістю акаунтів АБО за кількістю відправок. 
select *
from final
where
  rank_total_country_account_cnt <= 10
  or rank_total_country_sent_cnt <= 10;
