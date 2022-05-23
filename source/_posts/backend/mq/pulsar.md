---
title: Pulsar消息队列
date: 2022-05-23 10:20:00
tags:
- message
- pulsar

categories:
- 后端
- 消息队列
---

### 概述
> Apache Pulsar 是 Apache 软件基金会顶级项目，是下一代云原生分布式消息流平台，集消息、存储、轻量化函数式计算为一体，
> 采用计算与存储分离架构设计，支持多租户、持久化存储、多机房跨区域数据复制，具有强一致性、高吞吐、低延时及高可扩展性等流数据存储特性，
> 被看作是云原生时代实时消息流传输、存储和计算最佳解决方案。

### 组件介绍

- pulsar组件
![pulsar组件](https://raw.githubusercontent.com/im-fan/fan-pic/release/imagespulsar-module.jpg)

- 消息结构
```mermaid
%%{init: {'theme':'base'}}%%;
graph TD
    EventStream --> segment1
    EventStream --> segment2
    EventStream --> segment3
    segment1 --> message1
    segment1 --> message2
    Leder-id -.-> message2
    entry-id -.-> message2
    batch-index -.-> message2
    partition-index -.-> message2
```

- 组件描述

|组件|描述|
|:---|:---|
|Value / data payload|消息携带的数据。所有 Pulsar 消息都包含原始字节，尽管消息数据也可以符合数据模式。|
| Key| 消息可以有选择地使用键标记，这对于诸如主题压缩之类的事情很有用。|
| Properties | 用户定义属性的可选键/值映射。|
| Topic name | 消息要发布到的主题的名称。|
| Schema version|使用该模式生成消息的版本号。 |
| Sequence ID| 每条pulsar信息都属于其主题的有序序列。消息的序列ID最初是由它的生产者分配的，表示它在序列中的顺序，也可以定制。
“序列ID”可用于重复数据删除。如果brokerDeduplicationEnabled设置为true，每个消息的序列ID在一个主题(未分区)或分区的生产者中是唯一的。|
| Message ID| 消息的消息ID在消息被持久化存储后立即由经纪人分配。消息ID表示消息在分类账中的特定位置，在Pulsar集群中是唯一的。 |
| Publish time| 消息发布的时间戳。时间戳由生产者自动应用。|
| Event time| 由应用程序附加到消息上的可选时间戳。例如，应用程序在处理消息时附加时间戳。如果没有设置事件时间，则该值为0。 |

```textmate
    Producer：数据生产者，发送消息的一方。生产者负责创建消息，将其投递到 Pulsar 中。
    Consumer：数据消费者，接收消息的一方。消费者连接到 Pulsar 并接收消息，进行相应的业务处理。
    Broker：无状态的服务层，负责接收消息、传递消息、集群负载均衡等操作。Broker 不会持久化保存元数据。
    BookKeeper：有状态的持久层，负责持久化地存储消息。
    ZooKeeper：存储 Pulsar、BookKeeper 的元数据，集群配置等信息，负责集群间的协调(例如：Topic 与 Broker 的关系)、服务发现等。
```

#### 可扩展
- Broker 扩展
```textmate
    Broker 是无状态的，当需要支持更多的消费者或生产者时，可以简单地添加更多的 Broker 节点来满足业务需求。
    Pulsar 支持自动的分区负载均衡，在 Broker 节点的资源使用率达到阈值时，会将负载迁移到负载较低的 Broker 节点，
    这个过程中分区也将在多个 Broker 节点中做平衡迁移，一些分区的所有权会转移到新的 Broker 节点。
```

- Bookie 扩展
```textmate
    存储层的扩容，通过增加 Bookie 节点来实现。在 BooKie 扩容的阶段，由于分片机制，整个过程不会涉及到不必要的数据搬迁，
    即不需要将旧数据从现有存储节点重新复制到新存储节点。
```

### 部署文档(docker单机部署)
```textmate
- 启动apachePulsar(单机)
docker run --name apachePulsar -dit -p 8080:8080 -p 6650:6650 apachepulsar/pulsar-standalone

- 启动管理平台
docker run --name apachePulsar-dashboard -dit -p 8081:80 -e SERVICE_URL=http://pulsar:8080 --link apachePulsar apachepulsar/pulsar-dashboard

- 测试消息发送
docker exec -it apachePulsar bash /pulsar/bin/pulsar-client produce my-topic --messages "hello-pulsar"

- 访问管理平台
http://localhost:8081/

```

### Java接入Pulsar
- [官网demo](https://pulsar.apache.org/docs/next/client-libraries-java)

### 相关网站
- [Apache Pulsar官网](https://pulsar.apache.org/)
- [Apache Pulsar配置详解](https://pulsar.apache.org/docs/next/reference-configuration)

