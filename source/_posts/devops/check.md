---
title: 服务常见问题排查
date: 2021-02-09 17:08:25
tags:
- devops
categories:
- 运维
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
```
```java
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
```
```java
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

# 查看服务gc情况
jstat -gcutil pid 1000
```

- 工具

```textmate
1.gceasy网站
 https://www.gceasy.io
 
2.jconsole 或者 jvisualvm
```

### 频繁FullGC问题排查

- 模拟频繁GC

```java
@Slf4j
public class OOMTest extends TestCore {

    @Autowired
    private ThreadPoolConfig poolConfig;

    @Test
    public void newInstance(){
        for(;;){
            ConcurrentHashMap map = new ConcurrentHashMap<>(3000);
            map.put("a","b");
            log.info("{} size={}",map.toString(),map.size());
        }
    }
}
```

- 排查

```textmate
1.配置项目启动参数
    #出现 OOM 时生成堆 dump: 
    -XX:+HeapDumpOnOutOfMemoryError
    #生成堆文件地址：
    -XX:HeapDumpPath=/home/project/jvmlogs/

2.查看哪些对象较大
    jmap -histo pid | head -20

3.通过指令排查(堆栈较大的话可能会将系统卡死)
    jmap -dump:file=文件名.dump [pid]
    # format=b 指定为二进制文件
    jmap -dump:format=b,file=文件名 [pid]
```

- 分析

```textmate
工具 
    1.jhat - jdk自带分析工具
        jhat <heap-dump-file>  heap-dump-file 是文件的路径和文件名
        执行后访问浏览器访问 http://localhost:7000/ 查看 
    2.Eclipse Memory Analyzer(MAT)
        https://www.eclipse.org/mat/downloads.php
    3.IBM Heap Analyzer
```
