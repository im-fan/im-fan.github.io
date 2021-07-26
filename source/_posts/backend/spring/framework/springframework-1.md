---
title: SpringFramework源码学习(零)
date: 2021-06-26 20:00:00
tags:
- SpringFramework 
categories:
- 后端  
- 框架
- springframework-1
---

## SpringFramework5.2.x编译步骤(Mac下)
### 使用工具
- jdk1.8
- Spring-Framework5.2.x 源码
- Gradle 5.6.4
- Idea2021

### Gradle安装配置(编译工具)
- [Gradle官网](https://gradle.org/)
- [下载页面](https://gradle.org/releases/)

#### 方式一、压缩包(推荐)
> 建议下载源码中标识的gradle版本(源码gradle/wrapper/gradle-wrapper.properties中)
```textmate
1.下载压缩包，解压至~/software/文件夹下
2.设置环境变量
   echo $SHELL 先查看当前shell
   /bin/bash 则修改 ~/.bash_profile 文件
   /bin/zsh 则修改 ~/.zshrc 文件
   添加以下配置:
        export GRADLE_HOME=/Users/mac/software/gradle
        export PATH=$PATH:$GRADLE_HOME/bin
    source ~/.zshrc 或 source ~/.bash_profile 刷新
3.验证安装
  gradle -v
```
- 添加Gradle配置
```groovy
allprojects{
   repositories {
       def REPOSITORY_URL = 'http://maven.aliyun.com/nexus/content/groups/public/'
       all { ArtifactRepository repo ->
           if(repo instanceof MavenArtifactRepository){
               def url = repo.url.toString()
               if (url.startsWith('https://repo1.maven.org/maven2') || url.startsWith('https://jcenter.bintray.com/')) {
                   project.logger.lifecycle "Repository ${repo.url} replaced by $REPOSITORY_URL."
                   remove repo
               }
           }
       }
       maven {
           url REPOSITORY_URL
       }
   }
}
```

#### 方式二、brew安装
> 可能不是你想要的版本，注意！！！
```shell
brew install gradle
```

#### 方式三、旧版本升级命令(没试过)
```shell
./gradlew wrapper --gradle-version=7.1 --distribution-type=bin
```

### Idea安装配置Gradle
```textmate
1.搜索并安装插件 
    菜单: Preferences -> Plugins
    插件名(2个): Gradle / Gradle Extension
2.配置
    菜单: Preferences -> Build -> Build Tools -> Gradle
    配置项: 设置Gradle user home(仓库目录)
```

### Idea编译项目
```textmate
1.导入
   File -> Open -> 打开 Spring-Framework5.2x源码中 build.gradle
2.等待编译完成
   正常情况下一次编译通过，不熟悉gradle的话建议先不要改 settings.gradle 和 build.gradle 内容，否则会编译失败；
3.其他
   出现其他异常先参考源码中 import-into-XXX.md 文档
```

### 新建项目测试
- 1.新建模块my-demo，类型选Gradle
- 2.将新建的模块加到项目中(idea自动新增)
```textmate
settings.gradle 中新增 include 'my-demo'
```
- 3.引入模块
```groovy
// my-demo/build.gradle中引入模块
dependencies 下新增 compile(project(":spring-context"))
```
- 4.新建配置类及测试代码
```java
//配置类
//如果注解引入失败，则在
@Component
public class TestConfig {
}

//测试类，打印成功则说明编译成功
public class StartDemo {
    public static void main(String[] args) {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext("com.my.config");
        System.out.println(context.getBean(TestConfig.class));
    }
}
```
