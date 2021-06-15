---
title: nginx
description: nginx
#top: 1
date: 2021-04-05 10:26:05
tags:
- devops

categories:
- devops
- nginx
---

- [官网](http://nginx.org/)
- [菜鸟教程-Nginx 安装配置](https://www.runoob.com/linux/nginx-install-setup.html)
- [Nginx服务器SSL证书安装部署-腾讯云](https://cloud.tencent.com/document/product/400/35244)

### nginx命令
```textmate
1.检测配置是否正常
nginx -t 

2.热部署配置
nginx -s reload
```

### ssl-nginx配置
```textmate
具体参考云厂商ssl证书安装步骤
1.下载ssl相关文件,服务器开启443端口权限
2.解压后将文件夹Nginx中文件放到nginx安装目录下(或其他地方)
3.添加nginx配置文件
4.重启生效
```

### 同一域名不同服务配置
```textmate
server {
    listen       8888;
    server_name  localhost;

    location /service1/ {
         proxy_pass http://localhost:7001/;
    }
    
    location /service2/ {
         proxy_pass http://localhost:7002/;
    }
}
```
