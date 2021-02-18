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

### Java代码测试
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
