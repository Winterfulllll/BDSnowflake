-- ============================================
-- DML: Populate snowflake schema from mock_data
-- ============================================

-- Level 2 dimensions

INSERT INTO dim_customer_location (country, postal_code)
SELECT DISTINCT customer_country, customer_postal_code
FROM mock_data;

INSERT INTO dim_seller_location (country, postal_code)
SELECT DISTINCT seller_country, seller_postal_code
FROM mock_data;

INSERT INTO dim_store_location (city, state, country)
SELECT DISTINCT store_city, store_state, store_country
FROM mock_data;

INSERT INTO dim_supplier_location (city, country)
SELECT DISTINCT supplier_city, supplier_country
FROM mock_data;

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL;

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL;

-- Level 1 dimensions

INSERT INTO dim_date (full_date, day, month, year, quarter, day_of_week)
SELECT DISTINCT
    TO_DATE(sale_date, 'MM/DD/YYYY'),
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INT,
    EXTRACT(ISODOW FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INT
FROM mock_data
WHERE sale_date IS NOT NULL;

INSERT INTO dim_customer (first_name, last_name, age, email, location_id, pet_type, pet_name, pet_breed)
SELECT DISTINCT ON (m.customer_first_name, m.customer_last_name, m.customer_email)
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    cl.location_id,
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed
FROM mock_data m
LEFT JOIN dim_customer_location cl
    ON m.customer_country IS NOT DISTINCT FROM cl.country
    AND m.customer_postal_code IS NOT DISTINCT FROM cl.postal_code;

INSERT INTO dim_seller (first_name, last_name, email, location_id)
SELECT DISTINCT ON (m.seller_first_name, m.seller_last_name, m.seller_email)
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    sl.location_id
FROM mock_data m
LEFT JOIN dim_seller_location sl
    ON m.seller_country IS NOT DISTINCT FROM sl.country
    AND m.seller_postal_code IS NOT DISTINCT FROM sl.postal_code;

INSERT INTO dim_product (name, category_id, brand_id, price, quantity, pet_category,
                         weight, color, size, material, description, rating, reviews,
                         release_date, expiry_date)
SELECT DISTINCT ON (m.product_name, m.product_category, m.product_brand, m.product_price,
                    m.product_color, m.product_size, m.product_material)
    m.product_name,
    pc.category_id,
    b.brand_id,
    m.product_price,
    m.product_quantity,
    m.pet_category,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    CASE WHEN m.product_release_date IS NOT NULL AND m.product_release_date != ''
         THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY') END,
    CASE WHEN m.product_expiry_date IS NOT NULL AND m.product_expiry_date != ''
         THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY') END
FROM mock_data m
LEFT JOIN dim_product_category pc ON m.product_category = pc.category_name
LEFT JOIN dim_brand b ON m.product_brand = b.brand_name;

INSERT INTO dim_store (name, location, location_id, phone, email)
SELECT DISTINCT ON (m.store_name, m.store_email)
    m.store_name,
    m.store_location,
    stl.location_id,
    m.store_phone,
    m.store_email
FROM mock_data m
LEFT JOIN dim_store_location stl
    ON m.store_city IS NOT DISTINCT FROM stl.city
    AND m.store_state IS NOT DISTINCT FROM stl.state
    AND m.store_country IS NOT DISTINCT FROM stl.country;

INSERT INTO dim_supplier (name, contact, email, phone, address, location_id)
SELECT DISTINCT ON (m.supplier_name, m.supplier_email)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    supl.location_id
FROM mock_data m
LEFT JOIN dim_supplier_location supl
    ON m.supplier_city IS NOT DISTINCT FROM supl.city
    AND m.supplier_country IS NOT DISTINCT FROM supl.country;

-- Fact table

INSERT INTO fact_sales (date_id, customer_id, seller_id, product_id, store_id, supplier_id,
                        sale_quantity, sale_total_price)
SELECT
    dd.date_id,
    dc.customer_id,
    ds.seller_id,
    dp.product_id,
    dst.store_id,
    dsup.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
LEFT JOIN dim_date dd
    ON dd.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
LEFT JOIN dim_customer dc
    ON m.customer_first_name IS NOT DISTINCT FROM dc.first_name
    AND m.customer_last_name IS NOT DISTINCT FROM dc.last_name
    AND m.customer_email IS NOT DISTINCT FROM dc.email
LEFT JOIN dim_seller ds
    ON m.seller_first_name IS NOT DISTINCT FROM ds.first_name
    AND m.seller_last_name IS NOT DISTINCT FROM ds.last_name
    AND m.seller_email IS NOT DISTINCT FROM ds.email
LEFT JOIN dim_product_category fpc ON m.product_category = fpc.category_name
LEFT JOIN dim_brand fb ON m.product_brand = fb.brand_name
LEFT JOIN dim_product dp
    ON m.product_name IS NOT DISTINCT FROM dp.name
    AND m.product_price IS NOT DISTINCT FROM dp.price
    AND m.product_color IS NOT DISTINCT FROM dp.color
    AND m.product_size IS NOT DISTINCT FROM dp.size
    AND m.product_material IS NOT DISTINCT FROM dp.material
    AND fpc.category_id IS NOT DISTINCT FROM dp.category_id
    AND fb.brand_id IS NOT DISTINCT FROM dp.brand_id
LEFT JOIN dim_store dst
    ON m.store_name IS NOT DISTINCT FROM dst.name
    AND m.store_email IS NOT DISTINCT FROM dst.email
LEFT JOIN dim_supplier dsup
    ON m.supplier_name IS NOT DISTINCT FROM dsup.name
    AND m.supplier_email IS NOT DISTINCT FROM dsup.email;
