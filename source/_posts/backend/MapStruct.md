---
title: MapStruct
description: MapStruct
date: 2020-10-02 15:51:46
tags: 对象转换工具
categories:
- 后端
- MapStruct
---


## MapStruct
[MapStruct](http://mapstruct.org/)是一个代码生成器，它基于约定优于配置方法极大地简化了Java bean类型之间映射的实现。
生成的映射代码使用普通方法调用，因此快速，类型安全且易于理解。

### 如何接入MapStruct

```xml
maidao-commons 已经完成对[MapStruct 的mvn依赖](http://mapstruct.org/documentation/installation/)，并解决了与swagger2的兼容问题。
<dependency>
    <groupId>com.maidao</groupId>
    <artifactId>maidao-commons</artifactId>
</dependency>
```

IDEA Support: https://plugins.jetbrains.com/plugin/10036-mapstruct-support/versions


### Java Bean属性拷贝性能对比

get/set >= [MapStruct](http://mapstruct.org/) > [JMapper](https://jmapper-framework.github.io/jmapper-core/)  >  ["beanCopier(cglib)"](https://github.com/cglib/cglib/blob/master/cglib/src/main/java/net/sf/cglib/beans/BeanCopier.java) > Orika > ModelMapper > Spring BeanUtils > Dozer > Apache BeanUtils
  
性能对比数据来源：
 - https://www.baeldung.com/java-performance-mapping-frameworks
 - https://java.libhunt.com/categories/337-bean-mapping
 
说明：
- get/set 需要手动编写大量转换代码，代码简洁性差、重复性高和工作量大。
- beanCopier 性能较高，属性名和类型有较高的匹配要求。
- MapStruct 性能较高，在编译阶段，生成Get/Set代码,支持不同属性之间自定义转换。
- Orika 性能较高,支持自定义属性拷贝，性能略差与前两种，当比后面几种高很多。
- Spring BeanUtils 性能一般，只能支持相关名称的拷贝。
- Dozer 性能差，使用简单，编写xml不方便。
- Apache BeanUtils 性能差。
    
### demo

实例代码:
```java
/**
* 定义对象之间转换Mapper
 * @Mapper 只有在接口加上这个注解， MapStruct 才会去实现该接口
 *     @Mapper
 *     componentModel ：主要是指定实现类的类型，
 *         - default：默认，可以通过 Mappers.getMapper(Class) 方式获取实例对象
 *         -  spring：在接口的实现类上自动添加注解 @Component，可通过 @Autowired 方式注入
 *     uses 使用用户自定义转换器
 *
 *     http://mapstruct.org/documentation/stable/reference/html/
 */
//@Mapper(componentModel = "spring",uses = {DateHandWritten.class})
@Mapper(
        uses = {DateHandWritten.class, UserNameHandWritten.class},
        imports = {LocalDateUtil.class}
        )
public interface PersonMapper {

    PersonMapper  INSTANCE  = Mappers.getMapper(PersonMapper.class);

    @Mappings({
            //@Mapping(source = "name",target = "name",ignore = true),
            @Mapping(target = "birthExpressionFormat", expression = "java(LocalDateUtil.getDateNow().toString())"),
            @Mapping(source = "name",target = "address.name"),
            @Mapping(source = "price",target = "price",numberFormat = "#.00"),
            @Mapping(source = "birthDate",target = "birthDateFormat",dateFormat = "yyyy-MM-dd HH:mm:ss")
    })
    /***
     * @Mapping：属性映射，若源对象属性与目标对象名字一致，会自动映射对应属性
     *     source：源属性
     *     target：目标属性
     *     dateFormat：String 到 Date 日期之间相互转换，通过 SimpleDateFormat，该值为 SimpleDateFormat              的日期格式
     *     ignore: 忽略这个字段
     * @Mappings：配置多个@Mapping
     */
    PersonDto toDto(Person person);

    @InheritConfiguration(name = "toDto")
    List<PersonDto> toDtos(List<Person> person);


    /*@InheritInverseConfiguration()
    PersonDto fromDto(Person person);*/

    /**
     * @InheritConfiguration 用于继承配置
     * */
  /*  @InheritConfiguration(name = "toDto")
    void update(Person person, @MappingTarget PersonDto personDto);*/
}

/**定义自定义转换规则*/
public class DateHandWritten {

    public String asString(Date date) {
        return date != null ? new SimpleDateFormat( "yyyy-MM-dd" )
            .format( date ) : null;
    }

    public Date asDate(String date) {
        try {
            return date != null ? new SimpleDateFormat( "yyyy-MM-dd" )
                .parse( date ) : null;
        }
        catch ( ParseException e ) {
            throw new RuntimeException( e );
        }
    }
}

/**定义自定义转换规则*/
public class UserNameHandWritten {

    public String asUsername(String username) {
        return  "被修改后的name";
    } 
}

/***使用实例*/
public class MapStructTest {

    @Test
    public void personTest(){
        Person person = buildPerson();
        PersonDto personDto = PersonMapper.INSTANCE.toDto(person);
        System.out.println(JSON.toJSONString(personDto));
        /**
        * {"address":{"name":"被修改后的name"},"addresses":[{"name":"被修改后的name"}],"age":0,"birthDate":1555573411245,"birthDateFormat":"2019-04-18","birthExpressionFormat":"Thu Apr 18 15:43:31 CST 2019","name":"被修改后的name","price":"2.35"}
        * */
    }

    @Test
    public void personListTest(){
        Person person = buildPerson();
        List<PersonDto> personDtos = PersonMapper.INSTANCE.toDtos(Lists.newArrayList(person));
        System.out.println(JSON.toJSONString(personDtos));
        /**
        * [{"address":{"name":"被修改后的name"},"addresses":[{"name":"被修改后的name"}],"age":0,"birthDate":1555573439123,"birthDateFormat":"2019-04-18","birthExpressionFormat":"Thu Apr 18 15:43:59 CST 2019","name":"被修改后的name","price":"2.35"}]
        * */
    }

    private Person buildPerson(){
        Address a = new Address();
        a.setName("demo");
        return Person.builder().birthDate(new Date()).price(BigDecimal.valueOf(2.347)).name("中国人").addresses(Lists.newArrayList(a)).build();
    }
}

```
### 实现原理
在Maven 编译阶段将自动实现PersonMapper的对象属性转换接口,生成PersonMapperImpl文件。