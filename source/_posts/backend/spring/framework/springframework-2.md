---
title: SpringFramework源码学习
date: 2021-07-26 15:05:00
tags:
- SpringFramework
categories:
- 后端
- 框架
- springframework
---

### StartDemo
```java
public class StartDemo {
   public static void main(String[] args) {
      ApplicationContext context =
            new AnnotationConfigApplicationContext("com.my.config");
      TestConfig testConfig = context.getBean(TestConfig.class);
      System.out.println("==========>main");
      System.out.println(testConfig.getValue());
   }
}
```
### 关键类
- AnnotationConfigApplicationContext
```text
根据包扫描对象
```
- RootBeanDefinition
```text
记录扫描到的类的具体信息(描述类)
```
- BeanFactoryPostProcessor
```text
接口，可自定义参与类初始化过程逻辑
	工厂钩子，允许自定义修改应用程序上下文的 bean 定义，调整上下文底层 bean 工厂的 bean 属性值。
```
- BeanPostProcessor
```text
后期处理器父类，有很多子类；不同子类提供了不同的实现方法，参与到bean初始化过程中
	例：AutowiredAnnotationBeanPostProcessor
```
### 大体流程
```textmate
scan -> beanPorcessor(描述bean信息) -> 放到 configMap 中 -> refresh -> 通过bean工厂实例化类 -> 放到单例池中
```
### AnnotationConfigApplicationContext详解
- 类图
  ![类图](https://img-blog.csdnimg.cn/20210706100541307.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0Rlc3Ryb3llcl9EcmVhbQ==,size_16,color_FFFFFF,t_70#pic_center)
- 流程图
  ![执行流程](https://img-blog.csdnimg.cn/20210706100708794.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0Rlc3Ryb3llcl9EcmVhbQ==,size_16,color_FFFFFF,t_70#pic_center)
