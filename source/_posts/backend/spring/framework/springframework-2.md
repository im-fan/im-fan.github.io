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
```textmate
根据包扫描对象
```
- RootBeanDefinition
```textmate
记录扫描到的类的具体信息(描述类)
```
- BeanFactoryPostProcessor
```textmate
接口，可自定义参与类初始化过程逻辑
	工厂钩子，允许自定义修改应用程序上下文的 bean 定义，调整上下文底层 bean 工厂的 bean 属性值。
	BeanFactoryPostProcessor是在spring容器加载了bean的定义文件之后，在bean实例化之前执行的。接口方法的入参是ConfigurrableListableBeanFactory，使用该参数，可以获取到相关bean的定义信息
```
- BeanPostProcessor
```textmate
后置处理器父类，有很多子类；不同子类提供了不同的实现方法，参与到bean初始化过程中
	例：AutowiredAnnotationBeanPostProcessor
	可以在spring容器实例化bean之后，在执行bean的初始化方法前后，添加一些自己的处理逻辑。
	BeanPostProcessor的执行顺序是在BeanFactoryPostProcessor之后。
	内置实现: 
	org.springframework.context.annotation.CommonAnnotationBeanPostProcessor：支持@Resource注解的注入
    org.springframework.beans.factory.annotation.RequiredAnnotationBeanPostProcessor：支持@Required注解的注入
    org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor：支持@Autowired注解的注入

```
### 简易流程
```textmate
scan -> beanPorcessor(描述bean信息) -> 放到 configMap 中 -> refresh -> 通过bean工厂实例化类 -> 放到单例池中
```
### AnnotationConfigApplicationContext详解
- 类图
  ![类图](https://img-blog.csdnimg.cn/20210706100541307.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0Rlc3Ryb3llcl9EcmVhbQ==,size_16,color_FFFFFF,t_70#pic_center)
- 流程图
  ![执行流程](https://img-blog.csdnimg.cn/20210706100708794.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0Rlc3Ryb3llcl9EcmVhbQ==,size_16,color_FFFFFF,t_70#pic_center)


### 解决循环依赖
- [疯狂创客圈(转)](https://www.cnblogs.com/crazymakercircle/p/14465630.html)
- 主要流程图
  ![spring解决循环依赖流程(转)](https://gitee.com/im-fan/fan-pic/raw/master/images/spring-cycle-refrence.png)
