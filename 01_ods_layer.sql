"""Flask应用配置文件"""

class Config:
    SECRET_KEY = 'your-secret-key'

    # MySQL配置 - 远程Linux服务器
    MYSQL_HOST = '192.168.121.100'
    MYSQL_PORT = 3306
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = '123456'
    MYSQL_DATABASE = 'order_analysis'

    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:123456@192.168.121.100:3306/order_analysis?charset=utf8mb4'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
