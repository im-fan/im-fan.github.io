---
title: MySQL相关-常用语句
date: 2020-10-02 15:51:46
tags: 
- mysql
categories: 
- 存储
---

### 建表语句
```sql
1.表结构完全复制
create table user_bak LIKE user;

2.使用某些字段建表
create table user_bak select now() as time ;

3.建表时字段值强制转换
create table user_bak select CAST('2019-8-01' as UNSIGNED) as time;

4.临时表
解释: 只对当前会话有效,有同名表则原表隐藏不可见,会话结束自动清除
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


### 判断时间间隔不能重叠
```sql
set @start='2022-06-08',@end='2022-06-10';
select * FROM xxx WHERE 
(
    (start_time <= @start and end_time >= @end )
     or (start_time >= @start and end_time >= @end and start_time < @end)
     or (start_time <= @start and end_time <= @end and end_time > @start )
     or (start_time >= @start and end_time <= @end)
)

-- 解释
/*
时间重叠情况
    startTime    endTime
  start |   end     |
  start |           |    end
        | start end |
        |           |
*/
```

### MySQL8.0大数据表添加varchar字段
> [MySQL8.0官网文档](https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl-operations.html)
```sql
-- 原生只支持在表中追加字段，不可以随意位置插入字段
update xxx add column name varchar(255),ALGORITHM=INSTANT;

/*
作用：指定操作使用的算法类型
    COPY：对原始表的副本执行操作，并将表数据从原始表逐行复制到新表。不允许并发DML。
    INPLACE：操作可避免复制表数据，但可以在适当位置重建表。在操作的准备和执行阶段可以简短地获取表上的独占元数据锁定。通常，支持并发DML。
    INSTANT：操作只能修改数据字典中的元数据。在准备和执行期间，不会在表上获取任何独占元数据锁，并且表数据不受影响，从而使操作立即进行。允许并发DML。（在MySQL 8.0.12中引入）

INSTANT 原理：
    在 INNODB_COLUMNS.DEFAULT_VALUE、INNODB_COLUMNS.HAS_DEFAULT、INNODB_TABLES.INSTANT_COLS
    表中添加配置信息，标识添加instant字段前字段数、instant字段是否有默认值，instant添加的字段名;
    不会将添加的字段写入db文件，只有操作了数据(insert/update)后，才会将完整结构的数据更新至db文件
*/
```

### 查看NavicatPremium中的连接密码
#### 1.NaivatPremium导出连接
```textmate
注意：导出时一定要勾选上导出密码！！！
导出文件中 Password 值是加密后的密码
```
#### 解密
```textmate
1.打开网址 https://tool.lu/coderunner/  左上角选择php
2.复制以下代码到代码框中,修改倒数第三行代码中的加密串
3.点击执行(Run)
4.如果执行失败则修改下版本号 11/12
ps: 感谢大佬提供的代码，已经找不到出处了
```

```php
<?php
class NavicatPassword{

	protected $version = 0;
	protected $aesKey = 'libcckeylibcckey';
	protected $aesIv = 'libcciv libcciv ';
	protected $blowString = '3DC5CA39';
	protected $blowKey = null;
	protected $blowIv = null;

	public function __construct($version = 12){
		$this->version = $version;
		$this->blowKey = sha1('3DC5CA39', true);
		$this->blowIv = hex2bin('d9c7c3c8870d64bd');
	}

	public function encrypt($string){
		$result = FALSE;
		switch ($this->version) {
			case 11:
				$result = $this->encryptEleven($string);
				break;
			case 12:
				$result = $this->encryptTwelve($string);
				break;
			default:
				break;
		}

		return $result;
	}

	protected function encryptEleven($string){
		$round = intval(floor(strlen($string) / 8));
		$leftLength = strlen($string) % 8;
		$result = '';
		$currentVector = $this->blowIv;

		for ($i = 0; $i < $round; $i++) {
			$temp = $this->encryptBlock($this->xorBytes(substr($string, 8 * $i, 8), $currentVector));
			$currentVector = $this->xorBytes($currentVector, $temp);
			$result .= $temp;
		}

		if ($leftLength) {
			$currentVector = $this->encryptBlock($currentVector);
			$result .= $this->xorBytes(substr($string, 8 * $i, $leftLength), $currentVector);
		}

		return strtoupper(bin2hex($result));
	}

	protected function encryptBlock($block){
		return openssl_encrypt($block, 'BF-ECB', $this->blowKey, OPENSSL_RAW_DATA|OPENSSL_NO_PADDING);
	}

	protected function decryptBlock($block){
		return openssl_decrypt($block, 'BF-ECB', $this->blowKey, OPENSSL_RAW_DATA|OPENSSL_NO_PADDING);
	}

	protected function xorBytes($str1, $str2){
		$result = '';
		for ($i = 0; $i < strlen($str1); $i++) {
			$result .= chr(ord($str1[$i]) ^ ord($str2[$i]));
		}

		return $result;
	}

	protected function encryptTwelve($string){
		$result = openssl_encrypt($string, 'AES-128-CBC', $this->aesKey, OPENSSL_RAW_DATA, $this->aesIv);
		return strtoupper(bin2hex($result));
	}

	public function decrypt($string){
		$result = FALSE;
		switch ($this->version) {
			case 11:
				$result = $this->decryptEleven($string);
				break;
			case 12:
				$result = $this->decryptTwelve($string);
				break;
			default:
				break;
		}

		return $result;
	}

	protected function decryptEleven($upperString){
		$string = hex2bin(strtolower($upperString));

		$round = intval(floor(strlen($string) / 8));
		$leftLength = strlen($string) % 8;
		$result = '';
		$currentVector = $this->blowIv;

		for ($i = 0; $i < $round; $i++) {
			$encryptedBlock = substr($string, 8 * $i, 8);
			$temp = $this->xorBytes($this->decryptBlock($encryptedBlock), $currentVector);
			$currentVector = $this->xorBytes($currentVector, $encryptedBlock);
			$result .= $temp;
		}

		if ($leftLength) {
			$currentVector = $this->encryptBlock($currentVector);
			$result .= $this->xorBytes(substr($string, 8 * $i, $leftLength), $currentVector);
		}

		return $result;
	}

	protected function decryptTwelve($upperString){
		$string = hex2bin(strtolower($upperString));
		return openssl_decrypt($string, 'AES-128-CBC', $this->aesKey, OPENSSL_RAW_DATA, $this->aesIv);
	}
};


//需要指定版本两种，11或12
$navicatPassword = new NavicatPassword(12);

//解密密码,替换这里的值
$decode = $navicatPassword->decrypt('xxxx');
echo $decode."\n";
?>
```
