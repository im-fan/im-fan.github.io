---
title: 运维相关
date: 2021-04-16 14:19:25
tags:
- docker
categories:
- 运维
---
### K8S相关
- [k8s实践(转)](https://k8s.imroc.io/troubleshooting/)
- [k8s问题定位手册(转)](https://www.processon.com/view/link/5e4662ade4b0d86ec4018e50#map)

### Docker相关
- [清理Docker](https://dockerwebdev.com/tutorials/clean-up-docker/)
- [Kubernetes中文社区](https://www.kubernetes.org.cn/kubernetes-pod)
- [Istio(ServiceMesh)](https://istio.io/latest/zh/docs/setup/getting-started/)
- [Kiali](https://kiali.io/documentation/latest/runtimes-monitoring/#_quarkus)

#### 本地启动K8S
```textmate
1.先下载安装docker desktop(建议3.2.2以上)
    https://www.docker.com/products/docker-desktop

2.安装好后启动docker desktop

3.设置
    3.1 Perferences ==> Kubernetes ==> 开启Enable Kubernetes，Show system containers
    3.2 如果开启不了尝试手动下载k8s相关进行并重启docker desktop
    3.3 下载与docker desktop中Kubernetes一致的版本
        https://github.com/maguowei/k8s-docker-desktop-for-mac
        
```

#### docker设置
```textmate
1.设置开机自启
    sudo systemctl enable xx

2.配置docker容器自动重启
    docker update xx --restart=always
```

#### 清理Docker
```textmate
https://dockerwebdev.com/tutorials/clean-up-docker
```

#### 配置阿里云镜像加速
```textmate
阿里云控制台->容器服务->镜像加速器->选择不同系统的命令并执行
```

#### Docker踩坑
```textmate
1.目录挂载问题
    如果要映射具体文件，需要先手工创建好，否则默认是作为文件夹创建的
```

### 虚拟机-VirtualBox
#### VirtualBox虚拟机镜像安装工具
```textmate
   vargrant 软件(有对应的镜像仓库)
   vargrant init center/7  ---> 会生成类似dockerfile的文件,支持修改配置
   vargrant up --> 启动，相当于点虚拟机开机
   vargrant ssh  ---> ssh链接虚拟机
   vargrant reload ---> 重启虚拟机
```
