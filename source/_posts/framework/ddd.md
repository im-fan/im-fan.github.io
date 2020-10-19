---
title: ddd
description: ddd
top: 1
date: 2020-10-09 16:51:54
tags:
- DDD
categories:
- 架构
- DDD
---


### 方法论
```text
六边形架构、洋葱架构、整洁架构

SIDE-EFFECT-FREE模式被称为无副作用模式，熟悉函数时编程的朋友都知道，严格的函数就是一个无副作用的函数，对于一个给定的输入，总是返回固定的结果，通常查询功能就是一个函数，命令功能就不是一个函数，它通常会执行某些修改。

在DDD架构中，通常会将查询和命令操作分开，我们称之为CQRS(命令查询的责任分离Command Query Responsibility Segregation)，具体落地时，是否将Command和Query分开成两个项目可以看情况决定，大多数情况下放在一个项目可以提高业务内聚性，
```