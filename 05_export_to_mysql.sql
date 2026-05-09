-- ODS层：原始数据层
-- 创建ODS数据库
CREATE DATABASE IF NOT EXISTS ods_db;
USE ods_db;

-- 创建ODS订单表（贴源表，保持与原始数据一致）
CREATE EXTERNAL TABLE IF NOT EXISTS ods_orders (
    order_id        STRING  COMMENT '订单ID',
    user_id         STRING  COMMENT '用户ID',
    product_id      STRING  COMMENT '产品ID',
    category        STRING  COMMENT '商品类别',
    price           DOUBLE  COMMENT '商品单价',
    quantity        INT     COMMENT '购买数量',
    order_date      STRING  COMMENT '订单日期',
    region          STRING  COMMENT '地区',
    payment_method  STRING  COMMENT '支付方式',
    status          STRING  COMMENT '订单状态'
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);

-- 从本地加载：
LOAD DATA LOCAL INPATH '/home/hive/data/orders.csv' OVERWRITE INTO TABLE ods_orders;

-- 验证数据
SELECT COUNT(*) AS total_records FROM ods_orders;
SELECT * FROM ods_orders LIMIT 10;
