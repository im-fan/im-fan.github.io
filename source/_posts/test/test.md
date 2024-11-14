---
title: 测试相关
date: 2021-04-13 12:00：00
tags:
- test 
categories:
- 测试
---
### 后端测试工具
- PostMan
- [JMH-性能优化测试(转)](https://blog.csdn.net/weixin_43767015/article/details/104758415)
- Jmeter(接口测试)

#### 单元测试

- 添加依赖

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>
```

- 单元测试类
```java
//环境
@ActiveProfiles(value = "dev")
@AutoConfigureObservability
@SpringBootTest(classes = XXXApplication.class)
@ExtendWith(SpringExtension.class)
//支持按顺序执行单测
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class AbstractTestCore {
}
```

- 案例
> 默认执行真实方法,打桩后返回mock数据

```java
class UserService{
    @Autowired
    private UserMapper userMapper;
    @Autowired
    private OrderRest orderRest;
    
    public List<OrderInfo> orderList(Long userId,Integer pageNumber,Integer pageSize){
        UserInfo userInfo = userMapper.getById(userId);
        if(userInfo == null){
            return new ArrayList();
        }
        return orderRest.pageByUserId(userId,pageNumber,pageSize);
    }
    
}

class UserServiceTest extends AbstractTestCore{
    @Autowired
    private UserService userService;
    @SpyBean
    private UserMapper userMapper;
    @SpyBean
    private OrderRest orderRest;
    
    @Test
    public void userByIdTest(){
        UserInfo userInfo = userMapper.getById(1L);
        assertNull(userInfo);
    }
    
    @Test
    public void orderListTest(){
        Long userId = 1L;
        //模拟用户不存在
        doReturn(null).when(userMapper).getById(any());
        List<OrderInfo> result = userService.orderList(userId,1,10);
        assertNull(result);
        
        //用户存在，模拟orderRest未返回数据情况
        UserInfo userInfo = new UserInfo();
        userInfo.setId(userId);
        doReturn(userInfo).when(userMapper).getById(userId);
        doReturn(new ArrayList()).when(orderRest).pageByUserId(any(),any(),any());
        result = userService.orderList(userId,1,10);
        assertNull(result);
        
        //用户存在，模拟orderRest返回数据情况
        OrderInfo orderInfo = new OrderInfo();
        orderInfo.setOrderId(1L);
        orderInfo.setUserId(userId);
        orderInfo.setRealPrice(new Bigdecimal(1.12));
        List<OrderInfo> orderInfos = new ArrayList();
        orderInfos.add(orderInfo);
        doReturn(orderInfos).when(orderRest).pageByUserId(any(),any(),any());
        result = userService.orderList(userId,1,10);
        assertNotNull(result);
    }
}
```



### 移动端测试
- Charles(抓包)
- [Perfdog(软件性能)](https://perfdog.qq.com/)
- [Android专项测试工具](https://testerhome.com/topics/19832)
- Monkey
