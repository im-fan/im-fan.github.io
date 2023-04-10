---
title: 线上问题处理过程-ES
date: 2023-03-29 10:30:00
tags:
- 线上问题
- elasticsearch
categories:
- 线上问题
---

## 现象
- 接口告警群抛出接口调用异常
- APP首页无数据
- 阿里云ElasticSearch的监控平台，发现服务CPU占用过高，有慢查询

## 排查
- 看arms上有调用es服务的服务接口耗时情况，查找引起cpu过高的原因

## 解决
- 先临时下掉耗时久的接口
- es按接口重启
- 服务中es连接配置设置读取超时时间

## 相关文档
- [Elasticsearch High Level Rest Client偶现访问集群超时的问题定位与解决](https://cloud.tencent.com/developer/article/1943055)
