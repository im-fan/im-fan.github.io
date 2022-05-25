---
title: Ognl表达式
description: ognl
date: 2022-05-25 15:40:00
tags:
- ognl
categories:
- 后端
- ognl表达式
---

### 表达式作用
> 根据定义的语法规则，操作对象信息

### 表达式框架
- Ognl(Object-Graph Navigation Language): 可以方便地操作对象属性的开源表达式语言
- JSTL(JSP Standard Tag Library): JSP2.0集成的标准表达式语言

### Ognl提供的能力
```textmate
1、支持对象方法调用

2、支持类静态的方法 或 值调用
    格式: "@[类全名(包括包路径)]@[方法名|值名]"。
    例子: 
        调用类静态方法 @java.lang.String@format('user%s','getUserId')
        访问类的静态值 @com.my.module@APP_ID

3、支持赋值操作和表达式串联
    如 user.id=1,  表达式 #user.id+1, 返回2
    支持 +, -, *, /, ++, --, ==, !=, = , mod, in, not in 等操作符

4、访问OGNL上下文 (OGNL context) 和 ActionContext

5、操作集合对象
```

### Ognl用途
- Mybatis
- 动态业务处理(动态逻辑、动态数据获取等)

### OGNL中的#、%和$符号对比

#### #符号的用法
```textmate
1.访问对象属性(不加#默认访问根对象)
    例如 #user.name

2.用于过滤和投影（projecting）集合
    #users.{?#this.id>=2}

    ? --获取集合中所有满足选择逻辑的对象
    ^ --获取集合中第一个满足选择逻辑的对象
    $ --获取集合中最后一个满足选择逻辑的对象

3.用来构造Map
    例如 #{'id':'1', 'name':'小明'}
```

#### %符号的用法
```textmate
作用: 用于标识当前表达式是否被ognl解析器解析(前端)
    %{#user.name} 标识括号中是一个ognl表达式，需要解析
```

#### $符号的用法
```textmate
作用: 引用值
用途:
    1.在国际化资源文件中，引用OGNL表达式
    2.在Struts 2框架的配置文件中引用OGNL表达式
        ${title}
```

### 简单Demo

- 导入Maven包
```xml
<!-- ognl表达式 -->
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.4.0</version>
    <scope>compile</scope>
</dependency>
```

- OgnlUtil
```java
package com.utils;

import org.apache.ibatis.ognl.Ognl;
import org.apache.ibatis.ognl.OgnlContext;
import org.apache.ibatis.ognl.OgnlException;

public class OgnlUtil {

    /**
     * 根据OGNL表达式进行取值操作
     *
     * @param expression ognl表达式
     * @param ctx  ognl上下文
     * @param rootObject ognl根对象
     * @return
     */
    public static Object getValue(String expression,
                                  OgnlContext ctx,
                                  Object rootObject) {
        try {
            return Ognl.getValue(expression, ctx, rootObject);
        } catch (OgnlException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 根据OGNL表达式进行赋值操作
     *
     * @param expression ognl表达式
     * @param ctx ognl上下文
     * @param rootObject ognl根对象
     * @param value 值对象
     */
    public static void setValue(String expression, OgnlContext ctx,
                                Object rootObject, Object value) {
        try {
            Ognl.setValue(expression, ctx, rootObject, value);
        } catch (OgnlException e) {
            throw new RuntimeException(e);
        }
    }
}
```

- module对象
```java
public class Employee {

    private int id;
    private String title;

    public Employee(){}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }
}

public class User {

    private int id;
    private String name;

    public User(){}
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

}

```

- test
```java

public class OgnlTest {

    public static void main(String[] args) {
        Employee emp = new Employee();
        OgnlContext ctx = initOgnlContext(emp);

        //测试获取元素
        testGet(ctx,emp);

        //测试设置元素
        testPut(ctx,emp);
        
        /**
         * 执行结果
         研发部
         小明
         研发部
         2
         [{"id":2,"name":"小王"},{"id":3,"name":"小六"}]
         {"id":3,"name":"小六"}
         {"id":1,"title":"测试新标题"}
         [{"id":1,"name":"小明"},{"id":2,"name":"小王"},{"id":4,"name":"小黄"}]      
         **/
    }

    //测试设置元素
    private static void testPut(OgnlContext ctx,Employee emp){
        OgnlUtil.setValue("title",ctx,emp,"测试新标题");
        Employee newEmp = (Employee) OgnlUtil.getValue("#emp", ctx, emp);
        System.out.println(JSON.toJSONString(newEmp));

        //设置集合
        User user = new User();
        user.setId(4);
        user.setName("小黄");
        OgnlUtil.setValue("#users[2]",ctx,emp,user);

        List<User> users = (List<User>) OgnlUtil.getValue("#users",ctx,emp);
        System.out.println(JSONArray.toJSONString(users));
    }

    //测试获取元素
    private static void testGet(OgnlContext ctx,Employee emp){
        //取出ognl上下文（容器）中的根元素的id属性,取根节点的对象，可以无需指定命名空间
        String id = (String) OgnlUtil.getValue("title", ctx, emp);
        System.out.println(id);

        // 表达式#user.name将执行user.getName()
        //取出ognl上下文中非根对象的name值，非根对象取值必须通过指定的类实例去取
        String uName = (String) OgnlUtil.getValue("#user.name",ctx, emp);
        System.out.println(uName);

        // 当然根对象也可以使用#emp.title表达式进行访问
        String empName = (String) OgnlUtil.getValue("#emp.title", ctx, emp);
        System.out.println(empName);

        Integer id2 = (Integer) OgnlUtil.getValue("#user.id+1", ctx, emp);
        System.out.println(id2);

        List<User> users = (List<User>) OgnlUtil.getValue("#users.{?#this.id>=2}",ctx,emp);
        System.out.println(JSONArray.toJSONString(users));

        User user = (User) OgnlUtil.getValue("#users[2]",ctx,emp);
        System.out.println(JSON.toJSONString(user));
    }

    //初始化Ognl上下文
    public static OgnlContext initOgnlContext(Employee root){
        root.setId(1);
        root.setTitle("研发部");

        User user = new User();
        user.setId(1);
        user.setName("小明");

        User user2 = new User();
        user2.setId(2);
        user2.setName("小王");
        User user3 = new User();
        user3.setId(3);
        user3.setName("小六");

        List<User> users = new ArrayList<>();
        users.add(user);
        users.add(user2);
        users.add(user3);

        // 创建OGNL下文,而OGNL上下文实际上就是一个Map对象
        OgnlContext ctx = new OgnlContext();
        ctx.put("emp",root);
        ctx.put("user",user);
        ctx.put("users",users);
        ctx.put("maxAge",24);
        ctx.put("minAge",18);

        //设置上下文根对象，一个上下文中只有一个根对象
        ctx.setRoot(root);

        return ctx;
    }
}
```
