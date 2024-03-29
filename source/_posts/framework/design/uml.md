---
title: 技术文档
description: 技术文档
date: 2020-12-25 18:57
tags:
- 技术文档
categories:
- 架构
---

## 技术文档设计
### 文档格式
- 文档版本
- 参考资源
  - 相关文档地址
  - 关键名词解释
- 背景及目标
- 系统设计
  - 系统架构图(可选)
  - 组件关系图(可选)
  - 用例图
  - 流程图
  - 时序图
  - 状态图(可选)
  - 领域建模
  - ER图

## UML图相关
### 常用元素
```textmate
1.类
  用三层矩形框表示，第一层类名及解释(斜体表示抽象类)、第二层字段和属性、第三层方法
  前面的符号，‘+’表示public，‘-’表示private，‘#’表示protected。
2.接口
  用两层矩形框表示，第一层接口名及解释、第二层方法
```

### 常见的几种关系
```textmate
1.泛化(Generalization)
    表示继承。是is-a的关系。 用 空心三角箭头+实线 表示，箭头指向继承的类
2.依赖(Dependency)
    是一种类与接口的关系，表示类是接口所有特征和行为的实现. 空心三角箭头+虚线 箭头指向接口
3.关联(Association)
    描述类与类之间的连接，是has­-a的关系。它使一个类知道另一个类的属性和方法; 实心三角箭头+实线，两边关联则有两个箭头
4.聚合(Aggregation)
    是整体与部分的关系，且部分可以离开整体而单独存在。空心菱形+实线，菱形指向整体
5.组合(Composition)
    是整体与部分的关系，但部分不能离开整体而单独存在。实心菱形+实线，菱形指向整体
6. 实现(Realization)
    是一种类与接口的关系，表示类是接口所有特征和行为的实现。空心三角箭头+虚线，箭头指向接口

基数: 线两端的数字表明这一端的类可以有几个实例，比如：一个鸟应该有两只翅膀。如果一个类可能有无数个实例，则就用‘n’来表示。关联、聚合、组合是有基数的。
```
<img src="https://im-fan.gitee.io/img/uml/uml-line.png" width="500" height="300"/>

### 示例-标识了所有关系
<img src="https://im-fan.gitee.io/img/uml/uml.png"/>


## 设计工具
### 在线版
- [Processon-推荐](https://www.processon.com/)
- [Draw.io](https://app.diagrams.net/)
- [Visual-Paradigm](https://online.visual-paradigm.com/cn/drive/#diagramlist:proj=0&new)

### 软件
- VisualParadigm(功能强大，相比其他软件样式可能有点丑)
- draw.io(简单易用，样式美观)

