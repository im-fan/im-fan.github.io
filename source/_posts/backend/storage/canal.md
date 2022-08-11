---
title: Canal服务搭建
date: 2020-10-02 15:51:46
tags: 
- canal
categories: 
- 存储
---

## 介绍
### 主要用途
```textmate
基于 MySQL 数据库增量日志解析，提供增量数据订阅和消费。
```

### 适用场景
- 数据库镜像
- 数据库实时备份
- 索引构建和实时维护(拆分异构索引、倒排索引等)
- 业务 cache 刷新
- 带业务逻辑的增量数据处理

### 工作原理
```textmate
基于MySQL主备复制原理,伪装成MySQL slave,模拟MySQL slave的交互协议,
向MySQL mater发送dump协议,MySQL mater收到canal发送过来的dump请求，开始推送binary log给canal，
canal解析binary log，再发送到其他存储服务中，如: MySQL，RocketMQ，ES等等。
```

## 用途

## 搭建
### 1.直接部署
```textmate
1.下载安装包(点击上面Release)
    这里用1.1.4版本,下载 canal.deployer-1.1.4.tar.gz(主要程序) 和 canal.admin-1.1.4.tar.gz(管理程序)

2.解压&配置
    mkdir canal-deployer
    mkdir canal-admin
    tar -zxvf canal.deployer-1.1.4.tar.gz -C canal-deployer
    tar -zxvg canal.admin-1.1.4.tar.gz -C canal-admin
    修改 canal-deployer/conf 中 canal.properties(参考 快速开始，或参考底部配置)

3.修改Instance配置
    cd cd canal-deployer/conf/example/instance.properties
    参考官网或底部instance.peroperties配置

4.多Instance - 可选
    cd canal-deployer/conf
    cp -R example example2
    修改example2中配置

5.配置canal-admin
    初始化数据脚本，脚本所在位置 canal-admin/conf/canal_manager.sql
    修改配置，配置所在位置 canal-admin/conf/application.yml
    修改其中的数据库配置、端口号、用户名密码等-可选

6.启动
    6-1.canal-admin启动( 访问链接 localhost:80 )
        sh ./canal-admin/bin/startup.sh
    6-2.canal-server启动
        sh ./canal-deployer/bin/startup.sh
    6-3.日志所在文件夹
        cd canal-deployer/logs
```

### 2、Docker搭建步骤
> docker方式部署,注意配置时mysql的IP地址
#### 2.1、准备
```textmate
1.mysql
  需要确认mysql已开启binlog设置
2.拉取canal-server镜像
  docker pull canal/canal-server:v1.1.4
3.下载docker启动脚本
   wget https://github.com/alibaba/canal/blob/master/docker/run.sh
4.修改启动脚本中数据库配置
5.下载canal-admin包,修改配置(或者复制run.sh并修改启动命令，启动canal-admin)-可选
   wget https://github.com/alibaba/canal/releases/download/canal-1.1.4/canal.admin-1.1.4.tar.gz
   mkdir canal-admin
   tar -zxvf canal.admin-1.1.4.tar.gz -C canal-admin
   修改conf/application.yml中数据库配置
   初始化mysql脚本，conf/canal_manager.sql
6.canal-client
   参考 Canal Client Example
```

#### 2.2、启动命令
```textmate
1.canal-server
   运行 sh run.sh 会出现提示，复制提示后运行
2.canal-admin
   sh bin/startup.sh
3.启动程序(canal-client)
    成功后会打印出empty count : xx
```

### CanalAdmin部署
- 1.集群配置
```yaml
#集群名-local
#zk地址-127.0.0.1:2181 (可以不搭建zk)
#以下为配置项
# register ip
canal.register.ip =
# canal admin config
canal.admin.manager = 127.0.0.1:8089
canal.admin.port = 11110
canal.admin.user = admin
canal.admin.passwd = 4ACFE3202A5FF5CF467898FC58AAB1D615029441
```

- 2.Server管理
```textmate
ServerIP-127.0.0.1 (同一集群下server ip不能重复)
admin端口号-11110
```

- 3.Instance管理
```textmate
注意：Instance名称要与cancal-server容器中文件夹一致，默认有example
Instance配置项参考官网或底部配置
```

#### 一个Canal服务读取多个MySQL实例(docker中操作)
```textmate
1.进入canal容器内部关闭服务(不关闭复制会导致写入db2失败)
    docker exec -it canal-server bash
    ./stop.sh
2.复制一份Instatnce配置(注意确认example2中文件权限与example中是否一样)
    cd canal-server/conf
    cp -R example example2
3.Canal Admin中添加新配置
    Instance名称-example2
4.集成zookeeper
    修改canal-server/conf/下配置canal.properties
    canal.register.ip = zk服务器IP
    canal.zkServers = zk服务器IP:2181
```

### 参考配置(基础版，其他配置参考官网)

- canal.properties
```yaml
# 用以下配置项是需要修改的，其他默认配置项保留原来设置
# canal地址
canal.register.ip = zk所在地址
# zk配置，如果有用到则配置，没用到则保留默认设置
canal.admin.register.auto = true
canal.admin.register.cluster = 192.168.154.231:2181
canal.zkServers = 192.168.154.231:2181
```

- instance.properties
```yaml
# 用以下配置项是需要修改的，其他默认配置项保留原来设置(example2配置同下)
# 数据库配置
canal.instance.master.address= 数据库IP:端口号
canal.instance.dbUsername = 用户名 
canal.instance.dbPassword = 密码
canal.instance.defaultDatabaseName = 要监控的库名，不设置则监听当前实例下所有库
canal.instance.connectionCharset = UTF-8
canal.instance.tsdb.enable=false
```

#### 常见问题
- 服务都启动成功，客户端拉不到变更日志
```textmate
注意客户端中 canalConnector.subscribe() 中设置项，设置了值则服务中配置的过滤条件不生效
参考配置 canalConnector.subscribe("sap_system\\..*,user_center\\..*")
```

- 一个Canal-Service,多个client，运行时报错
```textmate
改为一个canal一个client，原因是多个client同时提交ack时，可能会存在重复提交的问题
```
- zk中记录的点位异常
```textmate
进入zookeeper安装目录 
cd /bin
./zkClient.sh  或  ./zkCli.sh
deleteall /otter/canal/destinations/instanceName(canal-admin中配置的instance名称)
```

## 总结
```textmate
1.对业务代码无侵入、实时性接近准实时
2.支持集群，集群基于zk做集群管理
3.提供多种接入方式、适配器等
3.不适合做复杂的业务逻辑判断及计算；直接对表数据进行修改，出问题后影响较大
```

## 相关网址
- [官网](https://github.com/alibaba/canal/wiki/Home)
- [快速开始](https://github.com/alibaba/canal/wiki/QuickStart)
- [Release下载](https://github.com/alibaba/canal/releases)
- [Docker镜像地址](https://hub.docker.com/r/canal/canal-server/tags/)
- [Canal Admin QuickStart](https://github.com/alibaba/canal/wiki/Canal-Admin-QuickStart)
- [Canal Client Example](https://github.com/alibaba/canal/wiki/ClientExample)
