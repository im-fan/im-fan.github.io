---
title: MySQL相关-json类型
date: 2022-06-01 15:20
tags:
- mysql
- json类型
categories:
- 存储
---

### 简介
> MySQL 5.7 增加了 JSON 数据类型的支持; 可以直接通过内置语法对json结构数据进行操作
> 注意: 对json结构位置不能变更的业务，强烈建议使用varchar或者text等结构存储，json类型会优化key顺序

### 查询语法
|语法	|描述|	最小可用版本(5.7+)|	已弃用|
|---|---|---|---|
|->	|评估路径后从 JSON 列返回值；相当于 JSON_EXTRACT()。||
|->>|	评估路径并取消引用结果后从 JSON 列返回值；相当于 JSON_UNQUOTE(JSON_EXTRACT())。|	5.7.13	|
|JSON_APPEND()|	将数据附加到 JSON 文档	|	Y|
|JSON_ARRAY()|	创建 JSON 数组		| |
|JSON_ARRAY_APPEND()|	将数据附加到 JSON 文档		| |
|JSON_ARRAY_INSERT()|	插入 JSON 数组		| |
|JSON_CONTAINS()|	JSON 文档是否在路径中包含特定对象		| |
|JSON_CONTAINS_PATH()|	JSON 文档是否包含路径中的任何数据		| |
|JSON_DEPTH()|	JSON 文档的最大深度		| |
|JSON_EXTRACT()|	从 JSON 文档返回数据		 ||
|JSON_INSERT()|	将数据插入 JSON 文档		| |
|JSON_KEYS()|	JSON 文档中的键数组		| |
|JSON_LENGTH()|	JSON 文档中的元素数		| |
|JSON_MERGE()|	合并 JSON 文档，保留重复键。JSON_MERGE_PRESERVE() 的弃用同义词	 |	5.7.22|
|JSON_MERGE_PATCH()|	合并 JSON 文档，替换重复键的值 |	5.7.22	|
|JSON_MERGE_PRESERVE()|	合并 JSON 文档，保留重复键 |	5.7.22	|
|JSON_OBJECT()|	创建 JSON 对象		| |
|JSON_PRETTY()|	以人类可读的格式打印 JSON 文档	 |5.7.22	|
|JSON_QUOTE()|	引用 JSON 文档		| |
|JSON_REMOVE()|	从 JSON 文档中删除数据		| |
|JSON_REPLACE()|	替换 JSON 文档中的值		| |
|JSON_SEARCH()|	JSON 文档中值的路径		| |
|JSON_SET()|	将数据插入 JSON 文档		| |
|JSON_STORAGE_SIZE()|	用于存储 JSON 文档的二进制表示的空间	5.7.22	| |
|JSON_TYPE()|	JSON 值的类型		| |
|JSON_UNQUOTE()|	取消引用 JSON 值 |		|
|JSON_VALID()|	JSON值是否有效		 ||


### 案例

#### 创建 JSON
```sql
SELECT JSON_ARRAY(1, "abc", NULL, TRUE, CURTIME());
SELECT JSON_OBJECT('id', 87, 'name', 'carrot');
SELECT JSON_QUOTE('null'), JSON_QUOTE('"null"'),JSON_QUOTE('[1, 2, 3]');
```

#### 搜索JSON
```sql
select b.c ->'$.a' from  ( select JSON_OBJECT('a',"10","b","15","c","25") as c  ) b;
select b.c ->>'$.a' from  ( select JSON_OBJECT('a',"10","b","15","c","25") as c  ) b;
```

#### JSON字符串转JSON对象
```sql
select b.js->>'$.a' from (select CAST('{"a":"10","b":"15","x":"25"}' as json) js ) as b;
```

### 注意事项

- JSON结构重排序
```textmate
现象:  
    执行 select CAST('{"aaa":"10","d":"15","cc":"25","c":"11"}' as json) 后返回数据
    {"c": "11", "d": "15", "cc": "25", "aaa": "10"}

原因: MySQL会针对JSON结构优化排序，提高搜索效率；排序规则是先根据key长度排序，长度相同根据ASCII()值排序
    select  ASCII('d'),ASCII('c')
```

### 相关资料
- [MySQL官方文档](https://dev.mysql.com/doc/refman/5.7/en/json-functions.html)
