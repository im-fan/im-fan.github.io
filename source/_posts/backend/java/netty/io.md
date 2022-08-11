---
title: IO
description: io
date: 2021-08-11 09:31:00
tags:
- io
categories:
- 后端
- io
---

### IO模型
|类型|解释|
|---|---|
|阻塞IO|返回数据就绪状态后，用户线程才能做其他动作|
|非阻塞IO|用户线程不断询问数据是否就绪|
|多路复用IO|即NIO(NewIO)  有一个线程不断去轮询多个 socket 的状态，只有当 socket 真正有读写事件时，才真正调用实际的 IO 读写操作，这个操作在内核中，比用户线程效率高<br/>缺点：一旦事件响应体很大，那么就会导致后续的事件迟迟得不到处理，并且会影响新的事件轮询。|
|信号驱动IO|当用户线程发起一个 IO 请求操作，会给对应的 socket 注册一个信号函数，然后用户线程会继续执行，当内核数据就绪时会发送一个信号给用户线程，用户线程接收到之后，在信号函数中调用 IO 读写操作来进行实际的 IO 请求操作|
|异步IO|最理想的IO模型  <br/>1.用户线程发起read操作，内核立即返回响应。<br/>2.内核接收到请求后，准备数据->copy至用户线程->给用户线程发信号<br/>比较：   信号驱动IO是需要client端调用函数操作IO，异步IO是内核异步处理，client端无需处理|

- 多路复用IO

```textmate
IO多路复用模型的IO涉及两种系统调用，一种是IO操作的系
统调用，另一种是select/epoll就绪查询系统调用。IO多路复用模型建立在操作系统的基础 设施之上，即操作系统的内核必须能够提供多路分离的系统调用select/epoll。
优点:一个选择器查询线程，可以同时处理成千上万的网络连接， 所以，用户程序不必创建大量的线程，也不必维护这些线程，从而大大减小了系统的开 销。这是一个线程维护一个连接的阻塞IO模式相比，使用多路IO复用模型的最大优势。
缺点:本质上，select/epoll系统调用是阻塞式的，属于同步IO。需要在读写事件就绪后，由系统调用本身负责进行读写，也就是说这个读写过程是阻塞 的
```

### IO包
|包名|类型/包|类名|
|---|---|---|
|java.io|字节流|InputStream|
|  |  |OutputStream|
|  |字符流|Reader|
|  | |Writer|
|java.nio|channels包||
|java.nio|charset包||
|java.nio|Buffer包||
|java.nio|ByteOrder||
|java.nio|MappedByteBuffer||


### 文件句柄(文件描述符)

- 解释
```textmate
文件句柄，也叫文件描述符。在Linux系统中，文件可分为:普通文件、目录文件、链 接文件和设备文件。
文件描述符(File Descriptor)是内核为了高效管理已被打开的文件所 创建的索引，它是一个非负整数(通常是小整数)，用于指代被打开的文件。
所有的IO系 统调用，包括socket的读写调用，都是通过文件描述符完成的。
```

- Linux的系统默认值为1024，需要解除文件句柄数的限制
- 调整步骤

```textmate
1.查看一个进程最大文件句柄数量
  ulimit -n

2.调整最大句柄数(当期会话有效)
  ulimit -n 1000000

3.永久调整最大句柄数(root权限)
    vim /etc/rc.local
    添加  ulimit -SHn 1000000
    解释: 选项-S表示软性极限值，-H表示硬性极限值。硬 性极限是实际的限制，就是最大可以是100万，不能再多了。软性极限值则是系统发出警告 (Warning)的极限值，超过这个极限值，内核会发出警告。

4.终极解除Linux系统的最大文件打开数量的限制
    vim /etc/security/limits.conf
    添加 
        soft nofile 1000000
        hard nofile 1000000
    解释: soft nofile表示软性极限，hard nofile表示硬性极限。
```

### NIO
#### Java NIO类库包含以下三个核心组件
- Channel(通道)
- Buffer(缓冲区)
- Selector(选择器)

#### NIO与OIO(Old IO)对比
```textmate
1)OIO是面向流(Stream Oriented)的，NIO是面向缓冲区(Buffer Oriented)的。 
面向流:
    在一般的OIO操作中，面向字节流或字符流的IO操作，总是以流式的方式顺序地从一个流(Stream)中读取一个或多个字节，因此，我们不能随意地改变读取指针的位置。
面向缓冲区:
    在NIO操作中则不同，NIO中引入了Channel(通道)和Buffer(缓冲区)的概念。面向缓冲 区的读取和写入，只需要从通道中读取数据到缓冲区中，或将数据从缓冲区中写入到通道 中。
    NIO不像OIO那样是顺序操作，可以随意地读取Buffer中任意位置的数据。

(2)OIO的操作是阻塞的，而NIO的操作是非阻塞的。
    OIO操作都是阻塞的，例如，我们调用一个 read方法读取一个文件的内容，那么调用read的线程会被阻塞住，直到read操作完成。
    而在NIO的非阻塞模式中，当我们调用read方法时，如果此时有数据，则read读取数据并返回;如果此时没有数据，则read也会直接返回，而不会阻塞当前线程。
    NIO的非阻塞: NIO使用了通道和 通道的多路复用技术。
(3)OIO没有选择器(Selector)概念，而NIO有选择器的概念。
NIO的实现是基于底层的选择器的系统调用，所以NIO的需要底层操作系统提供支持。
```
#### 通道(Channel)
```textmate
OIO: InputStream、OutputStream
NIO: 向通道中写入数据，也可以从通道中读取数据
```
#### 缓冲区(Buffer)
```textmate
所谓通道的读取，就是将数据从通道读取到缓冲区中;所谓通道的写入，就是将 数据从缓冲区中写入到通道中。
```

### 选择器(Selector)
```textmate
Selector 选择器可以理解为一个IO事件的监听与查询 器。通过选择器，一个线程可以查询多个通道的IO事件的就绪状态
```

## Buffer类
|属性|说明|
|:---:|---|
|capacity|容量，即可以容纳的最大数据量;在缓冲区创建时设置并且不能改变|
|limit|上限，缓冲区中当前的数据量|
|position|位置，缓冲区中下一个要被读或写的元素的索引|
|mark|调用 mark()方法来设置 mark=position，再调用 reset()可以让 position 恢复到 mark 标记的位置，即 position=mark|

