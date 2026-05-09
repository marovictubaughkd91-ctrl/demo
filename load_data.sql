-- DWS层：数据服务层

-- 创建DWS数据库
CREATE DATABASE IF NOT EXISTS dws_db;
USE dws_db;

-- 1. 地区维度汇总表
CREATE TABLE IF NOT EXISTS dws_region_sales (
    region            STRING  COMMENT '地区',
    total_orders      BIGINT  COMMENT '订单总数',
    total_amount      DOUBLE  COMMENT '销售总金额',
    total_quantity    BIGINT  COMMENT '销售总数量',
    avg_order_amount  DOUBLE  COMMENT '平均订单金额',
    completed_orders  BIGINT  COMMENT '已完成订单数',
    cancelled_orders  BIGINT  COMMENT '已取消订单数',
    refunded_orders   BIGINT  COMMENT '已退款订单数'
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_region_sales
SELECT
    region,
    COUNT(*)                                                     AS total_orders,
    ROUND(SUM(amount), 2)                                        AS total_amount,
    SUM(quantity)                                                 AS total_quantity,
    ROUND(AVG(amount), 2)                                        AS avg_order_amount,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)       AS completed_orders,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)       AS cancelled_orders,
    SUM(CASE WHEN status = 'refunded' THEN 1 ELSE 0 END)        AS refunded_orders
FROM dwd_db.dwd_orders
GROUP BY region;

-- 2. 品类维度汇总表
CREATE TABLE IF NOT EXISTS dws_category_sales (
    category          STRING  COMMENT '商品类别',
    total_orders      BIGINT  COMMENT '订单总数',
    total_amount      DOUBLE  COMMENT '销售总金额',
    total_quantity    BIGINT  COMMENT '销售总数量',
    avg_order_amount  DOUBLE  COMMENT '平均订单金额',
    avg_price         DOUBLE  COMMENT '平均商品单价',
    completed_orders  BIGINT  COMMENT '已完成订单数'
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_category_sales
SELECT
    category,
    COUNT(*)                                                     AS total_orders,
    ROUND(SUM(amount), 2)                                        AS total_amount,
    SUM(quantity)                                                 AS total_quantity,
    ROUND(AVG(amount), 2)                                        AS avg_order_amount,
    ROUND(AVG(price), 2)                                         AS avg_price,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)       AS completed_orders
FROM dwd_db.dwd_orders
GROUP BY category;

-- 3. 支付方式维度汇总表
CREATE TABLE IF NOT EXISTS dws_payment_sales (
    payment_method    STRING  COMMENT '支付方式',
    total_orders      BIGINT  COMMENT '订单总数',
    total_amount      DOUBLE  COMMENT '销售总金额',
    avg_order_amount  DOUBLE  COMMENT '平均订单金额',
    completed_orders  BIGINT  COMMENT '已完成订单数',
    completed_rate    DOUBLE  COMMENT '完成率(%)'
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_payment_sales
SELECT
    payment_method,
    COUNT(*)                                                     AS total_orders,
    ROUND(SUM(amount), 2)                                        AS total_amount,
    ROUND(AVG(amount), 2)                                        AS avg_order_amount,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)       AS completed_orders,
    ROUND(
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2)                                                           AS completed_rate
FROM dwd_db.dwd_orders
GROUP BY payment_method;

-- 4. 月度维度汇总表
CREATE TABLE IF NOT EXISTS dws_monthly_sales (
    order_yearmonth   STRING  COMMENT '年月(yyyy-MM)',
    order_year        INT     COMMENT '年份',
    order_month       INT     COMMENT '月份',
    total_orders      BIGINT  COMMENT '订单总数',
    total_amount      DOUBLE  COMMENT '销售总金额',
    total_quantity    BIGINT  COMMENT '销售总数量',
    avg_order_amount  DOUBLE  COMMENT '平均订单金额',
    completed_orders  BIGINT  COMMENT '已完成订单数'
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_monthly_sales
SELECT
    order_yearmonth,
    order_year,
    order_month,
    COUNT(*)                                                     AS total_orders,
    ROUND(SUM(amount), 2)                                        AS total_amount,
    SUM(quantity)                                                 AS total_quantity,
    ROUND(AVG(amount), 2)                                        AS avg_order_amount,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)       AS completed_orders
FROM dwd_db.dwd_orders
GROUP BY order_yearmonth, order_year, order_month;

-- 5. 订单状态维度汇总表
CREATE TABLE IF NOT EXISTS dws_status_stats (
    status            STRING  COMMENT '订单状态',
    total_orders      BIGINT  COMMENT '订单总数',
    total_amount      DOUBLE  COMMENT '涉及金额',
    total_quantity    BIGINT  COMMENT '涉及数量',
    avg_order_amount  DOUBLE  COMMENT '平均订单金额'
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_status_stats
SELECT
    status,
    COUNT(*)              AS total_orders,
    ROUND(SUM(amount), 2) AS total_amount,
    SUM(quantity)          AS total_quantity,
    ROUND(AVG(amount), 2) AS avg_order_amount
FROM dwd_db.dwd_orders
GROUP BY status;

-- 验证
SELECT 'dws_region_sales' AS tbl, COUNT(*) AS cnt FROM dws_region_sales
UNION ALL
SELECT 'dws_category_sales', COUNT(*) FROM dws_category_sales
UNION ALL
SELECT 'dws_payment_sales', COUNT(*) FROM dws_payment_sales
UNION ALL
SELECT 'dws_monthly_sales', COUNT(*) FROM dws_monthly_sales
UNION ALL
SELECT 'dws_status_stats', COUNT(*) FROM dws_status_stats;
