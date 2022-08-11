---
title: SPI-Java内置服务发现机制
description: 解析swagger-ui
date: 2020-11-11 19:30
tags:
- SPI
categories:
- 后端
---

## SPI案例
> JavaSPI实现,另外还有DubboSPI、SpringSPI等实现

### JavaSPI
```textmate
java.util.ServiceLoader类解析classPath和jar包的META-INF/services/目录 下的以接口全限定名命名的文件，并加载该文件中指定的接口实现类，以此完成调用
缺点：
    1.配置文件只能放在 META-INF/services/ 目录下
    2.使用扩展类不方便，不支持服务提供接口实现类的直接访问
```

### DubboSPI
```textmate
1.@SPI注解修饰定义的扩展接口
2.扩展类加载器：ExtensionLoader，相当于JavaSPI的 ServiceLoader
3.支持多扩展路径
    META-INF/dubbo/internal    //用来加载Dubbo内部的扩展点
    META-INF/dubbo   //对开发者开放
    META-INF/services   //兼容Java SPI
4.每个扩展路径指定加载器
    DubboInternalLoadingStrategy
    DubboLoadingStrategy
    ServicesLoadingStrategy
5.扩展配置文件
    支持别名引用
    例如:  mysql=com.xxx.support.MySQLConfig

Dubbo中对SPI的应用很广泛，如：序列化组件、负载均衡等都应用了SPI技术，还有很多SPI功能，比如：自适应扩展、Activate活性扩展等等
```

#### JavaSPI和DubboSPI差异点
```textmate
相同：
    扩展点即服务提供接口、扩展即服务提供接口实现类、扩展配置文件即services目录下的配置文件 三者相同。
    都是先创建加载器然后访问具体的服务实现类，包括深层次的在初始化加载器时都未实时解析扩展配置文件来获取扩展点实现，而是在使用时才正式解析并获取扩展点实现(即懒加载)。

不同：
    扩展点必须使用@SPI注解修饰(源码中解析会对此做校验)。
    Dubbo中扩展配置文件每个扩展(服务提供接口实现类)都指定了一个名称。
    Dubbo SPI在获取扩展类实例时直接通过扩展配置文件中指定的名称获取，而非Java SPI的循环遍历，在使用上更灵活。
```

#### SpringSPI
```textmate
1.加载路径
    META-INF/spring.handlers  //可以通过创建实例时重新指定
    META-INF/spring.factories

2.加载类 
    SpringFactoriesLoader 类似于Java SPI的ServiceLoader，负责解析spring.factories，并将指定接口的所有实现类实例化后返回。
    DefaultNamespaceHandlerResolver 类似于Java SPI的ServiceLoader，负责解析spring.handlers配置文件，生成namespaceUri和NamespaceHandler名称的映射，并实例化NamespaceHandler。
    
3.解析handlers扩展类-虚继承抽象类
    NamespaceHandlerSupport
    DefaultNamespaceHandlerResolver是NamespaceHandlerResolver接口的默认实现类，用于解析自定义标签。
4.解析spring.factories扩展类
    SpringFactoriesLoader.loadFactories()  //类似JavaSPI
```

### 参考文档
- [vivo技术博客-SpringSPI](https://zhuanlan.zhihu.com/p/529674338)
