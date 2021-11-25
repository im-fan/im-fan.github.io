---
title: 集成SwaggerUI
description: swaggerui
date: 2021-11-25 10:00:00
tags:
- 接口文档
categories:
- 后端
- 接口文档
---

- [knife4j官网](https://doc.xiaominfo.com/knife4j/documentation/)

### 集成步骤

- 引入jar包
```xml
<dependency>
    <groupId>com.github.xiaoymin</groupId>
    <artifactId>knife4j-spring-boot-starter</artifactId>
    <version>2.0.9</version>
</dependency>
```

- 添加配置类
```java
/** 
 * 注意knife版本号，如果是2.0.x
 * 
 * **/
@Configuration
//@EnableSwagger2WebMvc //2.x版本用这个
//@EnableOpenApi  //3.x版本用这个
public class MySwagger {

    @Bean
    public Docket createRestApi(Environment env) {
        //开发测试环境开启
        Profiles profile = Profiles.of("local", "dev", "test");
        boolean flag = env.acceptsProfiles(profile);

        //2.x版本用 DocumentationType.SWAGGER_2
        //3.x版本用 DocumentationType.OAS_30
        
        return new Docket(DocumentationType.SWAGGER_2)
                //分组名称
                .groupName("2.X版本")
                .apiInfo(apiInfo())
                .enable(flag)
                .pathMapping("/")
                .select()
                //这里指定Controller扫描包路径
                .apis(RequestHandlerSelectors.basePackage("com.my.demo.web.controller"))
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("服务名")
                .version("2.0.0")
                .description("描述")
                .build();
    }
}
```

- 常用注解
```textmate
1.Controller类注解
    @Api(tags = "Controller名")
    @RestController
    @RequestMapping("/请求路径")

2.Controller中方法注解
    @ApiOperation(value = "方法名",notes = "方法描述")
    @GetMapping("/请求路径")
    @PostMapping("/请求路径")

3.Controller中方法入参注解
    @RequestParam(value = "入参",name = "入参名称")
    @RequestBody

4.出参入参注解
    @ApiModel("对象名称")
    @ApiModelProperty(name = "属性名")

```

### 常见问题

- 版本不兼容
```textmate
<!--swagger-ui 兼容性好的版本-->
<dependency>
    <groupId>com.github.xiaoymin</groupId>
    <artifactId>knife4j-spring-boot-starter</artifactId>
    <version>2.0.9</version>
    <!-- 去掉不兼容的版本 -->
    <exclusions>
        <exclusion>
            <artifactId>spring-plugin-core</artifactId>
            <groupId>org.springframework.plugin</groupId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.plugin</groupId>
    <artifactId>spring-plugin-core</artifactId>
    <version>2.0.0.RELEASE</version>
</dependency>
```

