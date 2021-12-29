---
title: 软件推荐
date: 2020-10-02 14:34:06
tags: 
- tool
categories:
- 其他
---


### Mac软件&工具网站
|主要功能|软件名|相关网址|
|-|-|-|
|图片编辑器|PixelStyle||
|视频播放|IINA||
|录屏软件|LICEcap||
|文件比较|Beyond Compare||
|Markdown编辑工具|Haroopad||
|Mac包管理工具|Homebrew||
|Mac破解软件||https://xclient.info|
|相似网站查询||https://www.similarsites.com|


### 常用软件激活方法

#### JRebl激活
- [Idea JRebl插件激活方法](http://www.yq1012.com/things/5019.html)

```textmate
1.生成guid
    http://jrebel.cicoding.cn/guid
2.配置
    设置 JRebel & XRebel 点击Chanage license
3.填入
    http://jrebel.cicoding.cn/新生成的guid
    邮箱
```

- 方式二
```textmate
1.Team Url
	http://jrebel.cicoding.cn/016AAD2C-DD8E-6D92-58EB-B6C79E874355
	xxx@xxx.com
2.然后设置为离线使用
```

#### MacOS sourceTree跳过登录
```textmate
1.显示包内容
2.搜索Atlassian
3.删除搜出来的文件(没有说明安装包可能有问题)
```

#### MacOS软件已损坏修复
```textmate
## 软件已损坏
sudo xattr -d com.apple.quarantine /Applications/xxxxxx.app
```

#### ssh密钥生成
```shell

## 配置
git config --global user.name "名称"
git config --global user.email "邮箱地址"

## -t重新生成
ssh-keygen [-t] rsa -C "your_email@example.com" -f gitee_id_rsa

## 如果生成的密钥不生效，则将密钥重新加下！！！
ssh-add ~/.ssh/qts_id_rsa

##测试是否成生效
ssh -T gitee@gitee.com
```
