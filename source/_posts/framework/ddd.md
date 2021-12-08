---
title: DDD-领域驱动设计
description: DDD-领域驱动设计
#top: 1
date: 2020-10-09 16:51:54
tags:
- DDD
categories:
- 架构
---

- [有赞DDD实践](https://mp.weixin.qq.com/s/9eGZZ2wsZoaCVRy0oKt0iw)
- [DDD设计](https://www.processon.com/view/5e55d17ee4b069f82a120d06#map)
- [阿里技术专家详解 DDD 系列- Domain Primitive](https://segmentfault.com/a/1190000020270851?utm_source=tag-newest)

### 方法论
```textmate
六边形架构、洋葱架构、整洁架构、四色原型
SIDE-EFFECT-FREE模式被称为无副作用模式，熟悉函数时编程的朋友都知道，严格的函数就是一个无副作用的函数，对于一个给定的输入，总是返回固定的结果，通常查询功能就是一个函数，命令功能就不是一个函数，它通常会执行某些修改。
在DDD架构中，通常会将查询和命令操作分开，我们称之为CQRS(命令查询的责任分离Command Query Responsibility Segregation)，具体落地时，是否将Command和Query分开成两个项目可以看情况决定，大多数情况下放在一个项目可以提高业务内聚性，
```

#### 六边形架构
- [起源文章](http://alistair.cockburn.us/Hexagonal+architecture)
- [相关文章&demo](https://www.jianshu.com/p/c6bb08d9c613)
- 摘要
```textmate
六角架构的初衷是：
允许应用程序同样由用户，程序，自动化测试或批处理脚本驱动，并与最终的运行时设备和数据库隔离开发和测试。
```

#### 洋葱架构
- [在洋葱(Onion)架构中实现领域驱动设计](https://www.infoq.cn/article/2014/11/ddd-onion-architecture)
- 摘要
```textmate
层级关系
    Core ) Domain ) API ) Infrastructure )
洋葱架构中的一个重要概念是依赖，外部的层能够访问内部的层，而内部的层则对外部的层一无所知。
    核心（Core）层是与领域或技术无关的基础构件块，它包含了一些通用的构件块,包含任何技术层面的概念
    领域（Domain）层是定义业务逻辑的地方，每个类的方法都是按照领域通用语言中的概念进行命名的
    API 层是领域层的入口，它使用领域中的术语和对象。
    基础架构（Infrastructure）层是最外部的一层，它包含了对接各种技术的适配器，例如数据库、用户界面以及外部服务。
```

#### 整洁架构
- [阿里云-架构整洁之道](https://www.jianshu.com/p/b296ceea673b)

#### 开源框架
- cola4 
- DDDLib  
- Koala

#### 四色原型-需求分析利器
<img src="https://im-fan.gitee.io/img/ddd/four-color.png"/>

```textmate
概念
    “四色原型”是在使用UML建模的时候，把实体分为四类，并标注不同的颜色的一种建模方法。
    用一句话来概括四色原型就是：一个什么样的人或物品以某种角色在某个时刻或某段时间内参与某个活动。其中“什么样的”就是DESC，“人或物品”就是PPT,”角色”就是ROLE,而“某个时刻或某个时间段内的某个活动”就是MI。
    四色原型”有一个规则：就是MI（事件）不能与PPT（事物）直接打交道，必须通过ROLE（角色）来打交道。例如：只有买家才能下订单，订单只能通过买家与用户关联
四色建模法包括
    时标型（Moment-Interval）对象：具有可追溯性的记录运营或管理数据的时刻或时段对象，用粉红色表示
    PPT（Party/Place/Thing）对象：代表参与到流程中的参与方/地点/物，用绿色表示
    角色（Role）对象：在时标型对象与 PPT 对象（通常是参与方）之间参与的角色，用黄色表示
    描述（Description）对象：对 PPT 对象的一种补充描述，用蓝色表示
四色原型法设计领域模型的步骤：
    1.根据需求，采用四色原型分析法建立一个初步的领域模型；
    2.进一步分析领域模型，识别出哪些是实体，哪些是值对象，哪些是领域服务；
    3.对实体、值对象进行关联和聚合，提炼出聚合边界和聚合根；
    4.为聚合根设计仓储（一般情况下，一个聚合分配一个仓储），同时，思考实体、值对象的创建方式，是通过工厂创建，还是直接通过构造函数；
    5.走查需求场景，验证设计的领域模型的合理性。
```
#### 标准项目模块解释
```textmate
1.Interface 
    对外提供服务，包括Controller、防腐层-facade、对象转换-assembler、出参入参对象-dto
2.Application 
    应用层,包括服务层-service(主要作用是操作 聚合根+仓储)
3.Domain
    领域层,包括领域对象-entity(主要业务逻辑，可以理解为对象封装操作)、领域服务-EntityService(不属于任何一个领域对象的其他业务或复杂业务逻辑)、值对象-ValueObjects 领域事件-DomainEvent、仓储接口定义-repository
4.Infrastructure
    基础设施层,包括持久化设置-PersistenceFacilities(仓储实现)、工具类等；支持以上模块
```

### DDD核心概念
- 实体
- 值对象
- 聚合
- 仓储
- 工厂
- 仓储
```textmate
实体(Entities):具有唯一标识的对象
值对象(Value Objects): 无需唯一标识的对象
领域服务(Domain Services): 一些行为无法归类到实体对象或值对象上,本质是一些操作,而非事物
聚合/聚合根(Aggregates,Aggregate Roots): 聚合是指一组具有内聚关系的相关对象的集合,每个聚合都有一个root和boundary
工厂(Factories): 创建复杂对象,隐藏创建细节
仓储(Repository): 提供查找和持久化对象的方法
```

- DDD架构图
<img src="https://im-fan.gitee.io/img/ddd/ddd-framework.png"/>

#### 识别领域服务
```textmate
主要看它是否满足以下三个特征：
    1. 服务执行的操作代表了一个领域概念，这个领域概念无法自然地隶属于一个实体或者值对象。
    2. 被执行的操作涉及到领域中的其他的对象。
    3. 操作是无状态的。
```

#### 仓储相关
- CQRS
```textmate
将查询单独划分为应用系统的一个分支，将修改（命令）单独划分为另外一个分支来操作领域对象。这是DDD的另外一种模式，英文简写：CQRS
```
