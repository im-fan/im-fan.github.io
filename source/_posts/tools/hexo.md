---
title: Hexo搭建博客
date: 2020-09-30 14:51:20
tags: 
- tool
categories: 
- 其他
- 博客工具
---

> 记录本博客搭建步骤，适用于Mac/Linux系统，详细介绍及其他系统请参照Hexo官网


### 相关链接
- [Hexo官网](https://hexo.io/zh-cn/)
- [官网主题](https://hexo.io/themes/)
- [3-hexo主题](https://github.com/yelog/hexo-theme-3-hexo)
- [3-hexo主题相关文档](https://yelog.org/2017/03/13/3-hexo-logs/)

### 准备环境
> mac用户推荐先安装Homebrew，通过Homebrew安装一下软件
- [Homebrew](https://brew.sh/)
- 安装Git
- 安装Node.js

### 安装Hexo
```textmate
npm install -g hexo-cli
```

### 创建项目
```shell
注：my-hexo - 项目名/项目文件夹名
hexo init my-hexo
cd my-hexo
npm install
```

### 项目结构

- 目录
```textmate
.
├── _config.yml
├── package.json
├── scaffolds
├── source
|   ├── _drafts
|   └── _posts
└── themes
```

- 目录介绍

```textmate
1._config.yml
网站的 配置 信息，您可以在此配置大部分的参数
2.package.json
应用程序的信息。
3.scaffolds
模版 文件夹。当您新建文章时，Hexo 会根据 scaffold 来建立文件。
4.source
资源文件夹是存放用户资源的地方。除 _posts 文件夹之外，开头命名为 _ (下划线)的文件 / 文件夹和隐藏的文件将会被忽略。Markdown 和 HTML 文件会被解析并放到 public 文件夹，而其他文件会被拷贝过去。
5.themes
主题 文件夹。Hexo 会根据主题来生成静态页面。
```
### 配置主题
- [官网主题](https://hexo.io/themes/)
- 本博客使用的主题 [3-hexo](https://github.com/yelog/hexo-theme-3-hexo)

```textmate
1.项目根目录下执行(下载其他主题，修改为themes/xxx即可)
git clone https://github.com/yelog/hexo-theme-3-hexo.git themes/3-hexo
2.修改配置
修改hexo根目录的_config.yml，theme: 3-hexo
3.主题更新
cd themes/3-hexo
git pull

在此感谢提供主题的作者
```

### 写作
- 常用文档命令

```textmate
1.新建文档
hexo new [layout] <title>

2.新建草稿文档
hexo new [layout] <title>

3.草稿<->发布
hexo publish [layout] <title>
```
- 参数介绍
|参数|值|作用|生成文件的路径|
|-|-|-|-|
|layout|post|正式发表的文章|source/_posts|
|layout|page|静态页面|source|
|layout|draft|草稿|source/_drafts|
|title|-|文章标题&文件名|-|

- 文档头部信息格式

```textmate
---
title: Java
date: 2020-09-30 14:51:20
tags: 
- Java
categories: 
- Java
- 笔记
---
```

- 文档头部信息解释

|参数|作用|
|-|-|
|title|	网站标题|
|subtitle|	网站副标题|
|description|	网站描述|
|tags|标签，可多个|
|categories|分类菜单，可定义多级|
|keywords|	网站的关键词。支援多个关键词。|
|author|	您的名字|
|language|	网站使用的语言。对于简体中文用户来说，使用不同的主题可能需要设置成不同的值，请参考你的主题的文档自行设置，常见的有 zh-Hans和 zh-CN。|
|timezone|	网站时区。Hexo 默认使用您电脑的时区。请参考 时区列表 进行设置，如 America/New_York, Japan, 和 UTC 。一般的，对于中国大陆地区可以使用 Asia/Shanghai。|

### 运行&发布
- 本地运行
```textmate
npm run server
```
- 编译&部署
```textmate
hexo clean 
hexo generate
编译后会生成public文件夹，部署gitpage可以直接指定public为资源文件夹即可
```
