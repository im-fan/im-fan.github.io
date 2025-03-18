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

### 单元测试-通用

- 添加依赖

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>
```

- 需要spring容器加载时配置如下
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

- 纯mock数据单测
> 可mock所有类型的类，如果未定义mock则对象为空

```java
@ExtendWith(MockitoExtension.class)
class DemoTest{
    @Mapper
    private JobMapper jobMapper;
    @InjectMocks
    private JobService jobService;

    @Test
    void addTest(){
        when(jobMapper.count(any())).thenReturn(1);
        int result = jobService.count(1);
        assertEquals(1,result);
    }
}

```


- 默认执行真实逻辑，如有mock逻辑则执行mock
> 只能用于有具体实现类的class

```java
@ExtendWith(MockitoExtension.class)
class DemoTest{
    @SpyBean
    ThirdManage thirdManage;
    @Autowired
    JobService jobService;

    @Test
    class test(){
        Long jobId = 1L;
        //1. thirdManager走真实逻辑
        int result = jobService.count(jobId);
        assertEquals(result,1);
        
        //2. thirdManager走mock逻辑，可多次mock,返回不同值
        doReturn(2).when(thirdManage).selectByJobId(any());
        result = jobService.count(jobId);
        assertEquals(result,2);
    }
}
```

- SpringContextHolder 获取实例
> 需全局唯一，单独定义获取的类

```java
public class ConfigMock {

    public static MockedStatic<SpringContextHolder> mockContext;
    public static YmlConfig mockYml() {
        YmlConfig ymlConfig = Mockito.mock(YmlConfig.class);
        if (mockContext == null) {
            mockContext = Mockito.mockStatic(SpringContextHolder.class);
        }
        when(YmlConfig.getInstance()).thenReturn(ymlConfig);
        return ymlConfig;
    }
}

//使用
@ExtendWith(MockitoExtension.class)
class DemoTest(){

    @Test
    void ymlTest(){
        YmlConfig ymlConfig = ConfigMock.mockYml();
        String result = "true";
        when(ymlConfig.getFlag()).thenReturn(result);
    }
    
}
```

- 获取方法入参

```java
@ExtendWith(MockitoExtension.class)
pulic class DemoTest{
    @Captor
    private ArgumentCaptor orderInfoArg;

    @SpyBean
    private OrderInfoService orderInfoService;

    class addTest(){
        //不入库
        doNothing().when(orderInfoService).save(any());
        
        //获取入参
        verify(orderInfoService).save((OrderInfo) orderInfoArg.capture());
        OrderInfo saveOrderInfo = (OrderInfo) orderInfoArg.getValue();

        //调用方法
        OrderInfo param = new OrderInfo();
        param.setOrderNo("aa123");
        orderInfoService.add(param);

        //校验入参值和入库值是否一致
        assertEquals(param.getOrderNo(), saveOrderInfo.getOrderNo);
    }
}
```

- 通用打印当前执行的方法名
> junit5下每个类打印当前方法名
```java
@BeforeEach
public void setUp(TestInfo testInfo) {
    String currentMethodName = testInfo.getDisplayName();
    String className = testInfo.getTestClass().get().getSimpleName();
    log.info("{}.{}================>start", className, currentMethodName);
}
```

- 特殊注解
> 注意ExtendWith注解是junit5的注解，方法上的Test要用org.junit.jupiter.api.Test
```java
//宽松模式,mock的代码没用上时会报错(默认严格模式),加上此注解后不会报错(最好不用)
@MockitoSettings(strictness = Strictness.LENIENT)
// 实例生效范围，此配置为当前class生效
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@ExtendWith(MockitoExtension.class)
public class DemoTest{}
```

### MybatisPlus相关
- LambdaQueryWrapper mock
> UserServiceImpl.list() 方法中使用LambdaQueryWrapper，用以下方式初始化mybatisPlus的cache
```java
@ExtendWith(MockitoExtension.class)
class FunctionTest{
    @InjectMocks
    private UserServiceImpl userService;
    @Mock
    private UserMapper userMapper;
    
    @BeforeAll
    public static void init(){
        TableInfoHelper.initTableInfo(new MapperBuilderAssistant(new MybatisConfiguration(), ""), XXEntity.class);
    }
    
    @Test
    public void functionATest(){
        List<UserInfo> list = new ArrayList();
        when(userMapper.selectList(any())).thenReturn(list);
        List<UserInfo> result = userService.list();
        assertNotNull(result);
    }
}

```

- IService mock
> UserServiceImpl.batchAdd() 方法中使用IService.saveBatch()方法
```java
@ExtendWith(MockitoExtension.class)
class FunctionTest{
    @Spy
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    public void functionATest(){
        List<UserInfo> list = new ArrayList();
        //设置入参略
        when(userService.saveBatch(any())).thenReturn(true);
        List<UserInfo> result = userService.batchAdd(list);
        assertNotNull(result);
    }
}
```

### 移动端测试
- Charles(抓包)
- [Perfdog(软件性能)](https://perfdog.qq.com/)
- [Android专项测试工具](https://testerhome.com/topics/19832)
- Monkey
