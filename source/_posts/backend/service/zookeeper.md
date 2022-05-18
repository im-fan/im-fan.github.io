---
title: Zookeeper简介
date: 2020-10-29 15:40:46
tags: 
- zookeeper
- 注册中心
- 分布式锁
categories: 
- 后端
- 服务治理
---


## 相关链接
> [官网](https://zookeeper.apache.org/releases.html)

## 原理相关
### 角色
|角色| |描述|
|---|---|---|
|领导者(Leader) |  |领导者负责投票的发起和决策，更新系统状态|
|学习者(Learner)|跟随者(Follower)|Follower接收客户端请求并返回结果，在选举的过程中参与投票|
|学习者(Learner)|观察者(ObServer)|接收客户端连接，并转发给Leader。 不参与投票，只同步Leader状态。<br/>ObServer节点目的是扩展系统，提高读取速度|
|客户端(Client)| | 请求发起方|

### 特性
- Zab协议
```textmate
  Zookeeper的核心是原子广播，这个机制保证了各个Server之间的同步。实现这个机制的协议叫做Zab协议。Zab协议有两种模式，它们分别是恢复模式（选主）和广播模式（同步）。
  当服务启动或者在领导者崩溃后，Zab就进入了恢复模式，当领导者被选举出来，且大多数Server完成了和leader的状态同步以后 ，恢复模式就结束了。
  状态同步保证了leader和Server具有相同的系统状态。
  Zab协议有两种模式，它们分别是 **恢复模式** 和 **广播模式** 。
```

- Zxid
```textmate
   为了保证事务的顺序一致性，zookeeper采用了递增的事务id号（zxid）来标识事务。所有的提议（proposal）都在被提出的时候加上了zxid。
   实现中zxid是一个64位的数字，它高32位是epoch用来标识leader关系是否改变，每次一个leader被选出来，它都会有一个新的epoch，标识当前属于那个leader的统治时期。低32位用于递增计数。
```

- Zookeeper节点
```textmate
  1.Znode有两种类型，短暂的（ephemeral）和持久的（persistent）
  2.Znode的类型在创建时确定并且之后不能再修改
  3.短暂znode不可以有子节点
  4.Znode有四种形式的目录节点
    PERSISTENT(持久化节点)
    EPHEMERAL(临时节点)
    PERSISTENT_SEQUENTIAL(持久化顺序编号目录节点)
    EPHEMERAL_SEQUENTIAL(临时顺序编号目录节点)
```

- 工作时状态
```textmate
每个Server在工作过程中有三种状态：
    LOOKING：当前Server不知道leader是谁，正在搜寻
    LEADING：当前Server即为选举出来的leader
    FOLLOWING：leader已经选举出来，当前Server与之同步
```

- 其他特性
```textmate
    1.Zookeeper是一个由多个server组成的集群
    2.一个leader，多个follower
    3.每个server保存一份数据副本
    4.全局数据一致
    5.分布式读写
    6.更新请求转发，由leader实施
```

### 使用场景
- 服务注册
- 分布式锁
- 分布式ID生成器

## 部署
### 注意事项
```textmate
1.下载 xxx-bin.tar.gz包(这种是编译好的)，否则启动时会提示找不到Class
2.启动时注意端口号是否已经被占用
```

### 单机部署步骤
```textmate
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
> [下载地址](https://issues.apache.org/jira/secure/attachment/12436620/ZooInspector.zip)
- 使用

```textmate
1.解压后进入build文件夹
2.运行jar
    nohup java -jar zookeeper-dev-ZooInspector.jar &
3.左上角连接按钮，输入zk地址并连接
```

### 常见问题
- 启动报ClassNotFound

```textmate
重新下载zookeeper包，注意是xxxx-bin.tar.gz这种的
```

- 启动失败

```textmate
1.检查配置的文件夹路径和权限是否正常
2.检查zookeeper是否已经被启动
    ps -ef | grep zookeeper
    kill进程
3.删除 dataDir 和 dataLogDir 路径下 version-2 文件夹后重启
```
