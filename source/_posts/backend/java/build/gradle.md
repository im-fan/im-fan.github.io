---
title: Gradle学习笔记
description: gradle
date: 2021-01-21 13:24:22
tags:
- 项目编译
categories:
- 后端
- 项目编译
---

- [Gradle理解：configuration、dependency](https://blog.csdn.net/gdeer/article/details/104815986)

### 关键字解释

|关键字|关键字解释|值|值解释|
|-|:-:|-|:-:|
|plugins||id||
|group|定义模块|||
|version|模块版本号|||
|sourceCompatibility||||
|configurations|不同的 configuration 用来引用不同领域</br>（或不同用途）的 dependencies|||
|buildscript|用于声明gradle自身依赖的插件，优先执行|ext||
|||repositories||
|||dependencies||
|allprojects|对所有project的配置,包括root project|repositories||
|subprojects|对所有Child Project的配置|||
|repositories|查找jar包顺序|||
|dependencies|定义依赖|||
|test|定义测试依赖信息|||


### dependencies依赖关键字

|3+|2.+|描述|
|-|-|:-:|
|implementation||所依赖的库仅可在当前module使用，编译速度快|
|api|compile|所依赖的库可在整工程使用，编译速度较implementation慢|
|provided|compileOnly|仅在编译时有效，不参与打包，一般在发布no jar的库时候会用到，很少用|
|apk|runtimeOnly|仅在生成apk的时候参与打包，编译时不参与|
|testImplementation|testCompile|仅在单元测试代码的编译以及最终打包测试apk时有效|
|debugImplementation|debugCompile|仅在debug模式的编译和最终的debug apk打包时有效|
|releaseImplementation|releaseCompile|仅在Release模式的编译和最终的Release apk打包时有效|


