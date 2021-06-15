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
