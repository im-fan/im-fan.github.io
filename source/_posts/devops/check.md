---
title: 服务常见问题排查
date: 2021-02-09 17:08:25
tags:
- devops
categories:
- devops
- 服务问题排查
---

### 死锁问题排查
- 模拟死锁
```java
@Slf4j
public class ThreadTest {

    public static String a1 = "a1";
    public static String a2 = "a2";

    public static void main(String[] args) {
        new Thread(new PrintA()).start();
        new Thread(new PrintB()).start();
    }
}

@Slf4j
class PrintA implements Runnable{
    @SneakyThrows
    @Override
    public void run() {
        synchronized (ThreadTest.a1){
            log.info("PrintA =====> a1");
            Thread.sleep(3000);
            synchronized (ThreadTest.a2){
                log.info("PrintA =====> a2");
            }
        }
    }
}
@Slf4j
class PrintB implements Runnable{

    @SneakyThrows
    @Override
    public void run() {
        synchronized (ThreadTest.a2){
            log.info("PrintB =====> a2");
            Thread.sleep(3000);
            synchronized (ThreadTest.a1){
                log.info("PrintB =====> a1");
            }
        }
    }
}
```
- 排查命令
```shell
# 查找到运行中java进程
jps -l

# 查看进程堆栈信息
jstack pid
```
- 工具
```textmate
jconsole 或者 jvisualvm
```
