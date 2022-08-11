---
title: Oauth2
description: 鉴权框架 
date: 2020-11-08 10:37:12
tags:
- oauth2
categories:
- 后端
- 安全
---

### 安全框架
- [SpringSecurity](https://docs.spring.io/spring-security/site/docs/4.1.0.RELEASE/reference/htmlsingle/#what-is-acegi-security)
- [Oauth2](https://oauth.net/2/)
- [LDAP](http://www.ldap.org.cn/)

### 自定义获取token逻辑
- 添加配置
```textmate
在自定义AuthorizationServerConfigurerAdapter的继承类中，添加配置
endpoints.pathMapping("/oauth/token", "/my/login");
```
- Controller
```java
class UserController{
    /**
     * 只有映射的接口，security框架才会将principal信息填充进去
     * parameters: 生成token所需的入参; 
     * principal: 安全框架所需用户信息
     */
    @ApiOperation(value = "获取token接口", notes = "用于获取token接口")
    @PostMapping(value = "/my/login")
    public Result<LoginReslut> login(@RequestParam Map<String, String> parameters,
                                Principal principal){
        return xxx;
    }
}
```
