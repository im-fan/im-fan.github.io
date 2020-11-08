---
title: Zookeeper搭建
date: 2020-10-29 15:40:46
tags: 
- zookeeper
categories: 
- 服务搭建
---


### 相关链接
- [官网](https://zookeeper.apache.org/releases.html)

### 注意事项
```text
1.下载 xxx-bin.tar.gz包(这种是编译好的)，否则启动时会提示找不到Class
2.启动时注意端口号是否已经被占用

```

### 单机部署步骤
```text
1.解压文件
    tar -zxvf xxx-bin.tar.gz zookeeper
2.修改配置
    cd zookeeper/conf
    cp zoo_sample.cfg zoo.cfg
    vim zoo.cfg
    修改以下配置项
        dataDir= xxx/dataDir
        dataLogDir= xxx/logs/zookeeper
        
3.新增配置
    cd xxx/dataDir
    echo 1001>myid

4.启动
    cd zookeeper/bin
    ./zkServer.sh start / restart / stop / status

```

### zookeeper数据查看工具
- [下载地址](https://issues.apache.org/jira/secure/attachment/12436620/ZooInspector.zip)
- 使用
```text
1.解压后进入build文件夹
2.运行jar
    nohup java -jar zookeeper-dev-ZooInspector.jar &
3.左上角连接按钮，输入zk地址并连接
```


### 常见问题
- 启动报ClassNotFound
```text
重新下载zookeeper包，注意是xxxx-bin.tar.gz这种的
```

- 启动失败
```text
1.检查配置的文件夹路径和权限是否正常
2.检查zookeeper是否已经被启动
    ps -ef | grep zookeeper
    kill进程
3.删除 dataDir 和 dataLogDir 路径下 version-2 文件夹后重启
```
