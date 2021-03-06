---
title: LDAP学习笔记
date: 2021-02-18 14:25:55
tags:
- devops
categories:
- devops
- LDAP
---

### 相关链接
- [OpenLDAP](https://www.openldap.org/)
- [LDAP-admin操作指南](https://www.cnblogs.com/xiaomifeng0510/p/9564688.html)

### 常用名词
```textmate
o– organization（组织-公司）
ou – organization unit（组织单元-部门）
c - countryName（国家）
dc - domainComponent（域名）
sn – suer name（真实名称）
cn - common name（常用名称)
```

### Docker部署LDAP
- ldap
```shell
#用户名 cn=admin,dc=company,dc=com
#密码 123456
#注意，\后面不能有空格
docker run \
-p 389:389 \
-p 636:636 \
--name my-ldap \
--network bridge \
--hostname openldap-host \
--env LDAP_ORGANISATION="company" \
--env LDAP_DOMAIN="company.com" \
--env LDAP_ADMIN_PASSWORD="123456" \
--detach osixia/openldap
```
- ldap-admin
```shell
#启动后浏览器访问http://localhost:8080
docker run \
-d \
--privileged \
-p 8080:80 \
--name ldap-admin \
--env PHPLDAPADMIN_HTTPS=false \
--env PHPLDAPADMIN_LDAP_HOSTS=LDAP服务IP \
--detach osixia/phpldapadmin
```

### 查询用户信息
- 方式一
```java
@Slf4j
public class ldapService{
    public static void main(String[] args) {
        try {
            String bindUserDN = "cn=admin,dc=company,dc=com";
            //用户密码
            String bindPassword = "123456";
            //ldap服务器IP
            String url = "ldap://127.0.0.1:389/dc=company,dc=com";

            Hashtable<String, String> env = new Hashtable<>();
            env.put(javax.naming.Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
            env.put(javax.naming.Context.PROVIDER_URL, url);
            env.put(javax.naming.Context.SECURITY_AUTHENTICATION, "simple");
            env.put(javax.naming.Context.SECURITY_PRINCIPAL, bindUserDN);
            env.put(javax.naming.Context.SECURITY_CREDENTIALS, bindPassword);
            env.put("java.naming.referral", "follow");

            DirContext ctx = new InitialDirContext(env);
            log.info("ctx={}", JSON.toJSONString(ctx));
        } catch (Exception e) {
            log.info("LDAP登录失败 userName={},passWord={},error={}",username,password,e);
        }
        
    }
}
```
- 方式二(ldapTemplate)

#### 配置
```xml
<!-- ldap -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-ldap</artifactId>
    <version>2.3.2.RELEASE</version>
</dependency>
```
```yaml
  # LDAP连接配置,配置的base是不应该再加到节点的dn里面去的(dc=company,dc=com)
spring:
  ldap:
    urls: ldap://127.0.0.1:389
    base: dc=company,dc=com
    username: cn=admin,dc=company,dc=com
    password: 123456
```

#### 代码
```java
@Getter
@Setter
@ToString
@Entry(objectClasses = {"simpleSecurityObject", "organizationalRole","top"}, base = "ou=cmdb,ou=People")
public class LdapPerson {

    @Id
    @JsonIgnore
    private Name dn;

    /** 用户名 **/
    @Attribute(name="cn")
    private String personName;

    @Attribute(name="sn")
    private String sn;

    @Attribute(name="email")
    private String email;

    /** 昵称 **/
    @Attribute(name="displayName")
    private String displayName;

    @Attribute(name="password")
    private String password;
}
```
```java
@Slf4j
public class PersonAttributesMapper implements AttributesMapper<LdapPerson> {
    @Override
    public LdapPerson mapFromAttributes(Attributes attrs) throws NamingException {
        LdapPerson person = new LdapPerson();
        person.setPersonName((String)attrs.get("cn").get());

        //获取密码
        byte[] bts = (byte[]) attrs.get("userpassword").get();
        String password = "";
        for(byte bt : bts){
            password = password + (char)bt;
        }
        person.setPassword(password);
        return person;
    }
}
```

```java
public class LoginService{
    
    //lookup查询(精确定位查询)
    public AjaxResult<LdapPerson> ldapCheck(String username, String password) {
        String dn = String.format(userDN,username);
        LdapPerson person = ldapTemplate.lookup(dn, new PersonAttributesMapper());
        log.info("LDAP登录 username:{},person={}",username,JSON.toJSONString(person));
        if(person == null){
            return AjaxResult.error("账号不存在");
        }
        if(!password.equals(person.getPassword())){
            log.error("LDAP账号对应密码错误,username={},password={},realPwd={}",username,password,person.getPassword());
            return AjaxResult.error("密码错误");
        }
        return AjaxResult.success(person);
    }
    
    //search(遍历所有节点匹配)
    public LdapPerson getLdapAccountByName(String name) {

        LdapQuery query = query()
                .where("objectclass").is(objectclass)
                .and("cn").is(name);

        List<LdapPerson> persons = ldapTemplate.search(query,new PersonAttributesMapper());
        if(CollectionUtils.isEmpty(persons)){
            return null;
        }
        return persons.get(0);
    }
}
```
