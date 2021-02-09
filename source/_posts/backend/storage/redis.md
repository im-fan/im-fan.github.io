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

### Redis原子操作的两种方式
#### Lua脚本
```shell
-- lua语法 https://www.runoob.com/lua/lua-tutorial.html
-- 实现一个原子锁,存在key则返回失败,否则返回存储并返回成功
-- 关键字必须大写 参数1:value 参数2:有效时长

-- call 与 pcall区别  call执行错误就直接返回,pcall错误则返回一个带 err 域的 Lua 表(table),用于表示错误

-- 存在则直接返回失败
local val = redis.call("get",KEYS[1])

-- 不存在,则获取锁
if val then
    return 0
else
    redis.call("set",KEYS[1],ARGV[1])
    redis.call('expire',KEYS[1],ARGV[2])
    return 1
end
```
```java
@Service
public class LuaService {

    @Autowired
    private RedisTemplate redisTemplate;

    /**
     * lua文件所在路径
     * @parm key 键
     * @param ttl 过期时间，秒
     **/
    public boolean getAtomLock(String key,long ttl){
        String lockKey = "my:lock:" + key;
        // lua脚本所在resource目录下的相对路径
        String luaName = "lua/atom_lock.lua";
        // 执行 lua 脚本
        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
        // 指定 lua 脚本
        redisScript.setScriptSource(new ResourceScriptSource(new ClassPathResource(luaName)));
        // 指定返回类型
        redisScript.setResultType(Long.class);
        // 参数一：redisScript，参数二：key列表，参数三：arg（可多个）
        Long result = (Long) redisTemplate.execute(redisScript, Collections.singletonList(lockKey),1,ttl);
        return result != null && result == 1L;
    }
}

```
#### Set命令方式
```java
@Service
public class RedisService {

    @Autowired
    private RedisTemplate redisTemplate;

    /**
     * 不存则在获取锁
     * @param key
     * @param value 值
     * @param expire 过期时间，秒
     * **/
    public boolean setAndExpireIfAbsent(final String key, final String value, final long expire) {
        boolean isSuccess = (boolean) redisTemplate.execute((RedisCallback) connection -> {
            Object object = connection.execute("set",
                    key.getBytes(),
                    value.getBytes(),
                    SafeEncoder.encode("NX"),
                    SafeEncoder.encode("EX"),
                    Protocol.toByteArray(expire));
            return null != object;
        });
        return isSuccess;
    }
}

```
