---
title: 高并发相关
description: 高并发
date: 2021-11-22 20:06:00
tags:
- 高并发
categories:
- 后端
- 高并发
---

# 高并发相关
>高并发相关书籍总结文档

## 基础
#### 进程的结构
>由程序段、数据端和进程控制块组成
```textmate
线程的大致结构
线程描述信息、程序计数器和栈内存组成

区别
1.进程是进程代码段的一次顺序执行流程，一个进程有一个或多个线程组成
2.线程是CPU调度最小单位；进项是操作系统分配资源的最小单位。
3.线程从进程的内部演进而来。
4.进程之间相互独立；进程中的各个线程不完全独立，共享进程的方法区内存、堆内存、系统资源等
5.切换速度不同： 线程上下文切换比进程上下文切换速度快。
```

#### Java线程和OS线程关系
```textmate
一对一模型，缺点是创建一个用户线程也要创建一个内核线程，开销大
```

#### Java线程底层实现
```textmate
Windows上采用Win32 API实现
UNIX和Linux采用Pthread( POSIX标准的扩展，提供用户级或内核级库)
```

#### JDK创建Linux线程源码
```textmate
src/hotspot/os/linux/os_linux.cpp
```

#### 创建线程的方式
```textmate
Thread/Runnable/FutureTask/线程池(ThreadPoolExecutor)

SynchronousQueued(同步队列)
必须有take线程在阻塞等待，offer操作才能成功；否则会为新任务开一条新线程去执行

关闭线程池方法
shutdown/shutdownNow/awaitTermination
```

#### 确定线程池的线程数
```textmate
分类：
IO密集型   最佳线程数 = CPU核心线程的2倍
CPU密集型  最佳线程数 = CPU核心线程数量
混合型     最佳线程数 = ((线程等待时间+线程 CPU 时间)/线程 CPU 时间 )* CPU 核数 = 最佳线程数目 =(线程等待时间与线程 CPU 时间之比 + 1)* CPU 核数
```

#### Java对象的三个部分
```textmate
1.对象头
对象头包括三个字段，
Mark Word(标记字)，用于存储自身运行时的数据 例如 GC 标志位、哈希码、锁状态等信息。
Class Pointer(类对象指针)，用于存放方法区 Class 对象的地址，虚拟机通 过这个指针来确定这个对象是哪个类的实例。
Array Length(数组长度)。如果对象是一个 Java 数组，那么此字段必须有， 用于记录数组长度的数据;如果对象不是一个 Java 数组，那么此字段不存在，所以这是一个可选 字段。

2.对象体
对象体包含了对象的实例变量(成员变量)。用于成员属性值，包括父类的成员属性值。这 部分内存按 4 字节对齐。

3.对齐字节
对齐字节也叫做填充对齐，其作用是用来保证 Java 对象在所占内存字节数为 8 的倍数(8N bytes)。HotSpot VM 的内存管理要求对象起始地址必须是 8 字节的整数倍。对象头本身是 8 的 倍数，当对象的实例变量数据不是 8 的倍数，便需要填充数据来保证 8 字节的对齐。
```

#### 对象结构中的核心字段作用
```textmate
(1)Mark Word(标记字)字段主要用来表示对象的线程锁状态，另外还可以用来配合 GC、 存放该对象的 hashCode。
(2)Class Pointer(类对象指针)字段是一个指向方法区中 Class 信息的指针，意味着该对象 可随时知道自己是哪个 Class 的实例。
(3)Array Length(数组长度)字段也占用 32 位(在 32 位 JVM 中)的字节，这是可选的， 只有当本对象是一个数组对象时才会有这个部分。
(4)对象体用于保存对象属性值，是对象的主体部分，占用的内存空间大小取决于对象的属 性数量和类型。
(5)对齐字节并不是必然存在的，也没有特别的含义，它仅仅起着占位符的作用。当对象实 例数据部分没有对齐(8 字节的整数倍)时，就需要通过对齐填充来补全。
```

#### 对象结构中的字段长度
```textmate
Mark Word、Class Pointer、Array Length 等字段的长度，都与 JVM 的位数有关。Mark Word 的长度为 JVM 的一个 Word(字)大小，也就是说 32 位 JVM 的 Mark Word 为 32 位，64 位 JVM 为 64 位。Class Pointer(类对象指针)字段的长度也为 JVM 的一个 Word(字)大小，即 32 位的 JVM为32位，64位的JVM为64位。
所以，在 32 位 JVM 虚拟机中，Mark Word 和 Class Pointer 这两部分都是 32 位的;在 64 位 JVM 虚拟机中，Mark Word 和 Class Pointer 这两部分都是 64 位的。
对于对象指针而言，如果 JVM 中对象数量过多，使用 64 位的指针将浪费大量内存，通过简 单统计，64 位的 JVM 将会比 32 位的 JVM 多耗费 50%的内存。为了节约内存可以使用选项 +UseCompressedOops 开启指针压缩。选项 UseCompressedOops 中的 Oop 部分为 Ordinary object pointer 普通对象指针的缩写。

如果开启 UseCompressedOops 选项，以下类型的指针将从 64 位压缩至 32 位:
1.Class 对象的属性指针(即静态变量)
2.Object 对象的属性指针(即成员变量)
3.普通对象数组的元素指针
当然，也不是所有的指针都会压缩，一些特殊类型的指针不会压缩，比如指向 PermGen(永 久代)的 Class 对象指针(JDK8 中指向元空间的 Class 对象指针)、本地变量、堆栈元素、入参、返 回值和 NULL 指针等。
```

#### JOL
```textmate
JOL 全称为 Java Object Layout，是分析 JVM 中对象的结构布局的工具，该工具大量使用了 Unsafe、JVMTI 来解码内部布局情况，其分析结果相对比较精准的。要使用 JOL 工具，先引入 Maven 的依赖坐标:
<!--Java Object Layout --> 
<dependency>
	<groupId>org.openjdk.jol</groupId> 
	<artifactId>jol-core</artifactId> 
	<version>0.11</version>
</dependency>
```

#### 锁分类
> 偏向锁、轻量级锁、重量级锁
#### 偏向锁
```textmate
偏向锁的核心原理是:
	如果不存在线程竞争的一个线程获得了锁，那么锁就进入偏向状态， 此时 Mark Word 的结构变为偏向锁结构，锁对象的锁标志位(lock)被改为 01，偏向标志位 (biased_lock)被改为 1，然后线程的 ID 记录在锁对象的 Mark Word 中(使用 CAS 操作完成)以后该线程获取锁的时，判断一下线程 ID 和标志位，就可以直接进入同步块，连 CAS 操作都不 需要，这样就省去了大量有关锁申请的操作，从而也就提供程序的性能。
偏向锁的主要作用:
	消除无竞争情况下的同步原语，进一步提升程序性能，所在于没有锁竞 争的场合，偏向锁有很好的优化效果。但是，一旦有第二条线程需要竞争锁，那么偏向模式立即 结束，进入轻量级锁的状态。
偏向锁的缺点:
	如果锁对象时常被多条线程竞争，那偏向锁就是多余的，并且其撤销的过程 会带来一些性能开销。
```

#### 轻量级锁
```textmate
轻量锁存在的目的是尽可能不用动用操作系统层面的互斥锁，因为那个性能会比较差，轻量级锁是一种自旋锁；
轻量级锁主要有两种:
	(1)普通自旋锁，
		所谓普通自旋锁，就是指当有线程来竞争锁时，抢锁线程会在原地循环等待，而不是被阻塞，直到那个占有锁的线程释放锁之后，这个抢锁线程就可以马上获得锁的。默认情况下，自旋的次数为 10 次，用户可以通过-XX:PreBlockSpin 选项来进行更改。
	(2)自适应自旋锁。
		所谓自适应自旋锁，就是等待线程空循环的自旋次数并非是固定的，而是会动态着根据实际 情况来改变自旋等待的次数，自旋次数由前一次在同一个锁上的自旋时间及锁的拥有者的状态来决定
JDK1.6 的轻量级锁使用的是普通自旋锁，且需要使用 -XX:+UseSpinning 选 项手工开启。JDK1.7 后，轻量级锁使用自适应自旋锁，JVM 启动时自动开启，且自 旋时间由 JVM 自动控制。
```

#### 重量级锁
```textmate
JVM 中每个对象都会有一个监视器，监视器和对象一起创建、销毁
Monitor 是一种同步工具，也可以说是一种同步机制，主要特点是:
(1)同步。
	Monitor 所保护的临界区代码，是互斥的执行。一个 Monitor 是一个运行许可，任一个线程进入临界区代码都需要获得这个许可，离开时把许可归还。
(2)协作。
	Monitor 提供 Signal 机制:允许正持有许可的线程暂时放弃许可进入阻塞等待状 态，等待其他线程发送 Signal去唤醒;其他拥有许可的线程可以发送 Signal，唤醒正在阻塞等待 的线程，让它可以重新获得许可并启动执行。
```

#### 三种内置锁的对比
|锁|优点|缺点|适用场景|
|---|---|---|---|
|偏向锁|加锁和解锁不需要额外的消耗，和执行非同步方法比仅存在纳秒级的差距|如果线程间存在锁竞争，会带来额外的锁撤销的消耗|适用于只有一个线程访问 临界区场景|
|轻量级锁|竞争的线程不会阻塞，提高了程序的响应速度|抢不到锁的线程会CAS自旋等待，消耗CPU|锁占用时间短，吞吐量低|
|重量级锁|线程竞争不使用自旋，不会消耗CPU|线程阻塞，响应时间缓慢|锁占用时间较长，吞吐量高|

#### 线程通信
```textmate
定义:当多个线程共同操作共享的资源时，线程间通过某种方式互相告 知自己的状态，以避免无效的资源争夺。
分类:等待-通知、共享内存、管道流。
1.等待-通知
	"等待-通知" 是Java中使用最为普遍的线程间通信方式，其最为经典的案例就是 “生产者-消费者”模式。
2.共享内存
	通过实现Runnable或内部类的形式，共享同一个变量
3.管道通信就是使用java.io.PipedInputStream 和 java.io.PipedOutputStream进行通信

wait 方法的原理:
	首先 JVM 会释放当前线程的对象锁 Monitor 的 Owner 资格;其次 JVM 会 当前线程移入 Monitor 的 WaitSet 队列，而这些操作都和对象锁 Monitor 是相关的。
	所以，wait 方法必须在 synchronized 同步块的内部使用。在当前线程执行 wait 方法前，必须 通过 synchronized 方法成为对象锁的 Monitor 的 Owner。
notify 方法的原理:
	JVM 从对象锁的 Monitor 的 WaitSet 队列，移动一条线程到其 EntryList 队列，这些操作都与对象锁的 Monitor 有关。
	所以，notify 方法也必须在 synchronized 同步块的内部使用。在执行 notify 方法前，当前线 程也必须通过 synchronized 方法成为对象锁的 Monitor 的 Owner。

```

### CAS
#### ABA问题解决方案
```textmate
AtomicStampedReference  compareAndSet
AtomicMarkableReference   
	AtomicMarkableReference适用只要知道对象是否有被修改过，而不适用于对象被反复修改的 场景。
```

#### 提高高并发场景下CAS操作性能
```textmate
LongAdder 以空间换时间的方式提升高并发场景下 CAS 操作性能
	LongAdder 的实现思路，与 ConcurrentHashMap 中分段锁基本原理非常相似，本质上，都是不同的线程在不同的单元上进行操作，这样减少了线程竞争，提高了并发效率
```

### 可见性和缓存一致性
```textmate
1. 总线锁
	效率低，开销大
2. 缓存锁
	 MESI 协议，保证缓存一致性
	 缓存一致性:缓存一致性机制就整体来说，是当某块CPU对缓存中的数据进行操作了之后， 就通知其他 CPU 放弃储存在它们内部的缓存，或者从主内存中重新读取

    CPU 对 Cache 副 本如何与主存内容保持一致有几种写入方式可供选择，主要的写入方式有以下两种
	1)Write-through(直写模式)  更新低一级缓存和存储器，数据写入速度慢
	2)Write-back(回写模式)  只写入缓存，发现数据有变动，才将数据更新到存储器
```

#### MESI协议解释
```textmate
M: 被修改(Modified)
E: 独享的(Exclusive)
S: 共享的(Shared)
I: 无效的(Invalid)
```

#### 指令重排
```textmate
As-if-Serial规则： 不管如何重排序，都必须保证代码在单线程下的运行正确。

扩展:
	JIT 是 Just In Time 的缩写, 也就是“即时编译器”。JVM 读入“.class” 文件的字 节码后，默认情况下是解释执行的。但是对于运行频率很高(如>5000 次)的字节码， JVM 采用了 JIT 技术，将直接编译为机器指令，以提高性能。
```

#### 硬件层面的内存屏障
```texxtmate
1. 硬件层的内存屏障定义
	内存屏障(Memory Barrier)又称内存栅栏(Memory Fences)，是让一个 CPU 高速缓存的内 存状态对其他 CPU 内核可见的一项技术，也是一项保障跨 CPU 内核有序执行指令的技术。
	硬件层常用的内存屏障分为三种:读屏障(Load Barrier)、写屏障(Store Barrier)、全屏障 (Full Barrier)。

2.作用
	1).阻止屏障两侧的指令重排序
	2).强制让高速缓存的数据失效
```

#### JMM(Java内存模型)
> JMM 并不像 JVM 内存结构一样是真实存在的运行实体，更多体现为一种规范和规则
```textmate
1.核心的价值在于解决可见性和有序性。
2.JMM的另一大价值，在于能屏蔽了各种硬件和操作系统的访问差异的，保证了Java程序在各种平台下对内存的访问都能保证最终的一致。

Java 内存模型的规定:
	(1)所有变量存储在主内存中。 
	(2)每个线程都有自己的工作内存，且对变量的操作都是在工作内存中进行。 
	(3)不同线程之间无法直接访问彼此工作内存中的变量，要想访问只能通过主内存来传递。

volatile内存屏障操作
	LoadLoad、LoadStore、StoreStore、StoreLoad

Happens-Before(先行发生)规则
```

## 显式锁
### Lock
```textmate
Lock锁对比Java内置锁
1.可中断获取锁
2.可非阻塞获取锁
3.可限时抢锁
```

### ReentrantLock
```textmate
1)“可重入”含义:表示该锁能够支持一个线程对资源的重复加锁，也就是说，一个线程 可以多次进入同一个锁所同步的临界区代码块。比如，同一线程在外层函数获得锁后，在内层函 数能再次获取该锁，甚至多次抢占到同一把锁。
2)“独占”含义:在同一时刻只能有一个线程获取到锁，而其他获取锁的线程只能等待， 只有拥有锁的线程释放了锁后，其他的线程才能够获取锁。
```

### Condition
>  Lock代替了synchronized方法和语句的使用，而Condition代替了对象监视器方法的使用
```textmate
Condition实例本质上绑定到一个锁。要获取特定Lock实例的Condition实例，请使用其newCondition()方法。

基于显示锁进行“等待-通知”方式的线程间通信接口
Condition 的“等待-通知”方法和 Object 的“等待-通知”方法的语义等效关系为:
	- Condition 类的 awiat 方法和 Object 类的 wait 方法等效。
	- Condition 类的 signal 方法和 Object 类的 notify 方法等效。
	- Condition 类的 signalAll 方法和 Object 类的 notifyAll 方法等效。
Condition 对象的 signal(通知)方法和同一个对象的 await(等待)方法是一一配对使用的， 也就是说，一个 Condition 对象的 signal(或 signalAll)方法，不能去唤醒其他 Condition 对象上的 await 线程。
```

### LockSupport
> LockSupport 是 JUC 提供的一线程阻塞与唤醒的工具类，该工具类可以让线程在任意位置阻 塞和唤醒，其所有的方法都是静态方法。

- LockSupport.park()和 Thread.sleep()的区别
```textmate
从功能上说，LockSupport.park()与 Thread.sleep()方法类似，都是让线程阻塞，二者的区别如下:
(1)Thread.sleep()没法从外部唤醒，只能自己醒过来;而被LockSupport.park()方法阻塞的线程可以通过调用LockSupport.unpark()方法去唤醒。
(2)Thread.sleep()方法声明了 InterruptedException 中断异常，这是一个受检异常，调用者需要捕获这个异常或者再抛出;而使用 LockSupport.park()方法时，不需要捕获中断异常。
(3)LockSupport.park()方法、Thread.sleep()方法所阻塞的线程，当被阻塞线程的 Thread.interrup(t方法被调用时，被阻塞线程都会响应线程的中断信号，唤醒线程的执行。不同的是， 二者对中断信号的响应的方式不同。LockSupport.park( )方法不会抛出InterruptedException异常， 仅仅设置了线程的中断标志;而Thread.sleep()方法还会抛出InterruptedException 异常。
(4)与 Thread.sleep()相比，使用 LockSupport.park()能更精准、更加灵活的阻塞、唤醒指定 线程。
(5)Thread.sleep()本身就是一个 Native 方法;LockSupport.park()并不是一个 Native 方法，只是调用了一个Unsafe 类的Native方法(名字也叫 park)去实现。
(6)LockSupport.park()方法还允许设置一个 Blocker 对象，主要用来给监视工具或诊断工具 确定线程受阻塞的原因。
```

-  LockSupport.park( )与 Object.wait()的区别
```textmate
LockSupport.park()与 Object.wait()方法也类似，都是让线程阻塞，二者的区别如下:
(1)Object.wait()方法需要在synchronized块中执行;而LockSupport.park()可以在任意地方执行。
(2)当被阻塞线程被中断时，Object.wait()方法抛出了中断异常，调用者需要捕获或者再抛出;当被阻塞线程被中断时，LockSupport.park()不会抛出异常，使用时不需要处理中断异常。
(3)线程如果在Object.wait()执行之前去执行Object.notify()，会抛出 IllegalMonitorStateException异常，是不被允许的;而线程如果在LockSupport.park()执行之前去执行LockSupport.unPark()，不会抛出任何异常，是被允许的。
```

### 显式锁分类
```textmate
1. 可重入锁与不可重入锁
	可重入: 递归锁，同一个线程可重复获取当前对象的锁
	不可重入: 同一时间，只有一个线程能持有对象的锁
2. 悲观锁和乐观锁
	悲观锁: 每次操作都会加锁
	乐观锁: 基于AQS实现的锁都是乐观锁，操作不会加锁，采取在写时先读出当前版本号，然后加锁操作(失败则重复该操作)
	悲观锁适用于写多读少的场景，遇到高并发写时性能高；乐观锁用于读多写少的情况
3. 公平锁和非公平锁
	公平锁就是保障了各个线程获取锁都是按照顺序来的，先到的线程先获取锁，抢锁成功的次序体现为 FIFO(先进先出)顺序
4. 可中断锁和不可中断锁
	在抢锁过程中能通过某些方法去终止抢占过程，那就是可中断锁，否则就是不可 中断锁。
5. 共享锁和独占锁
	“独占锁”指的是每次只能有一个线程能持有的锁。
	“共享锁”允许多个线程同时获取锁，容许线程并发进入临界区。

其他
	CAS自旋锁可能会导致"总线风暴"，CLH 自旋锁(基于队列(具体为单向链表)排队的一种自旋锁),避免了总线风暴
	AQS是CLH的一个变种

```


### 高并发设计模式
```textmate
1.安全的单例模式
2.Master-Worker模式
3.ForkJoin模式
4.生产者消费者模式
5.Future模式
```
