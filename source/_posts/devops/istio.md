---
title: istio
date: 2021-05-18 16:30:00
tags:
- istio 
categories:
- 运维
---

- [官网](https://istio.io/latest/zh/docs/examples/bookinfo/)
- [istio性能测试](https://www.jianshu.com/p/1f3f62ce3ea9)

### 核心组件-V1.5之前
#### 1.数据平面
> [Envoy官网](https://www.envoyproxy.io/)
```textmate
Istio 的数据平面主流选用 Lyft 的 Envoy，当然也可以选择其他的数据平面，例如 MOSN。
Envoy提供了动态服务发现、负载均衡、TLS、HTTP/2及GRPC代理、熔断器、健康检查、流量拆分、灰度发布、故障注入等功能
```

#### 2.Pilot
```textmate
Istio 的核心组件，主要负责核心治理、流量控制、将配置转换为数据平面可识别的 xDS 协议分发配置到数据平面
比如：A/B测试、金丝雀发布一些相关配置的
```

#### 3.Citadel
```textmate
可选开启或关闭，负责安全相关的证书和密钥管理。
```

#### 4.Galley
```textmate
用于配置、验证、注入、处理和分发组件的。作为sidecar代理的分发以及注入等相关管理的。
```

#### 5.Mixer
```textmate
默认关闭，负责提供策略控制和遥测收集的组件，内部包含 Policy 和 Telemetry 2个子模块；
Policy 负责在服务相互调用过程中对请求进行策略检查，例如鉴权、限流，
Telemetry 负责监控相关的采集数据的信息聚合以用于对接各种后端。
```

#### 6.Injector
```textmate
负责数据平面的初始化相关的动作，例如自动注入 sidecar 就是使用该组件完成的。
```

### 核心组件-V1.5及以后
> 简单地说，只是将原有的多进程设计模式优化成了单进程的形态，之前各个组件被设计成了 istio 的内部子模块而已


### 流量管理
- 配置基本请求路由
```yaml
spec:
  hosts:
    - reviews
  http:
    - route:
        - destination:
            host: reviews
            subset: v1
```

- 按照请求头中用户信息过滤
```yaml
spec:
  hosts:
    - reviews
  http:
    - match:
        - headers:
            end-user:
              exact: jason
      route:
        - destination:
            host: reviews
            subset: v2
    - match:
        - headers:
            end-user:
              exact: aaa
      route:
        - destination:
            host: reviews
            subset: v2
    - route:
        - destination:
            host: reviews
            subset: v3
```

- 故障注入-延迟(jason登录，访问6s后页面才加载出来)
```yaml
spec:
  hosts:
    - ratings
  http:
    - fault:
        delay:
          fixedDelay: 7s # 7s延迟
          percentage:
            value: 100
      match:
        - headers:
            end-user:
              exact: jason
      route:
        - destination:
            host: ratings
            subset: v1
    - route:
        - destination:
            host: ratings
            subset: v1
```

- 故障注入-异常(jason登录，50几率访问返回500)
```yaml
spec:
  hosts:
  - ratings
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    fault:
      abort:
        percentage:
          value: 50
        httpStatus: 500 #注入500错误
    route:
    - destination:
        host: ratings
        subset: v1
  - route:
    - destination:
        host: ratings
        subset: v1
```

- 流量转移
```yaml
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50
```

- 设置请求超时(2s延迟)
```yaml
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 100
        fixedDelay: 2s
    route:
    - destination:
        host: ratings
        subset: v1
```
