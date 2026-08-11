# SQL-database-queries
Цей репозиторій містить приклади моїх робіт з аналізу даних за допомогою SQL. Мета цих скриптів — демонстрація навичок написання запитів для вирішення наближених до реальності задач.
## Перелік завдань та скриптів

### [1. Email Campaign & Account Analytics](marketing_campaign_analytics.sql)
- **Опис:** Запит, який демонструє дані, що допоможуть аналізувати динаміку створення акаунтів, активність користувачів за листами (відправлення, відкриття, переходи), а також оцінювати поведінку в категоріях, таких як інтервал відправлення, верифікація акаунтів і статус підписки. Дані дозволять порівнювати активність між країнами, визначати ключові ринки, сегментувати користувачів за різними параметрами.
- **Використані навички:** `CTEs`, `Window Functions` (DENSE_RANK, PARTITION BY), `UNION ALL`, `JOIN`.
- **Файл:** [marketing_campaign_analytics.sql](marketing_campaign_analytics.sql)

### [2. Monthly Email Activity Analysis](monthly_email_activity.sql)
- **Опис:** Аналіз щомісячної email-активності користувачів. Скрипт розраховує частку отриманих листів для кожного акаунта від загального місячного обсягу, а також визначає дати першої та останньої взаємодії. Всі розрахунки виконані виключно через віконні функції без використання стандартного групування.
- **Використані навички:** Просунуті `Window Functions` (COUNT, MIN, MAX OVER PARTITION BY), `Subqueries`, робота з датами (`DATE_TRUNC`, `DATE_ADD`).
- **Файл:** [monthly_email_activity.sql](monthly_email_activity.sql)

### [3. Revenue by Device and Continent with Sessions](revenue_by_device_and_continent_with_sessions.sql)
- **Опис:** Створення зведеної вітрини даних для аналізу доходів. Скрипт агрегує продажі за континентами та типами пристроїв, обчислює частку доходу кожного регіону, а також підраховує кількість сесій та верифікованих акаунтів.
- **Використані навички:** `Conditional Aggregation` (CASE WHEN всередині SUM/COUNT), `CTEs`, `Window Functions` (OVER), багаторазові `JOIN`.
- **Файл:** [revenue_by_device_and_continent.sql](revenue_by_device_and_continent_with_sessions.sql)
