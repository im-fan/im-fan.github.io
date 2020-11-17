---
title: OAuth2学习笔记
description: oauth2
date: 2020-11-17 09:58:26
tags:
- oauth2
categories:
- 架构
---

- [参考demo](https://github.com/lexburner/oauth2-demo)
- [OAuth2 RFC6749中文翻译](https://colobu.com/2017/04/28/oauth2-rfc6749/)
- [理解OAuth 2.0-阮一峰](http://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)
- [文档对应demo](https://github.com/im-fan/my-project/tree/release/1.0/my-oauth2)

#### 框架相关
- OAuth2
```text
解释：
    OAuth 2.0是一个关于授权的开放网络协议，它允许用户让第三方网站访问该用户在某一网站上存储的信息和资源，
    如账户信息，照片，联系人等，而不需要给第三方网站提供某一网站上的账户和密码。
流程：
    1、用户打开客户端，客户端要求授权。
    2、用户同意客户端授权。
    3、客户端使用上一步提供的授权，向服务器授权层申请令牌。
    4、授权服务器对客户端进行认证后，同意发放令牌。
    5、客户端使用令牌，向资源服务器申请资源。
    6、资源服务器确认令牌，向客户端开放资源。
```
- LDAP
```text
解释：
    LDAP是一种基于轻量目录访问协议，全称是Lightweight Directory Access Protocol，是由一个为查询、
    浏览和搜索而优化的数据库构成，它成树状结构组织数据，类似文件目录一样。
    LDAP单点登录认证主要是改变原有的认证策略，使得需要的软件都通过LDAP服务器进行认证，在统一身份认证后，
    用户的所有信息都存储在AD Server中，终端用户在需要使用公司内部服务的时候，都需要通过AD服务器进行认证。
登录流程：
    1、连接到LDAP服务器。
    2、绑定到LDAP服务器。
    3、在LDAP服务器上执行所需要的操作。
    4、释放LDAP服务器的连接。
```
- [CAS(Central Authentication Service-中央式认证服务)](https://www.cnblogs.com/lihuidu/p/6495247.html)
```text
SSO 仅仅是一种架构，一种设计，而 CAS 则是实现 SSO 的一种手段。两者是抽象与具体的关系。
CAS即Central Authentication Service模型（中央式认证服务），该协议是为应用提供可信身份认证的单点登录系统，最初是由耶鲁大学开发的。
CAS 包含两个部分： CAS Server 和 CAS Client。CAS Server 需要独立部署，主要负责对用户的认证工作；CAS Client 负责处理对客户端受保护资源的访问请求，需要登录时，重定向到 CAS Server。
```
- 适用场景
```text
OAuth协议能广泛应用于互联网中，基于大企业的巨大用户量，能减少小网站的注册推广成本，并且能做到更加便捷的资源共享。
LDAP协议适用于企业用户使用，通过LDAP协议，能较好地管理员工在公司各系统之间的授权与访问。
CAS模型，作为权威机构开发的系统，具有很好的兼容性与安全性，广泛应用于各大高校等大型组织，能很好地完成大量系统的对接与大量人员的使用。
```

#### 授权模式
- 授权码模式（authorization code）
```text
功能最完整、流程最严密的授权模式。它的特点就是通过客户端的后台服务器，与"服务提供商"的认证服务器进行互动。
```
- 简化模式（implicit）

- 密码模式（resource owner password credentials）
- 客户端模式（client credentials）

- 主要配置
```text
Oauth2ServerConfig
WebSecurityConfigurer
```

#### 不同授权模式请求
- 授权码模式(在浏览器中访问接口)
```text
配置项：需要将返回地址添加到client中
    clients.redirectUris("http://www.baidu.com")

http://localhost:8200/oauth/authorize?response_type=code&client_id=client_1&redirect_uri=http://www.baidu.com&state=123

所需参数解释
    response_type：表示授权类型，必选项，此处的值固定为"code"
    client_id：表示客户端的ID，必选项
    redirect_uri：表示重定向URI，可选项
    scope：表示申请的权限范围，可选项
    state：表示客户端的当前状态，可以指定任意值，认证服务器会原封不动地返回这个值。

```

- 简化模式(在浏览器中访问接口)
```text
http://localhost:8200/oauth/authorize?response_type=token&client_id=client_1&redirect_uri=http://www.baidu.com&state=123&scope=select

参数解释：
    response_type：表示授权类型，此处的值固定为"token"，必选项。
    client_id：表示客户端的ID，必选项。
    redirect_uri：表示重定向的URI，可选项。
    scope：表示权限范围，可选项。
    state：表示客户端的当前状态，可以指定任意值，认证服务器会原封不动地返回这个值。
```

- password方式获取toke
```text
POST http://localhost:8200/oauth/token?grant_type=password&scope=select&client_id=client_1&client_secret=123456&username=user_1&password=123456

{
    "access_token": "39be5ea6-fdcd-4b15-a4dd-1f3dbaf8fc63",
    "token_type": "bearer",
    "refresh_token": "396e6c5e-9d79-420a-8b25-945098b10c82",
    "expires_in": 43021,
    "scope": "select"
}

参数解释
    grant_type：表示授权类型，此处的值固定为"password"，必选项。
    username：表示用户名，必选项。
    password：表示用户的密码，必选项。
    scope：表示权限范围，可选项。

```

- client方式获取access_token
```text
POST http://localhost:8200/oauth/token?grant_type=client_credentials&scope=select&client_id=client_2&client_secret=123456

{
    "access_token": "17fc17a9-83b2-41c3-8621-c727d8329bbd",
    "token_type": "bearer",
    "expires_in": 42400,
    "scope": "select"
}

参数解释
    granttype：表示授权类型，此处的值固定为"clientcredentials"，必选项。
    scope：表示权限范围，可选项。

```


- 刷新token
```text
POST http://localhost:8200/oauth/token?grant_type=refresh_token&refresh_token=396e6c5e-9d79-420a-8b25-945098b10c82&client_id=client_2&client_secret=123456

{
    "access_token": "e0e64627-f157-4718-81f0-069ca21549ad",
    "token_type": "bearer",
    "refresh_token": "396e6c5e-9d79-420a-8b25-945098b10c82",
    "expires_in": 43199,
    "scope": "select"
}

```

#### 请求业务接口
- 请求接口
```text
配置拦截：
    HttpSecurity中配置 http.antMatchers("/user/**").authenticated()

使用client方式获取的access_token
GET http://localhost:8200/user/info?access_token=d8f47460-c0a6-4247-9f87-1712bae5325e

返回结果
```