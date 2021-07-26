---
title: SpringClougGateway
date: 2021-06-15 14:16:00
tags:
- gateway
categories:
- 框架
- springcloud
---

### 文章收集
- [SpringCloudGateway-2.1.0.RC3](https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.1.0.RC3/multi/multi_spring-cloud-gateway.html)
- [SpringCloudGateway官网](https://spring.io/projects/spring-cloud-gateway)
- [SpringCloudGateway(读取、修改RequestBody)(转)](https://www.haoyizebo.com/posts/876ed1e8/)

### 配置
```yaml
spring:
  application:
    name: cloud-gateway
  cloud:
    httpclient:
      connect-timeout: 20000
      pool:
        max-idle-time: 20000
    #开启从注册中心动态创建路由的功能，利用微服务名进行路由
#    discovery:
#      locator:
#        lower-case-service-id: true
#        enabled: true

    # 相关文档 https://www.cnblogs.com/crazymakercircle/p/11704077.html
    # uri相同时，只有最后一个会生效
    #一个请求满足多个路由的断言条件时，请求只会被首个成功匹配的路由转发；
    #predicates断言，可根据datetime、Cookie、Header、Host、Method、Path、Queryparam、RemoteAddr匹配
    #filter: 支持PrefixPath、RewritePath、SetPath、RedirectTo、RemoveRequestHeader、
    #RemoveResponseHeader、SetStatus、StripPrefix、RequestSize、Default-filters
    gateway:
      routes:
      #根据url拦截
      - id: service1_v1
        uri: https://www.so.com/?quanso.com.cn
        predicates:
          - Path=/360
#      - id: service1_v2
#        uri: http://localhost:8080/api/v2
#        predicates:
#          - Path=/v2

      #拦截v1请求，并带上/api，转发到8080端口上
#      - id: service1_v3
#        uri: http://localhost:8080
#        predicates:
#          - Path=/v1
#        filters:
#          - PrefixPath=/api

      #predicates断言，可根据datetime/Cookie/Header/Host/Method/Path/Queryparam/RemoteAddr匹配
      - id: queryParam-baidu-route
        uri: https://www.baidu.com
        predicates:
          - Query=baidu
      - id: queryParam-bing-route
        uri: https://bing.com/
        predicates:
          - Query=bing, tr. #参数中包含bing,且值为tr开头的三位参数 才能匹配到

#      - id: queryParam-release2-route
#        uri: http://localhost:8080/api/v2
#        predicates:
#          - Path=/api
#          - Weight=service2, 90

#      - id: queryParam-head-route
#        uri: http://localhost:8080
#        predicates:
#          - Header=Jump, 1001 #请求头中包含信息才校验通过
#        filters:
#          - PrefixPath=/api

#      - id: queryParam-host-route
#        uri: http://localhost:8080
#        predicates:
#          - Host=*.apix #请求头中包含信息才校验通过
#        filters:
#          - PrefixPath=/api

      #测试StripPrefix
#      - id: full-route
#        uri: http://localhost:8080
#        predicates:
#          - Query=full
#        filters:
#          - PrefixPath=/full
#          - StripPrefix=0

      # 熔断降级
#      - id: queryParam-fallback-route
#        uri: http://localhost:8080
#        predicates:
#          - Path=/test
#        filters:
#          - name: Hystrix
#            args:
#              name: default
#              fallbackUri: forward:/fallback
#      - id: fallback-route
#        uri: http://localhost:8080/fallback
#        predicates:
#          - Path=/fallback

        # 金丝雀发布
      - id: release1-route
        uri: http://localhost:8080
        predicates:
          - Path=/v1
          - Weight=service1, 50
        filters:
          - PrefixPath=/api
      - id: release2-route
        uri: http://localhost:8081
        predicates:
          - Path=/v1
          - Weight=service1, 50
        filters:
          - PrefixPath=/api


#hystrix.command.fallbackA.execution.isolation.thread.timeoutInMilliseconds: 5000
# hystrix 信号量隔离，1.5秒后自动超时
hystrix:
  command:
    default:
      execution:
        isolation:
          strategy: SEMAPHORE
          thread:
            timeoutInMilliseconds: 1500

```

### 获取及改写RequestBody示例
```java
class DemoFilter implements GlobalFilter, Ordered{
    @Resource
    private ServerCodecConfigurer configurer;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerRequest serverRequest = ServerRequest.create(exchange, configurer.getReaders());

        // read & modify body
        Mono<String> modifiedBody = serverRequest.bodyToMono(String.class)
                .flatMap(body -> {
                    //例子：验签
                    boolean checkFlag = paramSignCheck(jsonParam);
                    if(!checkFlag){
                        return Mono.error(new Exception("验签失败"));
                    }
                    return Mono.just(body);
                });

        BodyInserter bodyInserter = BodyInserters.fromPublisher(modifiedBody,String.class);
        HttpHeaders headers = new HttpHeaders();
        headers.putAll(exchange.getRequest().getHeaders());
        //重要 不处理会导致请求失败
        headers.remove(HttpHeaders.CONTENT_LENGTH);
        CachedBodyOutputMessage outputMessage = new CachedBodyOutputMessage(exchange, headers);

        return bodyInserter.insert(outputMessage, new BodyInserterContext())
                .then(Mono.defer(() -> {
                    ServerHttpRequestDecorator decorator = new ServerHttpRequestDecorator(
                            exchange.getRequest()) {
                        @Override
                        public HttpHeaders getHeaders() {
                            long contentLength = headers.getContentLength();
                            HttpHeaders httpHeaders = new HttpHeaders();
                            httpHeaders.putAll(super.getHeaders());
                            if (contentLength > 0) {
                                httpHeaders.setContentLength(contentLength);
                            }
                            return httpHeaders;
                        }

                        @Override
                        public Flux<DataBuffer> getBody() {
                            return outputMessage.getBody();
                        }
                    };
                    ServerHttpResponse decoratedResponse = decorate(exchange, trace);
                    return chain.filter(exchange.mutate().request(decorator).response(decoratedResponse).build());
                }));
    }
}
```

### 新增headers
```java
@Configuration
public class AuthGatewayFilter implements GlobalFilter, Ordered {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        Consumer<HttpHeaders> httpHeaders = httpHeader -> {
            // 存在相同的key,直接添加会报错
            if(StringUtils.isBlank(httpHeader.getFirst("xxx"))){
                httpHeader.add("xxx", "xxx");
            }
        };
        ServerHttpRequest serverHttpRequest = exchange.getRequest().mutate().headers(httpHeaders).build();
        exchange = exchange.mutate().request(serverHttpRequest).build();

        return chain.filter(exchange);
    }
    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE - 1;
    }
}
```

### 请求非json格式转jsondemo
```java
class Demo{

    /** application/x-www-form-urlencoded 转json **/
    private Map<String, Object> decodeBody(String body) {
        return Arrays.stream(body.split("&"))
                .map(s -> s.split("="))
                .collect(Collectors.toMap(arr -> arr[0], arr -> arr[1]));
    }

    /** fomrData(非文件)转 json 数据 **/
    private String parseFormData2Json(String requestParam){
        if(StringUtils.isBlank(requestParam) 
                && !requestParam.contains("filename")){
            return requestParam;
        }
        try{
            requestParam = requestParam.replace("-","").split("-")[0];
            String code = requestParam.split("\n")[0];
            requestParam = requestParam.replaceAll(code,"")
                    .replaceAll("ContentDisposition: formdata;","")
                    .replaceAll("\n","")
                    .replaceAll("name=",",")
                    .replaceAll("\"\r\r","\":\"")
                    .replaceFirst(",","")
                    .replaceAll("\r","\"")
            ;
            requestParam = "{" + requestParam + "\"}";
        } catch (Exception e){
            e.printStackTrace();
        }
        return requestParam;
    }
}

```
