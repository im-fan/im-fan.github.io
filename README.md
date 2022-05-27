## 官方文档
- [官方文档](https://hexo.io/zh-cn/docs/)
- [Imfan博客地址](https://im-fan.gitee.io/)
 
## 新增文档
```text
1.source/_posts文件夹下新增对应目录&文件夹
2.执行命令
  hexo new post 文件名

3.新文件头解释
文件头
title: Java    -- 标题
date: 2020-09-30 14:51:20  --时间
top: 1         -- 置顶
tags:          -- 标签，可多个
- Java
categories:    -- 菜单，多个表示一级、二级
- Java
- 笔记

```


## 相关命令
```text
1.本地启动
npm install (首次启动需执行)
npm run server

2.编译静态文件
hexo clean 
hexo generate

3.部署
    1.本地部署
    hexo deploy
    
    2.gitee上重新部署
    项目-> 服务 -> Gitee Pages
    部署分支:选择要部署的项目分支
    部署目录:
        选择项目中编译后的静态文件所在文件夹，如public(推荐此方法，部署速度快)
        不选则Gitee会自动编译并生一个文件夹(部署速度慢)；
```

## 发布部署命令
```shell
#本地启动
./restart.sh

#重新编译提交，并打开gitee页面
./rebuild.sh
```
