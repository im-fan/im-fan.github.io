---
title: Redis学习笔记
description: redis
date: 2021-02-02 19:59:00
tags:
- cache
categories:
- 后端
- cache
---

### Redis相关

#### RedisTemplate配置
```java
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport {
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory){
        RedisTemplate<Object, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        //key的序列化方式
        StringRedisSerializer stringRedisSerializer = new StringRedisSerializer();
        // string的key序列化方式
        template.setKeySerializer(stringRedisSerializer);
        // hash的key也采用String的序列化方式
        template.setHashKeySerializer(stringRedisSerializer);

        //value的序列化方式
        FastJson2JsonRedisSerializer serializer = new FastJson2JsonRedisSerializer(Object.class);
        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        om.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        om.registerModule(new JavaTimeModule());
        serializer.setObjectMapper(om);

        //string的value序列化方式
        template.setValueSerializer(serializer);
        // hash的value序列化方式
        template.setHashValueSerializer(stringRedisSerializer);
        
        template.afterPropertiesSet();
        return template;
    }
}
```
### RedisTemplate k-v序列化差异
<img src="https://im-fan.gitee.io/img/cache/redisTemplate-serialize.png"/>

### RedisTemplate 操作hash
```java
//redis中的hash相当于java中的HashMap

String key = "key";
Map<String,String> hashMap = new HashMap<>();
hashMap.put("a",JSON.toJSONString(new Object()));
hashMap.put("b",JSON.toJSONString(new Object()));

//所有值
redisTemplate.opsForHash().putAll(key,hashMap);

//获取单个值
List<String> hashKey = new ArrayList<>();
hashKey.add("a"); // 获取hash中的某个key下的值
redisTemplate.opsForHash().multiGet(key,hashKey);

//设置单个值
String hk = "hash 的key";
String hv = "hash 的value";
redisTemplate.opsForHash().put(key,hk,hv);

//删除key
String[] hkeys = {hk};
redisTemplate.opsForHash().delete(key, hkeys);

```
