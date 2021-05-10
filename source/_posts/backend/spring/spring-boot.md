---
title: SpringBoot
date: 2021-03-22 09:44:01
tags:
- springboot
categories:
- 框架
- springboot
---

### 文章收集
- [SpringBoot启动过程(转)](https://www.jianshu.com/p/603d125f21b3)
- [流程图(转)](https://www.processon.com/view/link/59812124e4b0de2518b32b6e)
- [@RefreshScope原理](https://blog.csdn.net/youanyyou/article/details/103562907)

### 集成PageHelper
- 配置
```pom
<!--基础框架包-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>2.3.4.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-dependencies</artifactId>
    <version>Hoxton.SR8</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
<!--page helper依赖-->
<!-- https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper-spring-boot-starter -->
<dependency>
    <groupId>com.github.pagehelper</groupId>
    <artifactId>pagehelper-spring-boot-starter</artifactId>
    <version>1.3.0</version>
</dependency>
```

- 使用
```java
class XXService{
    public Result list(QueryParam param){
        PageMethod.startPage(param.getPageNumber(),param.getPageSize());
        List result = mapper.list(param);
        PageInfo pageInfo = new PageInfo(result);
        return PageDTO.result(pageInfo.getTotal(),result);
    }
}
```
- 注意事项
```textmate
1.注意pom版本号
2.使用pagehelper-spring-boot-starter pom后，不需要在yml中配置pagehelper相关参数，否则分页会有问题(亲测)
  例如: 永远只在第一页
```
