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

#### 事务的隔离级别

|-|脏读|幻读|不可重复读|解决原理|
|---|---|---|---|---|
|读未提交|x|x|x||
|读已提交|√|x|x||
|可重复读|√|√|x||
|串行化|√|√|√|gap锁|

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
