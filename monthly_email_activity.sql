/*
=============================================================================
Проєкт: Аналіз щомісячної email-активності акаунтів
Опис: 
    Скрипт розраховує частку відправлених імейлів для кожного акаунта 
    від загальної кількості листів за місяць. Також визначаються дати 
    першого та останнього відправлення листа для акаунта в межах місяця.
    Особливість: всі розрахунки виконані виключно за допомогою віконних 
    функцій (Window Functions) без використання GROUP BY.
Технології: SQL (Window Functions, Subqueries, Date Functions)

Логіка:
    1. Використання підзапиту для розрахунку кількості повідомлень на рівні 
       акаунта та на рівні місяця (COUNT OVER PARTITION BY).
    2. Визначення першої та останньої дати відправки (MIN / MAX OVER).
    3. Розрахунок відсотка повідомлень для кожного акаунта у зовнішньому запиті.
=============================================================================
*/

select distinct
sent_month
, id_account
, round(cnt_mess_acc_month * 100.0 / cnt_mess_month, 3) as sent_msg_percent_from_this_month
, first_sent_date
, last_sent_date
from
(
select
date_trunc(date_add(s.date, interval es.sent_date day), month) as sent_month
, es.id_account
, count(es.id_message) over(partition by es.id_account, date_trunc(date_add(s.date, interval es.sent_date day), month)) as cnt_mess_acc_month
, count(es.id_message) over(partition by date_trunc(date_add(s.date, interval es.sent_date day), month)) as cnt_mess_month
, min(date_add(s.date, interval es.sent_date DAY))
  over(partition by es.id_account, date_trunc(date_add(s.date, interval es.sent_date day), month)) as first_sent_date
, max(date_add(s.date, interval es.sent_date DAY))
  over(partition by es.id_account, date_trunc(date_add(s.date, interval es.sent_date day), month)) as last_sent_date
from data-analytics-mate.DA.email_sent es
join data-analytics-mate.DA.account_session sa on es.id_account = sa.account_id
join data-analytics-mate.DA.session s          on sa.ga_session_id = s.ga_session_id
);
