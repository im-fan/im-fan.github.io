---
title: nacos
description: nacos
#top: 1
date: 2021-04-13 10:56:52
tags:
- nacos
- 动态配置
- 注册中心
categories:
- 后端
- 服务治理
---

## 相关资料
- [官方文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)
- [小白也能懂的 Nacos 服务模型介绍(转)](https://mp.weixin.qq.com/s/S8HI7DG5v9C2IfjXtkVjuQ) 
- [动态刷新原理(转)](https://blog.csdn.net/wangwei19871103/article/details/105775039/)
- [相关-Raft算法(转)](https://www.baidu.com/s?ie=UTF-8&wd=Raft%E7%AE%97%E6%B3%95)

## 介绍
### 主要作用
```textmate
1.致力于发现、配置和管理微服务
    提供了一组简单易用的特性集，帮助使用者快速实现动态服务发现、服务配置、服务元数据及流量管理。
2.更敏捷和容易地构建、交付和管理微服务平台
    构建以“服务”为中心的现代应用架构 (例如微服务范式、云原生范式) 的服务基础设施

服务（Service）是 Nacos 世界的一等公民。Nacos 支持几乎所有主流类型的“服务”的发现、配置和管理
```
### 关键特性
- 服务发现和服务健康监测
- 动态配置服务
- 动态 DNS 服务
- 服务及其元数据管理

### 优势
```textmate
1.与eureka相比
    nacos基于raft协议，集群一致性高；
    eureka2.0闭源了
    理论上支持的实例数大于eureka
2.与SpringCloud Config相比
    无需基于git仓库存储配置；
    有可视化操作界面
    nacos基于长连接，配置变动后立即通知Proivder
```
### 扩展
- raft协议
```textmate
Raft 协议强依赖 Leader 节点来确保集群数据一致性。
步骤:
client 发送过来的数据均先到达 Leader 节点，Leader 接收到数据后，先将数据标记为 uncommitted 状态，
随后 Leader 开始向所有 Follower 复制数据并等待响应，集群中超过半数的 Follower 成功接收数据并响应后，
Leader 将数据的状态标记为 committed，随后向 client 发送数据已接收确认，在向 client 发送出已数据接收后，
再向所有 Follower 节点发送通知表明该数据状态为committed。
```
