---
title: 调用链监控-skywalking
date: 2021-05-19 16:52:25
tags:
- skywalking 
categories:
- 运维
---

- [官网](http://skywalking.apache.org/)
- [下载地址](http://skywalking.apache.org/downloads/)
- [部署及使用文档(转)](https://www.jianshu.com/p/8b9aad4210c5)

### 常见问题
- 重启
```textmate
原脚本中没有杀掉旧进程，使用jps找到对应服务，然后kill掉再执行bin/startup.sh
```
- 支持SpringCloudGateway
```textmate
默认情况agent是不支持对spring-cloud-gateway的监控的，需要插件的支持。我们要将optional-plugins下的插件apm-spring-cloud-gateway-2.x-plugin-6.5.0.jar拷贝到plugins下
```
