---
title: 对象转换工具-Orika
description: 对象转换
date: 2021-03-20 14:15:00
tags:
- utils
categories:
- 后端
- 工具
---

## Orika
- [官方文档](http://orika-mapper.github.io/orika-docs/)

### 提供的能力
```textmate
Orika为开发者提供了如下功能：
1.映射复杂的、深层次结构性对象。
2.通过将嵌套属性映射到顶级属性，“拉平”或“展开”对象。
3.自动创建映射，并且在部分或所有映射上自定义。
4.创建转换器，以完全控制对象图中的任何特定对象集合的映射——按类型，甚至是通过特定的属性名。
5.处理代理或增强对象（如Hibernate或各种模拟框架）
6.用一个配置应用双向映射。
7.为一个目标抽象类或接口映射到具体的实现类。
8.映射POJO属性到Lists, Arrays, and Maps。
```

### 配置
#### pom引用
```textmate
<!-- 方式一(推荐) -->
<dependency>
    <groupId>net.rakugakibox.spring.boot</groupId>
    <artifactId>orika-spring-boot-starter</artifactId>
    <version>1.9.0</version>
</dependency>

<!-- 方式二，需要在项目中加入配置类 -->
<dependency>
    <groupId>ma.glasnost.orika</groupId>
    <artifactId>orika-core</artifactId>
    <version>1.5.4</version>
    <scope>compile</scope>
</dependency>
```

#### 方式二所需配置类(可选)
```textmate
@Configuration
public class MapperFactoryAware {
    @Bean
    public MapperFacade mapperFacade(){
        MapperFactory mapperFactory = new DefaultMapperFactory.Builder().build();
        return mapperFactory.getMapperFacade();
    }
}
```

### 案例
#### 基础测试类
```textmate
// dto对象
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserInfoDTO {

    private String userId;

    private String userName;

    private String createTime;

    private List<String> ids;

    private String dtoName;

}

// po对象
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserInfo {

    private Integer userId;

    private String userName;

    private Date createTime;

    private List<Integer> ids;

    private String poName;

}


```
#### 简易demo(更多用法参考官方文档)
```java

@Slf4j
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        classes = DemoApplication.class)
public class ConvertTest{

    @Autowired
    private MapperFacade mapperFacade;
    @Autowired
    private MapperFactory mapperFactory;

    //简易案例，属性名相同，类型不同
    @Test
    public void testSimple(){
        UserInfo userInfo = UserInfo.builder()
                .userId(10001)
                .ids(Arrays.asList(1002,1003,1004,1005))
                .userName("aaaa")
                .createTime(new Date())
                .build();

        //po 2 dto
        UserInfoDTO result = mapperFacade.map(userInfo, UserInfoDTO.class);
        log.info("po 2 dto =====> {}", JSON.toJSONString(result));

        //dto 2 po
        UserInfo info = mapperFacade.map(result, UserInfo.class);
        log.info("dto 2 po =====> {}", JSON.toJSONString(info));

        // pos 2 dtos
        List<UserInfo> pos = new ArrayList<>();
        pos.add(userInfo);
        List<UserInfoDTO> dtos = mapperFacade.mapAsList(pos,UserInfoDTO.class);
        log.info("pos 2 dtos =====> {}", JSON.toJSONString(dtos));

        // pos 2 dtos
        pos = mapperFacade.mapAsList(dtos, UserInfo.class);
        log.info("pos 2 dtos =====> {}", JSON.toJSONString(pos));

    }

    //属性名不同，需要先在mapperFactory中设置，然后获取到mapperFacade再使用
    @Test
    public void testDiff(){
        UserInfo userInfo = UserInfo.builder()
                .userId(10001)
                .ids(Arrays.asList(1002,1003,1004,1005))
                .userName("aaaa")
                .createTime(new Date())
                .poName("this is po")
                .build();

        //不同字段互转
        mapperFactory.classMap(UserInfo.class, UserInfoDTO.class)
                .field("poName", "dtoName")
                .byDefault()
                .register();
        MapperFacade mapperFacade = mapperFactory.getMapperFacade();

        //po 2 dto
        UserInfoDTO result = mapperFacade.map(userInfo, UserInfoDTO.class);
        log.info("po 2 dto =====> {}", JSON.toJSONString(result));

        //dto 2 po
        UserInfo info = mapperFacade.map(result, UserInfo.class);
        log.info("dto 2 po =====> {}", JSON.toJSONString(info));

        // pos 2 dtos
        List<UserInfo> pos = new ArrayList<>();
        pos.add(userInfo);
        List<UserInfoDTO> dtos = mapperFacade.mapAsList(pos,UserInfoDTO.class);
        log.info("pos 2 dtos =====> {}", JSON.toJSONString(dtos));

        // pos 2 dtos
        pos = mapperFacade.mapAsList(dtos, UserInfo.class);
        log.info("pos 2 dtos =====> {}", JSON.toJSONString(pos));
    }
}
```

#### 执行结果
```textmate
testSimple 执行结果:
po 2 dto =====> {"createTime":"Sat Mar 20 14:29:14 CST 2021","ids":["1002","1003","1004","1005"],"userId":"10001","userName":"aaaa"}
dto 2 po =====> {"createTime":1616272154000,"ids":[1002,1003,1004,1005],"userId":10001,"userName":"aaaa"}
pos 2 dtos =====> [{"createTime":"Sat Mar 20 14:29:14 CST 2021","ids":["1002","1003","1004","1005"],"userId":"10001","userName":"aaaa"}]
pos 2 dtos =====> [{"createTime":1616272154000,"ids":[1002,1003,1004,1005],"userId":10001,"userName":"aaaa"}]

testDiff 执行结果:
po 2 dto =====> {"createTime":"Sat Mar 20 14:30:46 CST 2021","dtoName":"this is po","ids":["1002","1003","1004","1005"],"userId":"10001","userName":"aaaa"}
dto 2 po =====> {"createTime":1616272246000,"ids":[1002,1003,1004,1005],"poName":"this is po","userId":10001,"userName":"aaaa"}
pos 2 dtos =====> [{"createTime":"Sat Mar 20 14:30:46 CST 2021","dtoName":"this is po","ids":["1002","1003","1004","1005"],"userId":"10001","userName":"aaaa"}]
pos 2 dtos =====> [{"createTime":1616272246000,"ids":[1002,1003,1004,1005],"poName":"this is po","userId":10001,"userName":"aaaa"}]
```
