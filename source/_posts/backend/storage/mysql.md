---
title: MySQL相关知识
date: 2021-07-20 09:45:00
tags:
- mysql

categories:
- 存储
---

### Innodb引擎的4大特性
> [参考文档](https://www.cnblogs.com/zhs0/p/10528520.html)
- 插入缓冲
- 二次写
- 自适应哈希
- 预读

#### 插入缓冲
```textmate
用于提升插入性能，分为Insert Buffer、Change Buffer
change buffering是insert buffer的加强，insert buffer只针对insert有效，change buffering对insert、delete、update(delete+insert)、purge都有效

使用插入缓冲的条件：
* 非聚集索引
* 非唯一索引
```

#### 事务
- 事务的特性ACID
```textmate
原子性(atomicity)：一个事务被事务不可分割的最小工作单元，要么全部提交，要么全部失败回滚。
一致性(consistency)：数据库总是从一致性状态到另一个一致性状态，它只包含成功事务提交的结果
隔离型(isolation)：事务所做的修改在最终提交一起，对其他事务是不可见的
持久性(durability)：一旦事务提交，则其所做的修改就会永久保存到数据库中。
```

- 事务隔离级别 

| |脏读|不可重复读|幻读|解决原理|
|---|---|---|---|---|
|读未提交|x|x|x||
|读已提交|√|x|x||
|可重复读|√|√|x|gap锁 (mysql默认级别)|
|串行化|√|√|√|读锁|

#### 重要文件
- undolog
- redolog
- binlog

#### 存储引擎
- MyISAM
- Heap
- Merge
- INNODB
- ISAM
