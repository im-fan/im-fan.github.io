---
title: MySQL相关-常用命令
date: 2020-10-02 15:51:46
tags: 
- mysql
categories: 
- 存储
---

### 存储引擎区别

- 查看数据库支持的存储引擎
```sql
show engines;
```

类型 | 磁盘文件 | 特性 | 适用场景
---|--- | --- | --- |
FEDERATED||用来访问远程表存储引擎|访问远程表
MRG_MYISAM||把多个MyISAM表合并为一个逻辑单元；查询一个表时，相当与查询其所有成员表|可以用分区表替换merge表|
MyISAM|.MDY数据)<br/> .MYI(索引)|主要的非实物处理存储引擎|
BLACKHOLE||丢弃写操作，读操作返回空内容|
CSV|.CSV(数据)<br/>.CSM(元数据)|存储数据时，会以逗号作为数据项之间的分割符号|不支持索引，数据存在为普通文本文件
MEMORY||置于内存的表|
ARCHIVE||用于数据存档(行插入后不能再修改)|数据归档，大批量存储后不修改
InnoDB|.ibd(数据&索引)|具备外键支持功能的事务处理引擎|
PERFORMANCE_SCHEMA||用于监视MySQL服务器|
NDB||集群存储引擎||
|TokuDB||存储速度快，查询速度略慢与InnoDB,支持事务等，未来替代InnoDB|


### 建表语句
```sql
1.表结构完全复制
create table user_bak LIKE user;

2.使用某些字段建表
create table user_bak select now() as time ;

3.建表时字段值强制转换
create table user_bak select CAST('2019-8-01' as UNSIGNED) as time;

4.临时表
解释：只对当前会话有效，有同名表则原表隐藏不可见，会话结束自动清除
create temporary table user_bak  like user;
drop temporary table user_bak;
```

### Cast类型强制转换
```sql
语法: 
    Cast(字段名 as 转换的类型 )

支持的类型:
    CHAR[(N)] 字符型 
    DATE 日期型
    DATETIME 日期和时间型
    DECIMAL float型
    SIGNED int
    TIME 时间型

场景:
    1.解决utf8字符查询时传入表情符，导致报错；

```

### 新建分区表
- 示例
```sql
create table user_bak (
 id int(11) UNSIGNED AUTO_INCREMENT ,
 `name` varchar(200) DEFAULT null COMMENT '名称',
 rand_num int(11) DEFAULT NULL COMMENT '随机数',
 birthday datetime default null comment '生日',
 PRIMARY KEY (`id`,rand_num)
) ENGINE = INNODB partition by RANGE (rand_num)
(
	PARTITION p0 VALUES less THAN (20),
	PARTITION p1 VALUES less THAN (40),
	PARTITION p2 VALUES less THAN (60),
	PARTITION p3 VALUES less THAN (80),
	PARTITION p4 VALUES less THAN MAXVALUE
);
```

- 注意点

```textmate
1.PRIMARY必须包含分区的字段
2.不能单独创建分区，建表时就要创建
```

- 常见异常

```textmate
1.ERROR 1064  不能单独创建分区
解决：建表时就要把分区创建好

2.ERROR 1503 主键必须包含分区函数中所有列
解决：创建分区的字段必须放在主键索引中
```

### 子查询
```sql
-- 1.ALL - 查询返回单个结果,类似in操作
select * from user_bak where (id) 
>= ALL(select id from user_bak where id = 10)

-- 2.ANY & SUM -效果一样,类似or操作
select * from user_bak where (name,id) 
= SOME(select name,id from user_bak where id = 1 or name = 'eee')
```

### FullText全文搜索
- 全文搜索类型

```textmate
1.自然语言搜索-搜索包含匹配词的信息
2.布尔模式搜索-
3.查询扩展搜索
```
- 创建索引需要满足的条件

```textmate
1.表类型为MyISAM,version5.6以后引入了对InnoDB支持
2.字段类型只能是char/varchar/text类型
3.全文搜索会自动忽略掉常用词(在记录中出现几率为50%以上)-验证可以查出来
4.停用词会被过滤掉(the/after/other等)
5.少于4个字符会被忽略，查不出来(默认4-84个字符范围，可更改)
```

- 语法

```sql
-- 自然语言
select *,match(`name`) against('good boy') 
as 'percentage' from `user` where match(`name`) against('good boy');

-- 布尔模式
select *,match(`name`) against('good boy' in boolean MODE) as 'percentage' from `user` where match(`name`) against('good boy' in boolean MODE);

-- 内容顺序完全匹配
select *,match(`name`) against('"good boy"' in boolean MODE) as 'percentage' from `user` where match(`name`) against('"good boy"' in boolean MODE);

-- 扩展查询
select *,match(`name`) against('good boy' with query expansion) as 'percentage' from `user` where match(`name`) against('good boy'  with query expansion);
```

- 修改查询字符长度

```textmate
1.my.cnf文件中ft_min_word_len
2.重建FullText索引或者快速修复
repair table table_name quick;
```

## 字符集
### 有字符集有关的系统设置
```yaml
character_set_system 用于存储的字符集
character_set_server 服务器默认字符集
collation_server  系统排序规则
character_set_database 数据库字符集
collation_database  数据库排序规则
character_set_client 客户端向服务器发送SQL时使用的字符集
character_set_result 表示服务器返回结果时使用的字符集
character_set_connection 连接时使用的字符串
character_set_filesystem 文件系统字符集
```

### 空间值
```textmate
OpenGIS规范
point 类型值,只支持InnoDB/MyISAM/NDB/ARCHIVE引擎
point(xxxx,xxxx)
```

### 模糊匹配查询
```textmate
1.like
    % 匹配任意数量的字符序列
    _ 只能匹配单个字符
    \%  \_  转义
2.REGEXP-正则查询

```

### 新建用户后授权
```sql
-- %表示所有IP可连接
CREATE USER `用户名`@`%` IDENTIFIED BY '密码';
grant all privileges on jwgateway.* to '用户名'@'%' identified by '密码';
select * from mysql.user;
```

### 判断时间与已有记录是否重叠
```sql
-- 1.方法一
SELECT * FROM test_table
WHERE (start_time >= startT AND start_time < endT)
   OR (start_time <= startT AND end_time > endT)
   OR (end_time >= startT AND end_time < endT)

-- 2.方法二
SELECT * FROM test_table WHERE NOT ( (end_time < startT OR (start_time > endT) )
```
