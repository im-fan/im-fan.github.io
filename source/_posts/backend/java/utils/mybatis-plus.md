---
title: MybatisPlus使用笔记
description: mybatis-plus
date: 2020-12-10 12:00:00
tags:
- utils
categories:
- 后端
- 工具
---

### 常用配置
```yaml
#mybatis
# 配置是否打印日志 true-打印  false-不打印
# paginationInterceptor-true 改为false则分页功能无效
sql:
  performanceInterceptor: true
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  #实体扫描，多个package用逗号或者分号分隔
  typeAliasesPackage: com.ruoyi.**.domain
  global-config:
    #数据库相关配置
    db-config:
      #主键类型  AUTO:"数据库ID自增", INPUT:"用户输入ID", ID_WORKER:"全局唯一ID (数字类型唯一ID)", UUID:"全局唯一ID UUID";
      id-type: AUTO
      #字段策略 IGNORED:"忽略判断",NOT_NULL:"非 NULL 判断"),NOT_EMPTY:"非空判断"
      field-strategy: NOT_NULL
      #驼峰下划线转换
      column-underline: true
      logic-delete-value: -1
      logic-not-delete-value: 0
    banner: false
  #原生配置
  configuration:
    #不加无法打印执行脚本及内容
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    map-underscore-to-camel-case: true
    cache-enabled: false
    call-setters-on-nulls: true
    jdbc-type-for-null: 'null'
```
### 常见问题

- 1.selectOne() 查询出多条数据会报错
```textmate
selectOne不是存在多条数据时只返回一条！！！
报错信息：
   org.mybatis.spring.MyBatisSystemException: nested exception is org.apache.ibatis.exceptions.TooManyResultsException:
   Expected one result (or null) to be returned by selectOne(), but found: 2
解决方法:
    1.手动添加
    wrapper最后加上(最好带上排序，每次返回固定的值) .last("limit 1")
    2.切面统一处理,如下
```
```java
@Aspect
@Component
public class MybatisPlusAspect {

    // 配置织入点
    @Pointcut("execution(public * com.baomidou.mybatisplus.core.mapper.BaseMapper.selectOne(..))")
    public void selectOneAspect() {
    }

    @Before("selectOneAspect()")
    public void beforeSelect(JoinPoint point) {
        Object arg = point.getArgs()[0];
        if (arg instanceof AbstractWrapper) {
            arg = (AbstractWrapper) arg;
            ((AbstractWrapper) arg).last("limit 1");
        }
    }
}
```