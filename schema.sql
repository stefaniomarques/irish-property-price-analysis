-- =========================================================
-- Irish Residential Property Price Register — Schema
-- Source: Property Services Regulatory Authority (PSRA)
-- =========================================================

CREATE DATABASE IF NOT EXISTS ppr_ireland
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ppr_ireland;

DROP TABLE IF EXISTS property_sales;

CREATE TABLE property_sales (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    date_of_sale                DATE NOT NULL,
    address                     VARCHAR(255) NOT NULL,
    county                      VARCHAR(50) NOT NULL,
    eircode                     VARCHAR(20),
    price                       DECIMAL(14,2) NOT NULL,
    not_full_market_price       TINYINT(1) NOT NULL DEFAULT 0,
    vat_exclusive               TINYINT(1) NOT NULL DEFAULT 0,
    property_description        VARCHAR(100),
    property_size_description   VARCHAR(255),

    INDEX idx_date (date_of_sale),
    INDEX idx_county (county),
    INDEX idx_price (price)
) ENGINE=InnoDB;

-- A view that standardises the New/Second-Hand flag (source data mixes
-- English and Irish-language descriptions) and flags likely bulk/portfolio
-- sales, which distort single-property price analysis if left in.
CREATE OR REPLACE VIEW property_sales_enriched AS
SELECT
    id,
    date_of_sale,
    YEAR(date_of_sale)  AS sale_year,
    QUARTER(date_of_sale) AS sale_quarter,
    address,
    county,
    eircode,
    price,
    not_full_market_price,
    vat_exclusive,
    property_description,
    CASE
        WHEN property_description LIKE 'New%' OR property_description LIKE 'Teach/%Nua%'
            THEN 'New'
        ELSE 'Second-Hand'
    END AS property_type,
    property_size_description,
    CASE WHEN price >= 5000000 THEN 1 ELSE 0 END AS likely_bulk_sale
FROM property_sales;
