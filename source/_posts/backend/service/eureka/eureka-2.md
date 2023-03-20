---
title: Eureka源码学习笔记(二)
description: eureka
date: 2023-03-16 17:10
tags:
- eureka
- 注册中心
categories:
- 后端
- 服务治理
---
> Client注册、服务信息同步、Server端收到续约心跳请求的处理细节

# 一、Client注册分析
## 1.入口类
```java
@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties
@ConditionalOnClass(EurekaClientConfig.class)
@ConditionalOnProperty(value = "eureka.client.enabled", matchIfMissing = true)

/** 
 * spring.cloud.discovery.enabled=true才生效，配置默认为true
 * */
@ConditionalOnDiscoveryEnabled
@AutoConfigureBefore({ 
        NoopDiscoveryClientAutoConfiguration.class,
        /** 初始化客户端健康状况指示器: 初始化状态、启动状态 */
        CommonsClientAutoConfiguration.class, 
        ServiceRegistryAutoConfiguration.class })

/** 自动注入完成后，注入这些信息 */
@AutoConfigureAfter(name = {
        "org.springframework.cloud.netflix.eureka.config.DiscoveryClientOptionalArgsConfiguration",
        
        /** 自动刷新配置 */
        "org.springframework.cloud.autoconfigure.RefreshAutoConfiguration",
        /** client服务发现配置 */
        "org.springframework.cloud.netflix.eureka.EurekaDiscoveryClientConfiguration",
        /** 服务自动注册配置 */
        "org.springframework.cloud.client.serviceregistry.AutoServiceRegistrationAutoConfiguration" })
public class EurekaClientAutoConfiguration {

    /** client配置bean */
    @Bean
    @ConditionalOnMissingBean(value = EurekaClientConfig.class,
            search = SearchStrategy.CURRENT)
    public EurekaClientConfigBean eurekaClientConfigBean(ConfigurableEnvironment env) {
        return new EurekaClientConfigBean();
    }

    /** 获取eureka.instance开头的配置,封装到EurekaInstanceConfigBean类中 */
    @Bean
    @ConditionalOnMissingBean(value = EurekaInstanceConfig.class,
            search = SearchStrategy.CURRENT)
    public EurekaInstanceConfigBean eurekaInstanceConfigBean(
            InetUtils inetUtils,
            ManagementMetadataProvider managementMetadataProvider) {
     //...   
    }

    /** 初始化eurekaService注册器，提供register、deregister */
    @Bean
    public EurekaServiceRegistry eurekaServiceRegistry() {
        return new EurekaServiceRegistry();
    }
    
    /** 自动注册逻辑
     * 提供start、stop方法
     * */
    @Bean
    @ConditionalOnBean(AutoServiceRegistrationProperties.class)
    @ConditionalOnProperty(
            value = "spring.cloud.service-registry.auto-registration.enabled",
            matchIfMissing = true)
    public EurekaAutoServiceRegistration eurekaAutoServiceRegistration(
            ApplicationContext context, EurekaServiceRegistry registry,
            EurekaRegistration registration) {
        return new EurekaAutoServiceRegistration(context, registry, registration);
    }
}
```

- 总结
```textmate
1：项目启动
2：初始化配置EurekaClientAutoConfiguration->eurekaInstanceConfigBean
3：构造EurekaClient对象（内部类EurekaClientAutoConfiguration：：RefreshableEurekaClientConfiguration）
    3.1：构造心跳任务线程池
    3.2：构造缓存刷新任务线程池
4：启动定时任务（心跳+缓存刷新）
    4.1：启动缓存刷新定时任务
    4.2：启动心跳定时任务
    4.3：启动instanceInfoReplicator线程，执行注册任务
5：服务启动时，会延迟40秒向注册中心注册
6：心跳时间默认是30秒，可通过eureka.instance.lease-renewal-interval-in-seconds修改

```

# 二、服务信息同步分析

# 三、服务心跳续约分析
