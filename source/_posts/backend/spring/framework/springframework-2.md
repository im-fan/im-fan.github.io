---
title: SpringFramework源码学习
date: 2021-07-26 15:05:00
tags:
- SpringFramework
categories:
- 后端
- 框架
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
生命周期 加载 -> 实例化 -> 初始化 -> 使用 -> 销毁
scan -> beanPorcessor(描述bean信息) -> 放到 configMap 中 -> refresh -> 通过bean工厂实例化类 -> 放到单例池中
```
### AnnotationConfigApplicationContext详解
- 类图
  ![类图](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/springframework-bean-uml.png)
- 流程图
  ![执行流程](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/spring-start-process.png)


### 解决循环依赖
- [疯狂创客圈(转)](https://www.cnblogs.com/crazymakercircle/p/14465630.html)
- 主要流程图
  ![spring解决循环依赖流程(转)](https://raw.githubusercontent.com/im-fan/fan-pic/release/images/spring-cycle-refrence.png)

- 解释
```textmate
1.三级缓存中分别存放的是什么？
  一级缓存存放实例化完成，且属性填充后的对象。
  二级缓存存放对象实例化完成后，还没有填充完属性值的对象。
  三级缓存存放的是工厂对象。存放实例化对象所需要的工厂。

2.如果只有一级缓存行不行？
    不行，因为完整的对象会和未初始化的对象放到一起，在进行获取的时候有可能会获取到为初始化的对象，对象是无法使用的；

3.如果只有二级缓存行不行？
    只要有二级缓存可以解决循环依赖问题，但是添加aop的实现之后，会报错。

4.三级缓存到底做了什么事情？
    在三级缓存中完成了代理对象替换非代理对象的工作。
    三级缓存是为了解决在aop代理过程中产生的循环依赖问题，如果没有aop的话，二级缓存可以解决循环依赖问题。
```
- [三级缓存参考资料](https://blog.csdn.net/weixin_44390164/article/details/119350651)
