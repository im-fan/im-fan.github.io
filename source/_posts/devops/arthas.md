---
title: Arthas-问题排查工具
date: 2021-10-13 09:17:00
tags:
- arthas
categories:
- 运维
---

## 介绍
```textmate
线上问题排查工具，无侵入；支持查看服务jvm信息、方法出入参数信息、接口耗时等
```

## 相关链接
- [官网](https://arthas.aliyun.com/doc/quick-start.html)
- [用户案例](https://github.com/alibaba/arthas/issues?q=label%3Auser-case)
- [常见问题回答](https://github.com/alibaba/arthas/issues?utf8=%E2%9C%93&q=label%3Aquestion-answered+)

## 安装启动

```textmate
1.arthas-boot方式安装
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar -h

-h: 打印帮助信息
```

## 常用命令

|命令名称|描述|示例|
|---|---|---|
|thread|查看当前线程信息，查看线程的堆栈|thread -n 3 指定最忙的前N个线程并打印堆栈<br/>thread -b 查找阻塞的线程|
|jvm|显示jvm信息||
|watch|方法执行数据观测|watch com.xxx.xxService 方法名 -x 3 (参数遍历深度3，默认1)|
|trace|方法内部调用路径，并输出方法路径上的每个节点上耗时|trace com.xxx.xxService 方法名|
|stack|输出当前方法被调用的调用路径|stack com.xxx.xxService 方法名|

## 完整命令介绍
> [完整命令详细文档](https://arthas.aliyun.com/doc/commands.html)

|命令名称|描述|示例|
|---|---|---|
|help|显示arthas帮助| |
|auth|验证当前会话| |
|keymap|显示指定连接的所有可用键图。| |
|sc|搜索JVM加载的所有类| |
|sm|搜索JVM加载的类的方法| |
|classloader|显示类加载器信息| |
|jad|反编译类| |
|getstatic|显示类的静态字段| |
|monitor|监控方法执行统计数据，例如总/成功/失败计数，平均rt，失败率等。 |  |
|stack|显示指定类和方法的堆栈跟踪| |
|thread|显示线程信息，线程堆栈| |
|trace|跟踪指定方法调用的执行时间。| |
|watch|显示指定方法调用的输入/输出参数、返回对象和抛出异常 | |
|tt|时间隧道| |
|jvm|显示目标JVM信息| |
|perfcounter|显示性能计数器信息。| |
|ognl|执行ognl表达式。| |
|mc|内存编译器，在内存中将java文件编译成字节码和类文件。| |
|redefine|重新定义类。@see仪表# redefineClasses (ClassDefinition…) | |
|retransform|使变回原形类。@see仪表# retransformClasses(类…) | |
|dashboard|目标jvm的线程，内存，gc, vm, tomcat信息的概述。 | |
|dump|从JVM中转储类字节数组| |
|heapdump|堆转储| |
|options|查看和改变各种阿尔萨斯选项| |
|cls|清理屏幕信息| |
|reset|重置所有增强类| |
|version|显示arthas版本| |
|session|显示当前会话信息| |
|sysprop|显示和更改系统属性。| |
|sysenv|显示系统env。| |
|vmoption|显示和更新虚拟机诊断选项。| |
|logger|打印记录器信息，并更新记录器级别| |
|history|显示命令历史| |
|cat|连接和打印文件| |
|base64|使用Base64表示进行编码和解码| |
|echo|将参数写入标准输出| |
|pwd|返回工作目录名| |
|mbean|显示mbean信息| |
|grep|用于管道的Grep命令。| |
|tee|tee命令用于管道。| |
|profiler|异步分析器。https://github.com/jvm-profiling-tools/async-profiler| |
|vmtool|jvm的工具| |
|stop|停止/关闭Arthas服务器并退出控制台。| |
