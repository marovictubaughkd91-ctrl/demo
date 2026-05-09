-- DWD层：数据明细层（清洗、规范化）

-- 创建DWD数据库
CREATE DATABASE IF NOT EXISTS dwd_db;
USE dwd_db;

-- 创建DWD订单明细表
CREATE TABLE IF NOT EXISTS dwd_orders (
    order_id        STRING    COMMENT '订单ID',
    user_id         STRING    COMMENT '用户ID',
    product_id      STRING    COMMENT '产品ID',
    category        STRING    COMMENT '商品类别',
    price           DOUBLE    COMMENT '商品单价',
    quantity        INT       COMMENT '购买数量',
    order_date      DATE      COMMENT '订单日期',
    order_year      INT       COMMENT '订单年份',
    order_month     INT       COMMENT '订单月份',
    order_yearmonth STRING    COMMENT '订单年月(yyyy-MM)',
    region          STRING    COMMENT '地区',
    payment_method  STRING    COMMENT '支付方式',
    status          STRING    COMMENT '订单状态',
    amount          DOUBLE    COMMENT '订单金额(单价*数量)',
    etl_date        DATE      COMMENT 'ETL处理日期'
)
STORED AS ORC;

-- 插入数据，进行清洗和规范
INSERT OVERWRITE TABLE dwd_orders
SELECT
    order_id,
    user_id,
    product_id,
    -- 类别标准化（去空格）
    TRIM(category)                                                     AS category,
    -- 价格清洗（过滤负数和空值，设为0）
    CASE WHEN price IS NULL OR price < 0 THEN 0 ELSE price END         AS price,
    -- 数量清洗（过滤负数和空值，设为0）
    CASE WHEN quantity IS NULL OR quantity < 0 THEN 0 ELSE quantity END AS quantity,
    -- 日期规范化
    TO_DATE(order_date)                                                AS order_date,
    YEAR(TO_DATE(order_date))                                          AS order_year,
    MONTH(TO_DATE(order_date))                                         AS order_month,
    SUBSTR(order_date, 1, 7)                                           AS order_yearmonth,
    -- 地区标准化
    TRIM(region)                                                       AS region,
    -- 支付方式标准化
    TRIM(payment_method)                                               AS payment_method,
    -- 状态标准化
    TRIM(status)                                                       AS status,
    -- 计算订单金额
    CASE
        WHEN price IS NULL OR quantity IS NULL OR price < 0 OR quantity < 0
        THEN 0
        ELSE price * quantity
    END                                                                 AS amount,
    CURRENT_DATE()                                                      AS etl_date
FROM ods_db.ods_orders
WHERE
    -- 过滤空记录
    order_id IS NOT NULL
    AND TRIM(order_id) != ''
    AND user_id IS NOT NULL
    AND TRIM(user_id) != ''
    AND order_date IS NOT NULL
    AND TRIM(order_date) != ''
    -- 去重（按order_id去重，保留最新记录）
    AND order_id IN (
        SELECT order_id
        FROM (
            SELECT order_id,
                   ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date DESC) AS rn
            FROM ods_db.ods_orders
            WHERE order_id IS NOT NULL AND TRIM(order_id) != ''
        ) t
        WHERE rn = 1
    );

-- 验证数据
SELECT COUNT(*) AS total_records FROM dwd_orders;
SELECT * FROM dwd_orders LIMIT 10;
