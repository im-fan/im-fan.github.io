---
title: MySQL相关-知识点
date: 2021-07-20 09:45:00
tags:
- mysql

categories:
- 存储
---

### 相关文档
- [Jeremy Cole的博客](https://blog.jcole.us/innodb)
- [MySQL8.0的源码文档](https://dev.mysql.com/doc/dev/mysql-server)
- [mariadb-innodb原理文档(带图)](https://publications.sba-research.org/publications/WSDF2012_InnoDB.pdf)
- [MySQL Team Blog](http://mysqlserverteam.com/)
- [非官方MySQL8.0优化器指南](http://www.unofficialmysqlguide.com/optimizer-trace.html)

## 部分总结
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

## 《MySQL是怎样运行的：从根上理解MySQL》 读书笔记
> 第一次读，摘录了其中部分知识点 2021-09-13读完

### InnoDB数据格式
- 内存与磁盘交互方式
```textmate
InnoDB 采取的方式是:将数据划分为若干个页，以页作为磁盘和内存之间交互的基本单位，InnoDB中页的大小 一般为 16 KB。
也就是在一般情况下，一次最少从磁盘中读取16KB的内容到内存中，一次最少把内存中的16KB 内容刷新到磁盘中。
```

- 行格式
<br/>[Compact行](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/mysql-compact%E8%A1%8C%E6%A0%BC%E5%BC%8F.png)
```textmate
  Compact 、 Redundant 、Dynamic 和 Compressed
  变长字段(varchar(n)、text等)占用内存：1. 真正的数据内容 2. 占用的字节数
  对于 CHAR(M) 类型的列来说，当列采用的是定长字符集时，该列占用的字节数不会被加到变长字 段长度列表，而如果采用变长字符集时，该列占用的字节数也会被加到变长字段长度列表。
```

- 数据太多造成的溢出
```textmate
  行溢出：一个页一般是 16KB ，当记录中的数据太多，当前页放不下的时候，会把多余的数据存储到其他页中；
  MySQL 是以 页为单位管理存储空间，一个页一般16kb,16384字节，一个varchar最多存储65532个字节
  对于占用存储空间非常大的列，在 记录的真实数据 处只会存储该列的一部 分数据，把剩余的数据分散存储在几个其他的页中，然后记录的真实数据处用20个字节存储指向这些页的地址 
  (当然这20个字节中还包括这些分散在其他页面中的数据的占用的字节数)，从而可以找到剩余数据所在的页，
```

- 行溢出的临界点
```textmate
MySQL 中规定一个页中至少存放两行记录
对于只有一个列的表，发生行溢出现象时需要满足这个式子: 136 + 2×(27 + n) > 16384 ， n > 8098
重点:
    不用关注这个临界点是什么，只要知道如果我们向一个行中存储了很大的数据时，可能发生 行溢出 的现象
不论我们怎么对页中的记录做增删改操作，InnoDB始终会维护一条记录的单链表，链表中的各个 节点是按照主键值由小到大的顺序连接起来的
```

- 总结
<br/>[InnoDB数据页结构](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/InnoDB_data_page.png)

```textmate
1. InnoDB为了不同的目的而设计了不同类型的页，我们把用于存放记录的页叫做 数据页 。
2. 一个数据页可以被大致划分为7个部分，分别是
   File Header ，表示页的一些通用信息，占固定的38字节。
   Page Header ，表示数据页专有的一些信息，占固定的56个字节。
   Infimum + Supremum ，两个虚拟的伪记录，分别表示页中的最小和最大记录，占固定的 26 个字节。
   User Records :真实存储我们插入的记录的部分，大小不固定。
   Free Space :页中尚未使用的部分，大小不确定。
   Page Directory: 页中的某些记录相对位置，也就是各个槽在页面中的地址偏移量，大小不固定，插入的记录越多，这个部分占用的空间越多。
   File Trailer :用于检验页是否完整的部分，占用固定的8个字节。
3. 每个记录的头信息中都有一个 next_record 属性，从而使页中的所有记录串联成一个 单链表 。
4. InnoDB 会为把页中的记录划分为若干个组，每个组的最后一个记录的地址偏移量作为一个 槽 ，存放在
   Page Directory 中，所以在一个页中根据主键查找记录是非常快的，分为两步:
   4.1 通过二分法确定该记录所在的槽。
   4.2 通过记录的next_record属性遍历该槽所在的组中的各个记录。
5. 每个数据页的 File Header 部分都有上一个和下一个页的编号，所以所有的数据页会组成一个 双链表 。
6. 为保证从内存中同步到磁盘的页的完整性，在页的首部和尾部都会存储页中数据的校验和和页面最后修改时
   对应的 LSN 值，如果首部和尾部的校验和和 LSN 值校验不成功的话，就说明同步过程出现了问题。
```

- Innodb通用页结构
<br/>[Innodb通用页结构](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/InnoDB%E6%95%B0%E6%8D%AE%E9%A1%B5%E7%BB%93%E6%9E%84%E7%A4%BA%E6%84%8F%E5%9B%BE.png)
<br/>[Innodb通用页结构-解释](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/Innodb%E9%80%9A%E7%94%A8%E9%A1%B5%E7%BB%93%E6%9E%84-%E8%A7%A3%E9%87%8A.png)

```textmate
表空间结构(系统表空间/独立表空间)
连续64个页面 = 一个区(默认1MB)
每256个区被划分为一个组
每个组的最开始的几个页面类型是固定的
1.FSP_HDR 类型:这个类型的页面是用来登记整个表空间的一些整体属性以及本组所有的 区 ，也就是
  extent 0 ~ extent 255 这256个区的属性，稍后详细唠叨。需要注意的一点是，整个表空间只有一 个 FSP_HDR 类型的页面。
2.IBUF_BITMAP 类型:这个类型的页面是存储本组所有的区的所有页面关于 INSERT BUFFER 的信息。
3.INODE 类型:这个类型的页面存储了许多称为 INODE 的数据结构，

其余各组最开始的2个页面的类型是固定的
1.DES 类型:全称是 extent descriptor ，用来登记本组256个区的属性，也就是说对于在 extent 256 区中的该类型页面存储的就是 extent 256 ~ extent 511 这些区的属性，对于在 extent 512 区中的该 类型页面存储的就是 extent 512 ~ extent 767 这些区的属性。上边介绍的 FSP_HDR 类型的页面其实 和 XDES 类型的页面的作用类似，只不过 FSP_HDR 类型的页面还会额外存储一些表空间的属性。
2.IBUF_BITMAP
```

- [InnonDB文件结构总结](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/mysql-innondb%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F.png)


### 索引
```textmate
SHOW INDEX FROM 表名 - 索引统计数据
    对于InnoDB存储引擎来说，使用SHOW INDEX语句展示出来的某个索引列的Cardinality属性是一个估计 值，并不是精确的
注意：
    在MySQL 5.7.3以及之前的版本中，eq_range_index_dive_limit的默认值为10，之 后的版本默认值为200。
    所以如果大家采用的是5.7.3以及之前的版本的话，很容易采用索引统计数据而 不是index dive的方式来计算查询成本。当你的查询中使用到了IN查询，但是却实际没有用到索引，就 应该考虑一下是不是由于 eq_range_index_dive_limit 值太小导致的。
连接查询的成本计算公式:
    连接查询总成本 = 单次访问驱动表的成本 + 驱动表扇出数 x 单次访问被驱动表的成本
```
#### InnoDB统计数据的方式
```textmate
InnoDB 以表为单位来收集统计数据，这些统计数据可以是基于磁盘的永久性统计数据，也可以是基于内存 的非永久性统计数据。
    innodb_stats_persistent 控制着使用永久性统计数据还是非永久性统计数据; 
    innodb_stats_persistent_sample_pages 控制着永久性统计数据的采样页面数量; 
    innodb_stats_transient_sample_pages 控制着非永久性统计数据的采样页面数量; 
    innodb_stats_auto_recalc 控制着是否自动重新计算统计数据。
我们可以针对某个具体的表，在创建和修改表时通过指定 STATS_PERSISTENT 、 STATS_AUTO_RECALC 、 STATS_SAMPLE_PAGES 的值来控制相关统计数据属性。
    innodb_stats_method 决定着在统计某个索引列不重复值的数量时如何对待 NULL 值。
通过配置将决定权交给用户
    1.nulls_equal :认为所有 NULL 值都是相等的。这个值也是 innodb_stats_method 的默认值。如果某个索引列中 NULL 值特别多的话，这种统计方式会让优化器认为某个列中平均一个值重复次数特别 多，所以倾向于不使用索引进行访问。
    2.nulls_unequal :认为所有 NULL 值都是不相等的。如果某个索引列中 NULL 值特别多的话，这种统计方式会让优化器认为某个列中平均一个值重复次数特别 少，所以倾向于使用索引进行访问。
    3.nulls_ignored :直接把 NULL 值忽略掉。
```

#### SQL重写方式
##### 条件化简
```textmate
1.移除不必要的括号
2.常量传递
    a = 5 AND b > a 改写为 a = 5 AND b > 5
3.等值传递
    a = b and b = c and c = 5 改写为 a = 5 and b = 5 and c = 5
4.移除没用的条件
    (a < 1 and b = b) OR (a = 6 OR 5 != 5) 改写为 (a < 1 and TRUE) OR (a = 6 OR FALSE)  ==>  a < 1 OR a = 6
5.表达式计算
    a =5 + 1 改写为 a=6
6.having和where子句合并
7.常量表检测
```

##### 外连接消除
- 外连接和内连接区别
```textmate
外连接和内连接的本质区别就是:
    对于外连接的驱动表的记录来说，如果无法在被驱动表中找到 匹配ON子句中的过滤条件的记录，那么该记录仍然会被加入到结果集中，对应的被驱动表记录的各个字段使用 NULL值填充;
    而内连接的驱动表的记录如果无法在被驱动表中找到匹配ON子句中的过滤条件的记录，那么该记 录会被舍弃
空值拒绝:
    在被驱动表的WHERE子句符合空值拒绝的条件后，外连接和内连接可以相互转 换。这种转换带来的好处就是查询优化器可以通过评估表的不同连接顺序的成本，选出成本最低的那种连接顺序 来执行查询。
```

##### 子查询优化
```textmate
1.按返回的结果集区分子查询
    标量子查询
    行子查询
    列子查询
    表子查询
2.按与外层查询关系来区分子查询
    不相关子查询
    相关子查询
3.子查询在布尔表达式中的使用
4.子查询语法注意事项
    4.1 子查询必须用小括号扩起来
    4.2 在 SELECT 子句中的子查询必须是标量子查询
    4.3 在想要得到标量子查询或者行子查询，但又不能保证子查询的结果集只有一条记录时，应该使用LIMIT 1语句来限制记录数量。
    4.4 对于[NOT]IN/ANY/SOME/ALL 子查询来说，子查询中不允许有 LIMIT 语句。
    4.5 不允许在一条语句中增删改某个表的记录时同时还对该表进行子查询。

    如果 IN 子查询符合转换为 semi-join 的条件，查询优化器会优先把该子查询为 semi-join ，然后再考虑下边5种执行半连接的策略中哪个成本最低:
    Table pullout
    DuplicateWeedout 
    LooseScan 
    Materialization 
    FirstMatch
    选择成本最低的那种执行策略来执行子查询。
    如果 IN 子查询不符合转换为 semi-join 的条件，那么查询优化器会从下边两种策略中找出一种成本更低的 方式执行子查询:
    先将子查询物化之后再执行查询 执行 IN to EXISTS 转换。

5.[NOT] EXISTS子查询的执行
    如果 [NOT] EXISTS 子查询是不相关子查询，可以先执行子查询，得出该 [NOT] EXISTS 子查询的结果是 TRUE 还
    是 FALSE ，并重写原先的查询语句

6.对于派生表的优化
    6.1 最容易想到的就是把派生表物化
    6.2将派生表和外层的表合并，也就是将查询重写为没有派生表的形式
```

### Explain
##### 查看优化器生成执行计划的整个过程
```textmate
SHOW VARIABLES LIKE 'optimizer_trace';
 1. 打开optimizer trace功能 (默认情况下它是关闭的):
    SET optimizer_trace="enabled=on";
 2. 这里输入你自己的查询语句 SELECT ...;
 3. 从OPTIMIZER_TRACE表中查看上一个查询的优化过程 
    SELECT * FROM information_schema.OPTIMIZER_TRACE;
 4. 可能你还要观察其他语句执行的优化过程，重复上边的第2、3步 ...
 5. 当你停止查看语句的优化过程时，把optimizer trace功能关闭 SET optimizer_trace="enabled=off";
```

### 磁盘
#### 总结
```textmate
1. 磁盘太慢，用内存作为缓存很有必要。
2. Buffer Pool 本质上是 InnoDB 向操作系统申请的一段连续的内存空间，可以通过
   innodb_buffer_pool_size 来调整它的大小。
3. Buffer Pool 向操作系统申请的连续内存由控制块和缓存页组成，每个控制块和缓存页都是一一对应的，在
   填充足够多的控制块和缓存页的组合后， Buffer Pool 剩余的空间可能产生不够填充一组控制块和缓存页，
   这部分空间不能被使用，也被称为 碎片 。
4. InnoDB 使用了许多 链表 来管理 Buffer Pool 。
5. free链表 中每一个节点都代表一个空闲的缓存页，在将磁盘中的页加载到 Buffer Pool 时，会从 free链 表 中寻找空闲的缓存页。
6. 为了快速定位某个页是否被加载到 Buffer Pool ，使用 表空间号 + 页号 作为 key ，缓存页作为 value ， 建立哈希表。
7. 在 Buffer Pool 中被修改的页称为 脏页 ，脏页并不是立即刷新，而是被加入到 flush链表 中，待之后的某 个时刻同步到磁盘上。
8. LRU链表 分为 young 和 old 两个区域，可以通过 innodb_old_blocks_pct 来调节 old 区域所占的比例。
   首次从磁盘上加载到 Buffer Pool 的页会被放到 old 区域的头部，在 innodb_old_blocks_time 间隔时间内访 问该页不会把它移动到 young 区域头部。在 Buffer Pool 没有可用的空闲缓存页时，会首先淘汰掉 old 区 域的一些页。
9. 我们可以通过指定 innodb_buffer_pool_instances 来控制 Buffer Pool 实例的个数，每个 Buffer Pool 实 例中都有各自独立的链表，互不干扰。
10. 自 MySQL 5.7.5 版本之后，可以在服务器运行过程中调整 Buffer Pool 大小。每个 Buffer Pool 实例由若 干个 chunk 组成，每个 chunk 的大小可以在服务器启动时通过启动参数调整。
11. 可以用下边的命令查看 Buffer Pool 的状态信息: SHOW ENGINE INNODB STATUS\G
```

### 事务
#### ReadView
- [版本链](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/mysql-innodb-%E7%89%88%E6%9C%AC%E9%93%BE.png)

```textmate
READ COMMITTED 和 REPEATABLE READ 隔离级别的事务来说，
核心问题就是:需要判断一下版本链中的哪个版本是当前事务可见的;
```

- ReadView包含信息

```textmate
1.m_ids :表示在生成 ReadView 时当前系统中活跃的读写事务的 事务id 列表。
2.min_trx_id :表示在生成 ReadView 时当前系统中活跃的读写事务中最小的 事务id ，也就是 m_ids 中的最 小值。
3.max_trx_id :表示生成 ReadView 时系统中应该分配给下一个事务的 id 值。
  小贴士:
  注意max_trx_id并不是m_ids中的最大值，事务id是递增分配的。比方说现在有id为1，2，3这三 个事务，之后id为3的事务提交了。那么一个新的读事务在生成ReadView时，m_ids就包括1和2，mi n_trx_id的值就是1，max_trx_id的值就是4。
4.creator_trx_id :表示生成该 ReadView 的事务的 事务id 。
```

- 区别

```textmate
READ COMMITTED 和 REPEATABLE READ 隔离级别的的一个非常大的区别就是它们生成ReadView的 时机不同
READ COMMITTED —— 同一事务每次读取数据前都生成一个ReadView
REPEATABLE READ —— 同一事务在第一次读取数据时生成一个ReadView
```

- ReadView判断步骤

```textmate
1.如果被访问版本的 trx_id 属性值与 ReadView 中的 creator_trx_id 值相同，意味着当前事务在访问它自己 修改过的记录，所以该版本可以被当前事务访问。
2.如果被访问版本的 trx_id 属性值小于 ReadView 中的 min_trx_id 值，表明生成该版本的事务在当前事务生 成 ReadView 前已经提交，所以该版本可以被当前事务访问。
3.如果被访问版本的 trx_id 属性值大于 ReadView 中的 max_trx_id 值，表明生成该版本的事务在当前事务生 成 ReadView 后才开启，所以该版本不可以被当前事务访问。
4.如果被访问版本的 trx_id 属性值在 ReadView 的 min_trx_id 和 max_trx_id 之间，那就需要判断一下 trx_id 属性值是不是在 m_ids 列表中，如果在，说明创建 ReadView 时生成该版本的事务还是活跃的，该
  版本不可以被访问;如果不在，说明创建 ReadView 时生成该版本的事务已经被提交，该版本可以被访问。

MVCC (Multi-Version Concurrency Control ，多版本并发控制)指的就 是在使用 READ COMMITTD 、 REPEATABLE READ 这两种隔离级别的事务在执行普通的 SEELCT 操作时访问记录的版 本链的过程，这样子可以使不同事务的 读-写 、 写-读 操作并发执行，从而提升系统性能。
```

- purge
```textmate
  insert undo 在事务提交之后就可以被释放掉了，而 update undo 由于还需要支持 MVCC ，不能立即 删除掉。
  为了支持 MVCC ，对于 delete mark 操作来说，仅仅是在记录上打一个删除标记，并没有真正将它删除掉。
  随着系统的运行，在确定系统中包含最早产生的那个 ReadView 的事务不会再访问某些 update undo日志 以及被 打了删除标记的记录后，有一个后台运行的 purge线程 会把它们真正的删除掉
```
### 锁
#### 锁分类
```textmate
行级锁、表锁(S锁-共享锁、X锁-独占锁、IS-意向共享、IX-意向独占)
总结:
    IS、IX锁是表级锁，它们的提出仅仅为了在之后加表级别的S锁和X锁时可以快速判断表中的记录是否 被上锁，
    以避免用遍历的方式来查看表中有没有上锁的记录，也就是说其实IS锁和IX锁是兼容的，IX锁和IX锁是 兼容的
```

- 兼容性

|是否兼容|X|IX|S|IS|
|---|---|---|---|---|
|X|否|否|否|否|
|IX|否|是|否|是|
|S|否|否|是|是|
|IS|否|是|是|是|

- 锁结构(简易)
```textmate
  trx信息 :代表这个锁结构是哪个事务生成的。
  is_waiting :代表当前事务是否在等待。
```
- 操作锁步骤
```textmate
  在事务 T1 提交之后，就会把该事务生成的 锁结构 释放掉，然后看看还有没有别的事务在等待获取锁， 发现了事务 T2 还在等待获取锁，
  所以把事务 T2 对应的锁结构的 is_waiting 属性设置为 false ，然后 把该事务对应的线程唤醒，让它继续执行，此时事务 T2 就算获取到锁了
```

#### 事务隔离级别
```textmate
在 READ UNCOMMITTED 隔离级别下， 脏读 、 不可重复读 、 幻读 都可能发生。
在 READ COMMITTED 隔离级别下， 不可重复读 、 幻读 可能发生， 脏读 不可以发生。
在 REPEATABLE READ 隔离级别下， 幻读 可能发生， 脏读 和 不可重复读 不可以发生。
在 SERIALIZABLE 隔离级别下，上述问题都不可以发生。

脏读：读到另一个事务未提交的数据
不可重复读: 同一个事务两次读取，第二次读取到了另外一个事务提交的数据
幻读: 同一个事务两次读取范围数据，第二次读取到新的记录
```
