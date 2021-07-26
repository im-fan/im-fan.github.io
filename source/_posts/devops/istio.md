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
