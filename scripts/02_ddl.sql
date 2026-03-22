-- ============================================
-- DDL: Snowflake schema for pet store data
-- ============================================

-- Level 2 dimensions (snowflake normalization)

CREATE TABLE dim_customer_location (
    location_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_seller_location (
    location_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_store_location (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_supplier_location (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_product_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE dim_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100)
);

-- Level 1 dimensions

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    day INT,
    month INT,
    year INT,
    quarter INT,
    day_of_week INT
);

CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INT,
    email VARCHAR(255),
    location_id INT REFERENCES dim_customer_location(location_id),
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100)
);

CREATE TABLE dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    location_id INT REFERENCES dim_seller_location(location_id)
);

CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category_id INT REFERENCES dim_product_category(category_id),
    brand_id INT REFERENCES dim_brand(brand_id),
    price DECIMAL(10,2),
    quantity INT,
    pet_category VARCHAR(50),
    weight DECIMAL(10,2),
    color VARCHAR(50),
    size VARCHAR(20),
    material VARCHAR(100),
    description TEXT,
    rating DECIMAL(3,1),
    reviews INT,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    location VARCHAR(255),
    location_id INT REFERENCES dim_store_location(location_id),
    phone VARCHAR(50),
    email VARCHAR(255)
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    contact VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    location_id INT REFERENCES dim_supplier_location(location_id)
);

-- Fact table

CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    date_id INT REFERENCES dim_date(date_id),
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    product_id INT REFERENCES dim_product(product_id),
    store_id INT REFERENCES dim_store(store_id),
    supplier_id INT REFERENCES dim_supplier(supplier_id),
    sale_quantity INT,
    sale_total_price DECIMAL(10,2)
);
