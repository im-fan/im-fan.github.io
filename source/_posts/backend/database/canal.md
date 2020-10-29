---
title: Canal-Docker搭建
date: 2020-10-02 15:51:46
tags: 
- canal
categories: 
- 数据库
- Canal搭建
---

### 相关网址
- [官网](https://github.com/alibaba/canal/wiki/Home)
- [快速开始](https://github.com/alibaba/canal/wiki/QuickStart)
- [Docker镜像地址](https://hub.docker.com/r/canal/canal-server/tags/)
- [Canal Admin QuickStart](https://github.com/alibaba/canal/wiki/Canal-Admin-QuickStart)
- [Canal Client Example](https://github.com/alibaba/canal/wiki/ClientExample)

### 搭建步骤
- 推荐docker方式部署,注意配置时mysql的IP地址
#### 准备
```text
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

#### 启动命令
```text
1.canal-server
   运行 sh run.sh 会出现提示，复制提示后运行
2.canal-admin
   sh bin/startup.sh
3.启动程序(canal-client)
    成功后会打印出empty count : xx
```

#### CanalAdmin配置

- 1.集群配置
```text
集群名-local
zk地址-127.0.0.1:2181 (可以不搭建zk)
以下为配置项
    # register ip
    canal.register.ip =
    # canal admin config
    canal.admin.manager = 127.0.0.1:8089
    canal.admin.port = 11110
    canal.admin.user = admin
    canal.admin.passwd = 4ACFE3202A5FF5CF467898FC58AAB1D615029441
    # admin auto register
    canal.admin.register.auto = true
    canal.admin.register.cluster =
  
```

- 2.Server管理
```text
ServerIP-127.0.0.1 (同一集群下server ip不能重复)
admin端口号-11110

```

- 3.Instance管理
```text
注意：Instance名称要与cancal-server容器中文件夹一致，默认有example
Instance配置项
    ## mysql serverId
    canal.instance.mysql.slaveId = 1002
    #position info，需要改成自己的数据库信息
    canal.instance.master.address = 127.0.0.1:3306
    #username/password，需要改成自己的数据库信息
    canal.instance.dbUsername = root  
    canal.instance.dbPassword = 123456
    canal.instance.connectionCharset = UTF-8
    #table regex，过滤规则
    canal.instance.filter.regex = .\*\\\\..\*

```

#### 一个Canal服务读取多个MySQL实例(docker中操作)
```text
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