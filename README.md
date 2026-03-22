# BigDataSnowflake

Лабораторная работа №1 — нормализация данных о продажах зоомагазина в модель «снежинка».

Описание задания: [TASK.md](TASK.md)

## Структура проекта

```
├── docker-compose.yml           # PostgreSQL 16 в Docker
├── исходные данные/             # 10 CSV-файлов (MOCK_DATA), 10 000 строк
├── scripts/
│   ├── 01_init.sql              # Staging-таблица mock_data + импорт CSV
│   ├── 02_ddl.sql               # DDL: таблицы фактов и измерений (снежинка)
│   └── 03_dml.sql               # DML: заполнение таблиц из mock_data
├── TASK.md                      # Описание задания
└── README.md
```

## Схема «снежинка»

```
fact_sales
├── dim_date
├── dim_customer
│   └── dim_customer_location
├── dim_seller
│   └── dim_seller_location
├── dim_product
│   ├── dim_product_category
│   └── dim_brand
├── dim_store
│   └── dim_store_location
└── dim_supplier
    └── dim_supplier_location
```

**Факт:** `fact_sales` — каждая строка соответствует продаже (количество, сумма).

**Измерения 1-го уровня:** `dim_date`, `dim_customer`, `dim_seller`, `dim_product`, `dim_store`, `dim_supplier`.

**Измерения 2-го уровня (снежинка):** `dim_customer_location`, `dim_seller_location`, `dim_store_location`, `dim_supplier_location`, `dim_product_category`, `dim_brand`.

## Запуск

Требования: Docker и Docker Compose.

```bash
# Запуск PostgreSQL + автоматический импорт данных и создание схемы
docker compose up -d

# Проверка логов (убедиться, что инициализация завершена)
docker compose logs -f postgres
```

При первом запуске контейнер автоматически:

1. Создаёт staging-таблицу `mock_data` и импортирует все 10 CSV-файлов (10 000 строк).
2. Создаёт таблицы фактов и измерений по схеме «снежинка».
3. Заполняет таблицы данными из `mock_data`.

## Подключение к БД

```
Host:     localhost
Port:     5432
Database: pet_store
User:     postgres
Password: postgres
```

```bash
# Через psql
docker exec -it bd_snowflake_db psql -U postgres -d pet_store

# Проверка количества строк
SELECT COUNT(*) FROM mock_data;        -- 10 000
SELECT COUNT(*) FROM fact_sales;       -- 10 000
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_product;
```

## Остановка и очистка

```bash
# Остановка
docker compose down

# Остановка с удалением данных (для повторной инициализации)
docker compose down -v
```
