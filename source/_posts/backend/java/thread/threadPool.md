---
title: ThreadPool详解
description: 线程池
date: 2021-02-09 14:12:45
tags:
- 线程池
categories:
- 后端
- 线程池
---

#### 构造方法签名
```textmate
ThreadPoolExecutor(int corePoolSize,
        int maximumPoolSize,
        long keepAliveTime,
        TimeUnit unit,
        BlockingQueue<Runnable> workQueue,
        ThreadFactory threadFactory,
        RejectedExecutionHandler handler)
        
corePoolSize - 池中所保存的线程数，包括空闲线程。
maximumPoolSize - 池中允许的最大线程数。
keepAliveTime - 当线程数大于核心时，此为终止前多余的空闲线程等待新任务的最长时间。
unit - keepAliveTime参数的时间单位。
workQueue - 执行前用于保持任务的队列。此队列仅保持由 execute方法提交的 Runnable任务。
threadFactory - 执行程序创建新线程时使用的工厂。
handler - 由于超出线程范围和队列容量而使执行被阻塞时所使用的处理程序。
```

#### 官方封装好的线程池
```textmate
ThreadPoolExecutor是Executors类的底层实现。

1. newSingleThreadExecutor（单个后台线程）
    创建一个单线程的线程池。这个线程池只有一个线程在工作，也就是相当于单线程串行执行所有任务。如果这个唯一的线程因为异常结束，那么会有一个新的线程来替代它。
    此线程池保证所有任务的执行顺序按照任务的提交顺序执行。

2.newFixedThreadPool（固定大小线程池）
    创建固定大小的线程池。每次提交一个任务就创建一个线程，直到线程达到线程池的最大大小。线程池的大小一旦达到最大值就会保持不变，
    如果某个线程因为执行异常而结束，那么线程池会补充一个新线程。

3. newCachedThreadPool（无界线程池，可以进行自动线程回收）
    创建一个可缓存的线程池。如果线程池的大小超过了处理任务所需要的线程，
    那么就会回收部分空闲（60秒不执行任务）的线程，当任务数增加时，此线程池又可以智能的添加新线程来处理任务。
    此线程池不会对线程池大小做限制，线程池大小完全依赖于操作系统（或者说JVM）能够创建的最大线程大小。

4.newScheduledThreadPool
    创建一个大小无限的线程池。此线程池支持定时以及周期性执行任务的需求。
```

#### 排队策略
```textmate
排队有三种通用策略：

1.直接提交
    工作队列的默认选项是 SynchronousQueue，它将任务直接提交给线程而不保持它们。在此，如果不存在可用于立即运行任务的线程，
    则试图把任务加入队列将失败，因此会构造一个新的线程。此策略可以避免在处理可能具有内部依赖性的请求集时出现锁。
    直接提交通常要求无界 maximumPoolSizes 以避免拒绝新提交的任务。当命令以超过队列所能处理的平均数连续到达时，此策略允许无界线程具有增长的可能性。
    
2.无界队列。
    使用无界队列（例如，不具有预定义容量的 LinkedBlockingQueue）将导致在所有 corePoolSize 线程都忙时新任务在队列中等待。
    这样，创建的线程就不会超过 corePoolSize。（因此，maximumPoolSize的值也就无效了。）当每个任务完全独立于其他任务，即任务执行互不影响时，
    适合于使用无界队列；例如，在 Web页服务器中。这种排队可用于处理瞬态突发请求，当命令以超过队列所能处理的平均数连续到达时，此策略允许无界线程具有增长的可能性。

3.有界队列。
    当使用有限的 maximumPoolSizes时，有界队列（如 ArrayBlockingQueue）有助于防止资源耗尽，但是可能较难调整和控制。
    队列大小和最大池大小可能需要相互折衷：使用大型队列和小型池可以最大限度地降低 CPU 使用率、操作系统资源和上下文切换开销，但是可能导致人工降低吞吐量。
    如果任务频繁阻塞（例如，如果它们是 I/O边界），则系统可能为超过您许可的更多线程安排时间。使用小型队列通常要求较大的池大小，CPU使用率较高，
    但是可能遇到不可接受的调度开销，这样也会降低吞吐量。
```

#### BlockingQueue的选择
```textmate
例子一：使用直接提交策略，也即SynchronousQueue。
    首先SynchronousQueue是无界的，也就是说他存数任务的能力是没有限制的，但是由于该Queue本身的特性，在某次添加元素后必须等待其他线程取走后才能继续添加。

例子二：使用无界队列策略，即LinkedBlockingQueue
    corePoolSize大小的线程数会一直运行，忙完当前的，就从队列中拿任务开始运行。要防止任务疯长，比如任务运行的实行比较长

例子三：有界队列，使用ArrayBlockingQueue。
    这个是最为复杂的使用，所以JDK不推荐使用。与上面的相比，最大的特点便是可以防止资源耗尽的情况发生。假设，所有的任务都永远无法执行完。
    对于首先来的A,B来说直接运行，接下来，如果来了C,D，他们会被放到queue中，如果接下来再来E,F，则增加线程运行E，F。但是如果再来任务，队列无法再接受了，
    线程数也到达最大的限制了，所以就会使用拒绝策略来处理。
```

#### 拒绝策略
```textmate
在ThreadPoolExecutor中已经默认包含了4中拒绝策略
1.CallerRunsPolicy
    线程调用运行该任务的 execute 本身。此策略提供简单的反馈控制机制，能够减缓新任务的提交速度。
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
        if (!e.isShutdown()) {
             r.run();
         }
    }
这个策略显然不想放弃执行任务。但是由于池中已经没有任何资源了，那么就直接使用调用该execute的线程本身来执行。

2.AbortPolicy
    处理程序遭到拒绝将抛出运行时RejectedExecutionException
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
       throw new RejectedExecutionException();
    }
    这种策略直接抛出异常，丢弃任务。

3.DiscardPolicy
    不能执行的任务将被删除
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {}
    这种策略和AbortPolicy几乎一样，也是丢弃任务，只不过他不抛出异常。

4.DiscardOldestPolicy
    如果执行程序尚未关闭，则位于工作队列头部的任务将被删除，然后重试执行程序（如果再次失败，则重复此过程）
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
        if (!e.isShutdown()) {
            e.getQueue().poll();
            e.execute(r);
        }
    }
    该策略就稍微复杂一些，在pool没有关闭的前提下首先丢掉缓存在队列中的最早的任务，然后重新尝试运行该任务。这个策略需要适当小心。
    设想:如果其他线程都还在运行，那么新来任务踢掉旧任务，缓存在queue中，再来一个任务又会踢掉queue中最老任务。
```

#### 自定义线程池名称
```textmate
ThreadFactory springThreadFactory = new CustomizableThreadFactory("xxx-pool-");
```

#### 总结
```textmate
总结：
keepAliveTime和maximumPoolSize及BlockingQueue的类型均有关系。如果BlockingQueue是无界的，那么永远不会触发maximumPoolSize，自然keepAliveTime也就没有了意义。
反之，如果核心数较小，有界BlockingQueue数值又较小，同时keepAliveTime又设的很小，如果任务频繁，那么系统就会频繁的申请回收线程
```

#### 配置计算公式
```textmate
为了使CPU达到期望使用率，线程池的最优大小为
线程个数 = cpu个数 * cpu利用率 * （1+ IO处理时间 / CPU处理时间)
```
