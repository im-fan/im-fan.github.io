---
title: SpringBoot-EventStream
date: 2023-12-06 15:10:00
tags:
- 事件推送
categories:
- 后端
- 事件推送
---

### 事件推送实现方式
- WebSocket
- SseEmitter

### 对比

| 实现方式 | 建立连接 | 传输效率 | 兼容性| 传输内容 | 功能 | 使用场景 | 
| --- | --- | --- |--- |--- |--- |--- |
| WebSocket | 采用双工通信,客户端和服务器建立实时的双向通信信道。| 建立后保持连接不断,效率高于SSE。 |现代浏览器基本全面支持。|支持传输文本以及二进制数据。|支持双向全 duplex 通信,客户端和服务器都可以主动发送消息。|适用于需要实时双向交互的场景。例如聊天应用。|
| SseEmitter | 客户端发送一个长连接请求，然后服务端将事件通过 HTTP 响应推送给客户端。 |需要经常建立和关闭连接,效率不如 WebSocket。但支持 HTTP 缓存。 |原生支持的浏览器相对较少。需要Polyfill。|只允许推送文本，不支持传输二进制数据。|只支持服务器主动推送,客户端只能被动接收。|适用于需要一对一推送事件的场景。客户端只需监听,服务器主动推送。|

- 总结
  - SSE 适用于服务器单向推送文本事件的场景，兼容性稍差但效率高。
  - WebSocket 适用于实时双向通信的场景，效率更高但兼容性要求高。

### SSE实现
- 导包
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency> 
```
- 自定义SseEmitter(解决中文乱码)
```java
public class SseEmitterUTF8 extends SseEmitter {
    public SseEmitterUTF8(Long timeout) {
        super(timeout);
    }

    @Override
    protected void extendResponse(ServerHttpResponse outputMessage) {
        super.extendResponse(outputMessage);

        HttpHeaders headers = outputMessage.getHeaders();
        headers.setContentType(new MediaType(MediaType.TEXT_EVENT_STREAM, StandardCharsets.UTF_8));
    }
}
```

- Controller
```java

@Slf4j
@RestController
@RequestMapping(value = "/ai")
public class AIController {

    //防止串流
    private static final Map<String, SseEmitterUTF8> SSE_CACHE = new ConcurrentHashMap<>();

    @GetMapping(value = "/open", produces = {MediaType.TEXT_EVENT_STREAM_VALUE})
    public SseEmitterUTF8 open(@RequestParam("clientId") String clientId) {
        try{
            final SseEmitterUTF8 emitter = this.getConn(clientId);
            CompletableFuture.runAsync(() -> {
                try {
                    this.send(clientId);
                } catch (Exception e) {
                    log.error("{}",e);
                }
            });
            return emitter;
        } catch (Exception e){
            log.error("{}",e);
        }

        return null;
    }

    @GetMapping("/close")
    public Result<String> closeConn(@RequestParam("clientId") String clientId) {
        final SseEmitter sseEmitter = SSE_CACHE.get(clientId);
        if (sseEmitter != null) {
            sseEmitter.complete();
        }
        return Result.success("连接已关闭");
    }

    //获取链接
    public SseEmitterUTF8 getConn(@NotBlank String clientId) {
        final SseEmitterUTF8 sseEmitter = SSE_CACHE.get(clientId);

        if (sseEmitter != null) {
            return sseEmitter;
        } else {
            // 设置连接超时时间，需要配合配置项 spring.mvc.async.request-timeout: 600000 一起使用
            final SseEmitterUTF8 emitter = new SseEmitterUTF8(600_000L);
            // 注册超时回调，超时后触发
            emitter.onTimeout(() -> {
                log.info("连接已超时，正准备关闭，clientId = {}", clientId);
                SSE_CACHE.remove(clientId);
            });
            // 注册完成回调，调用 emitter.complete() 触发
            emitter.onCompletion(() -> {
                log.info("连接已关闭，正准备释放，clientId = {}", clientId);
                SSE_CACHE.remove(clientId);
                log.info("连接已释放，clientId = {}", clientId);
            });
            // 注册异常回调，调用 emitter.completeWithError() 触发
            emitter.onError(throwable -> {
                log.error("连接已异常，正准备关闭，clientId = {}", clientId, throwable);
                SSE_CACHE.remove(clientId);
            });

            SSE_CACHE.put(clientId, emitter);

            return emitter;
        }
    }

    /**
     * 模拟类似于 chatGPT 的流式推送回答
     *
     * @param clientId 客户端 id
     */
    public void send(@NotBlank String clientId) throws IOException, InterruptedException {
        final SseEmitterUTF8 emitter = SSE_CACHE.get(clientId);
        // 推流内容到客户端
        for(int i=0; i<10; i++){
            String msg = "第"+i+"条消息";
            emitter.send(new String(msg.getBytes(), StandardCharsets.UTF_8), MediaType.APPLICATION_JSON);
            Thread.sleep(300);
        }

        // 结束推流
        emitter.complete();
    }
}

```
