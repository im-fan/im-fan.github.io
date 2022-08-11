---
title: ES官方文档笔记
date: 2022-02-15 13:38:00
tags:
- es
categories:
- 存储
---

- [ElasticSearch官方教程(非最新版)](https://www.elastic.co/guide/cn/elasticsearch/guide/current/getting-started.html)

## 集群原理

### 空集群

```textmate
一个运行中的Elasticsearch实例称为一个节点，而集群是由一个或者多个拥有相同cluster.name配置的节点组成，它们共同承担数据和负载的压力。当有节点加入集群中或者从集群中移除节点时，集群将会重新平均分布所有的数据。

负责管理集群范围内的所有变更，例如增加、删除索引，或者增加、删除节点等。而主节点并不需要涉及到文档级别的变更和搜索等操作，所以当集群只拥有一个主节点的情况下，即使流量的增加它也不会成为瓶颈。任何节点都可以成为主节点。我们的示例集群就只有一个节点，所以它同时也成为了主节点。

作为用户，我们可以将请求发送到集群中的任何节点，包括主节点。每个节点都知道任意文档所处的位置，并且能够将我们的请求直接转发到存储我们所需文档的节点。无论我们将请求发送到哪个节点，它都能负责从各个包含我们所需文档的节点收集回数据，并将最终结果返回給客户端。
```

### 集群健康

```textmate
Elasticsearch的集群监控信息中包含了许多的统计数据，其中最为重要的一项就是集群健康，它在status字段中展示为green、yellow或者red。
GET/_cluster/health
1.green
	所有的主分片和副本分片都正常运行。
2.yellow
	所有的主分片都正常运行，但不是所有的副本分片都正常运行。
3.red
	有主分片没能正常运行。
```

### 索引

```textmate
索引实际上是指向一个或者多个物理分片的逻辑命名空间。
一个 分片 是一个底层的工作单元 ，它仅保存了全部数据中的一部分,一个分片是一个 Lucene 的实例，它本身就是一个完整的搜索引擎。
索引在默认情况下会被分配5个主分片，我们的文档被存储和索引到分片内，但是应用程序是直接与索引而不是与分片进行交互。

Elasticsearch 是利用分片将数据分发到集群内各处的。分片是数据的容器，文档保存在分片内，分片又被分配到集群内的各个节点里。 当你的集群规模扩大或者缩小时， Elasticsearch 会自动的在各节点中迁移分片，使得数据仍然均匀分布在集群里。

一个分片可以是 主分片或者 副本 分片。 索引内任意一个文档都归属于一个主分片，所以主分片的数目决定着索引能够保存的最大数据量。

```

- 添加索引语法

```textmate
PUT /blogs
{
   "settings" : {
      "number_of_shards" : 3,  //分片数量
      "number_of_replicas" : 1 //副本数量
   }
}
```

### 故障转移

```textmate
当你在同一台机器上启动了第二个节点时，只要它和第一个节点有同样的 cluster.name 配置，它就会自动发现集群并加入到其中。 但是在不同机器上启动节点的时候，为了加入到同一集群，你需要配置一个可连接到的单播主机列表。
```

### 水平扩容

```textmate
拥有三个节点的集群——为了分散负载而对分片进行重新分配
分片是一个功能完整的搜索引擎，它拥有使用一个节点上的所有资源的能力。 有6个分片（3个主分片和3个副本分片）的索引可以最大扩容到6个节点，每个节点上存在一个分片，并且每个分片拥有所在节点的全部资源。


主分片的数目在索引创建时就已经确定了下来。实际上，这个数目定义了这个索引能够 存储 的最大数据量。（实际大小取决于你的数据、硬件和使用场景。） 但是，读操作——搜索和返回数据——可以同时被主分片 或 副本分片所处理，所以当你拥有越多的副本分片时，也将拥有越高的吞吐量。

在运行中的集群上是可以动态调整副本分片数目的，我们可以按需伸缩集群
```

- 调整副本数量

```textmate
PUT /blogs/_settings
{
   "number_of_replicas" : 2
}
```

### 故障转移

```textmate
| Node1 | Node2 | Node3 |
|1* 2 3 |1 2*  3|1 2 3* |
*代表主分片

如果关闭Node1,则会失去1主分片，索引不能正常工作，此时集群状态是red;
其他节点会立即将Node2或Node3上的副本分片提升为主分片，此时集群状态是yellow,该动作是瞬时发生的；
如果重启Node1,集群可以将缺失的副本分片再次进行分配，如果Node1依然拥有之前的分片，则会尝试重用，仅从主分片复制改动过的数据文件
```

## 数据输入输出

> 在 Elasticsearch 中， 每个字段的所有数据 都是 默认被索引的 。 即每个字段都有为了快速检索设置的专用倒排索引

### 什么是文档

```textmate
在 Elasticsearch 中，术语 文档 有着特定的含义。它是指最顶层或者根对象, 这个根对象被序列化成 JSON 并存储到 Elasticsearch 中，指定了唯一 ID;

字段的名字可以是任何合法的字符串，但 不可以 包含英文句号(.)。
```

### 文档元数据

```textmate
三个必须的元数据元素：
  _index: 文档在哪存放
  _type: 文档表示的对象类别
  _id: 文档唯一标识
```

### 索引文档

```textmate
// 创建文档时使用自定义ID
PUT /website/blog/123
{
  "title": "My first blog entry",
  "text":  "Just trying this out...",
  "date":  "2014/01/01"
}

//创建文档时使用ES自动生成的ID
POST /website/blog/
{
  "title": "My second blog entry",
  "text":  "Still trying this out...",
  "date":  "2014/01/01"
}

/**
tips: 自动生成的 ID 是 URL-safe、 基于 Base64 编码且长度为20个字符的 GUID 字符串。 这些 GUID 字符串由可修改的 FlakeID 模式生成，这种模式允许多个节点并行生成唯一 ID ，且互相之间的冲突概率几乎为零。
**/
```

### 处理冲突

```textmate
乐观并发控制
每个文档都有一个 _version （版本）号，当文档被修改时版本号递增。 Elasticsearch 使用这个 _version 号来确保变更以正确顺序得到执行。如果旧版本的文档在新版本之后到达，它可以被简单的忽略。
```

## 分布式文档存储

### 路由一个文档到一个分片中

```textmate
计算公式：
shard = hash(routing) % number_of_primary_shards(主分片的数量)
routing是可变值，默认是文档的_id,也可以设置成一个自定义的值。
这就解释了为什么我们要在创建索引的时候就确定好主分片的数量 并且永远不会改变这个数量：因为如果数量变化了，那么所有之前路由的值都会无效，文档也再也找不到了。
```

### 主副分片交互

```textmate
我们可以发送请求到集群中的任一节点。 每个节点都有能力处理任意请求。 每个节点都知道集群中任一文档位置，所以可以直接将请求转发到需要的节点上。
将所有的请求发送到 Node 1 ，我们将其称为 协调节点(coordinating node) 。


tips:当发送请求的时候， 为了扩展负载，更好的做法是轮询集群中所有的节点。
```

### 新建、索引和删除文档时步骤

```textmate
以下是在主副分片和任何副本分片上面 成功新建，索引和删除文档所需要的步骤顺序：

1.客户端向 Node 1 发送新建、索引或者删除请求。
2.节点使用文档的 _id 确定文档属于分片 0 。请求会被转发到 Node 3，因为分片 0 的主分片目前被分配在 Node 3 上。
3.Node 3 在主分片上面执行请求。如果成功了，它将请求并行转发到 Node 1 和 Node 2 的副本分片上。一旦所有的副本分片都报告成功, Node 3 将向协调节点报告成功，协调节点向客户端报告成功。
```

### 查询文档步骤

```textmate
以下是从主分片或者副本分片检索文档的步骤顺序：

1、客户端向 Node 1 发送获取请求。
2、节点使用文档的 _id 来确定文档属于分片 0 。分片 0 的副本分片存在于所有的三个节点上。 在这种情况下，它将请求转发到 Node2。
3、Node2将文档返回给 Node 1 ，然后将文档返回给客户端。

在处理读取请求时，协调结点在每次请求的时候都会通过轮询所有的副本分片来达到负载均衡。

在文档被检索时，已经被索引的文档可能已经存在于主分片上但是还没有复制到副本分片。 在这种情况下，副本分片可能会报告文档不存在，但是主分片可能成功返回文档。 一旦索引请求成功返回给用户，文档在主分片和副本分片都是可用的。

考虑到分页过深以及一次请求太多结果的情况，结果集在返回之前先进行排序。 但请记住一个请求经常跨越多个分片，每个分片都产生自己的排序结果，这些结果需要进行集中排序以保证整体顺序是正确的。

深度分页问题: 在分布式系统中，对结果排序的成本随分页的深度成指数上升。这就是 web 搜索引擎对任何查询都不要返回超过 1000 个结果的原因。
```

### 更新局部文档步骤

```textmate
以下是部分更新一个文档的步骤：

1.客户端向 Node 1 发送更新请求。
2.它将请求转发到主分片所在的 Node 3 。
3.Node 3 从主分片检索文档，修改 _source 字段中的 JSON ，并且尝试重新索引主分片的文档。 如果文档已经被另一个进程修改，它会重试步骤 3 ，超过 retry_on_conflict 次后放弃。
4.如果 Node 3 成功地更新文档，它将新版本的文档并行转发到 Node 1 和 Node 2 上的副本分片，重新建立索引。 一旦所有副本分片都返回成功， Node 3 向协调节点也返回成功，协调节点向客户端返回成功。

ps: 当主分片把更改转发到副本分片时， 它不会转发更新请求。 相反，它转发完整文档的新版本。请记住，这些更改将会异步转发到副本分片，并且不能保证它们以发送它们相同的顺序到达。 如果Elasticsearch仅转发更改请求，则可能以错误的顺序应用更改，导致得到损坏的文档。
```

## 分片内部原理

### 倒排索引

```textmate
倒排索引被写入磁盘后是 不可改变 的:它永远不会修改。 不变性有重要的价值：

1.不需要锁。如果你从来不更新索引，你就不需要担心多进程同时修改数据的问题。
2.一旦索引被读入内核的文件系统缓存，便会留在哪里，由于其不变性。只要文件系统缓存中还有足够的空间，那么大部分读请求会直接请求内存，而不会命中磁盘。这提供了很大的性能提升。
3.其它缓存(像filter缓存)，在索引的生命周期内始终有效。它们不需要在每次数据改变时被重建，因为数据不会变化。
4.写入单个大的倒排索引允许数据被压缩，减少磁盘 I/O 和 需要被缓存到内存的索引的使用量。

当然，一个不变的索引也有不好的地方。主要事实是它是不可变的! 你不能修改它。如果你需要让一个新的文档 可被搜索，你需要重建整个索引。这要么对一个索引所能包含的数据量造成了很大的限制，要么对索引可被更新的频率造成了很大的限制。
```

### 索引与分片的比较

```textmate
一个 Lucene 索引 我们在 Elasticsearch 称作 分片 。 一个 Elasticsearch 索引 是分片的集合。 当 Elasticsearch 在索引中搜索的时候， 他发送查询到每一个属于索引的分片(Lucene 索引)，然后像 执行分布式检索 提到的那样，合并每个分片的结果到一个全局的结果集。
```

### 删除和更新

```textmate
当一个文档被 “删除” 时，它实际上只是在 .del 文件中被 标记 删除。一个被标记删除的文档仍然可以被查询匹配到， 但它会在最终结果被返回前从结果集中移除。

文档更新也是类似的操作方式：当一个文档被更新时，旧版本文档被标记删除，文档的新版本被索引到一个新的段中。 可能两个版本的文档都会被一个查询匹配到，但被删除的那个旧版本文档在结果集返回前就已经被移除。
```

### 持久化变更

```textmate
Elasticsearch 增加了一个 translog(事务日志)，在每一次对 Elasticsearch 进行操作时均进行了日志记录
1.一个文档被索引之后，就会被添加到内存缓冲区，并且 追加到了 translog 
2.刷新（refresh）, 缓存被清空但是事务日志不会
3.事务日志持续积累文档
4.每隔一段时间—例如 translog 变得越来越大，索引被刷新（flush）；一个新的 translog 被创建，并且一个全量提交被执行
	4.1所有在内存缓冲区的文档都被写入一个新的段。
  4.2缓冲区被清空。
  4.3一个提交点被写入硬盘。
  4.4文件系统缓存通过 fsync 被刷新（flush）。
  4.5老的 translog 被删除。
```

### Translog安全性

```textmate
在文件被 fsync 到磁盘前，被写入的文件在重启之后就会丢失。默认 translog 是每 5 秒被 fsync 刷新到硬盘， 或者在每次写请求完成之后执行(e.g. index, delete, update, bulk)。这个过程在主分片和复制分片都会发生。最终， 基本上，这意味着在整个请求被 fsync 到主分片和复制分片的translog之前，你的客户端不会得到一个 200 OK 响应。

在每次请求后都执行一个 fsync 会带来一些性能损失，尽管实践表明这种损失相对较小（特别是bulk导入，它在一次请求中平摊了大量文档的开销）。

但是对于一些大容量的偶尔丢失几秒数据问题也并不严重的集群，使用异步的 fsync 还是比较有益的。比如，写入的数据被缓存到内存中，再每5秒执行一次 fsync 。

这个行为可以通过设置 durability 参数为 async 来启用：
PUT /my_index/_settings
{
    "index.translog.durability": "async",
    "index.translog.sync_interval": "5s"
}
这个选项可以针对索引单独设置，并且可以动态进行修改。如果你决定使用异步 translog 的话，你需要 保证 在发生crash时，丢失掉 sync_interval 时间段的数据也无所谓。
```

### 刷新

```textmate
在 Elasticsearch 中，写入和打开一个新段的轻量的过程叫做 refresh 。 默认情况下每个分片会每秒自动刷新一次。这就是为什么我们说 Elasticsearch 是 近 实时搜索: 文档的变化并不是立即对搜索可见，但会在一秒之内变为可见。
// 手动刷新数据 
POST /_refresh  //刷新所有索引
POST /blogs/_refresh  //只刷新blogs索引
```

### 段合并

```textmate
目的：
	由于自动刷新流程每秒会创建一个新的段 ，这样会导致短时间内的段数量暴增。而段数目太多会带来较大的麻烦。 每一个段都会消耗文件句柄、内存和cpu运行周期。更重要的是，每个搜索请求都必须轮流检查每个段；所以段越多，搜索也就越慢。
	Elasticsearch通过在后台进行段合并来解决这个问题。小的段被合并到大的段，然后这些大的段再被合并到更大的段。

流程：
  1.当索引的时候，刷新（refresh）操作会创建新的段并将段打开以供搜索使用。
  2.合并进程选择一小部分大小相似的段，并且在后台将它们合并到更大的段中。这并不会中断索引和搜索。
  3.合并结束，老的段被删除
  
tips:合并大的段需要消耗大量的I/O和CPU资源，默认下会对合并流程进行资源限制

optimeze API(强制合并)
介绍: optimize API大可看做是 强制合并 API。它会将一个分片强制合并到 max_num_segments 参数指定大小的段数目。 这样做的意图是减少段的数量（通常减少到一个），来提升搜索性能。
tips: 
	1.optimize API 不应该 被用在一个活跃的索引————一个正积极更新的索引。后台合并流程已经可以很好地完成工作。
	2.使用 optimize API 触发段合并的操作不会受到任何资源上的限制。这可能会消耗掉你节点上全部的I/O资源
```

## 常用查找语法

### 精确查找(包含，不是等于)

```textmate
//term查数字
GET /my_store/products/_search
{
    "query" : {
        "constant_score" : { 
            "filter" : {
                "term" : { 
                    "price" : 20
                }
            }
        }
    }
}

//term查文本
原词可能会被分词,构建索引时，需要指定不分析值
"index" : "not_analyzed" 

//terms匹配多个内容	

//运行非评分查询(精确查询)时的步骤
1.查找匹配文档
2.创建bitset(一个包含 0 和 1 的数组），它描述了哪个文档会包含该 term 
3.迭代bitsets
4.增量计数
```

### 组合过滤器

- 布尔过滤器

```textmate
{
   "bool" : {
      "must" :     [],  //相当于and,有评分
      "should" :   [],  //相当于or
      "must_not" : [],  //相当于not
      "filter" : []     //过滤查询，无评分
   }
}
```

### 范围

```textmate
"range" : {
    "price" : {
        "gte" : 20,
        "lte" : 40
    }
}
/**
  gt: > 大于（greater than）
  lt: < 小于（less than）
  gte: >= 大于或等于（greater than or equal to）
  lte: <= 小于或等于（less than or equal to）
**/

// 特殊用法
//1.时间计算： 查找时间戳在过去一小时内的所有文档
"range" : {
    "timestamp" : {
        "gt" : "now-1h"
    }
}
"range" : {
    "timestamp" : {
        "gt" : "2014-01-01 00:00:00",
        "lt" : "2014-01-01 00:00:00||+1M"  //早于2014年1月1日加1月（2014年2月1日零时）
    }
}

//2.字符串范围(效率较低)
"range" : {
    "title" : {
        "gte" : "a",
        "lt" :  "b"
    }
}
```

### Null值查询

```textmate
// 存在查询 exist
GET /my_index/posts/_search
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "exists" : { "field" : "tags" }
            }
        }
    }
}

//不存在查询
GET /my_index/posts/_search
{
    "query" : {
        "constant_score" : {
            "filter": {
                "missing" : { "field" : "tags" }
            }
        }
    }
}

//对象的存在与不存在 
//如果 first 和 last 都是空，那么 name 这个命名空间才会被认为不存在。
{  //对象数据
   "name" : {
      "first" : "John",
      "last" :  "Smith"
   }
}

{ //查询语句
    "exists" : { "field" : "name" }
}

{ //实际执行的语句
    "bool": {
        "should": [
            { "exists": { "field": "name.first" }},
            { "exists": { "field": "name.last" }}
        ]
    }
}
```

### 缓存

```textmate
自动缓存
Elasticsearch 会基于使用频次自动缓存查询。如果一个非评分查询在最近的 256 次查询中被使用过（次数取决于查询类型），那么这个查询就会作为缓存的候选。但是，并不是所有的片段都能保证缓存 bitset 。只有那些文档数量超过 10,000 （或超过总文档数量的 3% )才会缓存 bitset 。因为小的片段可以很快的进行搜索和合并，这里缓存的意义不大。

一旦缓存了，非评分计算的 bitset 会一直驻留在缓存中直到它被剔除。剔除规则是基于 LRU 的：一旦缓存满了，最近最少使用的过滤器会被剔除。
```

## 相关度

### 相关度评分逻辑

```textmate
Lucene（或 Elasticsearch）使用 布尔模型（Boolean model） 查找匹配文档，并用一个名为 实用评分函数（practical scoring function） 的公式来计算相关度。这个公式借鉴了 词频/逆向文档频率（term frequency/inverse document frequency） 和 向量空间模型（vector space model），同时也加入了一些现代的新特性，如协调因子（coordination factor），字段长度归一化（field length normalization），以及词或查询语句权重提升。
```

#### 布尔模型

```textmate
布尔模型（Boolean Model）只是在查询中使用 AND、OR 和 NOT（与、或和非）这样的条件来查找匹配的文档，以下查询：

full AND text AND search AND (elasticsearch OR lucene)
会将所有包括词 full 、 text 和 search ，以及 elasticsearch 或 lucene 的文档作为结果集。
```



#### 词频/逆向文档频率(TF/IDF)

```textmate
当匹配到一组文档后，需要根据相关度排序这些文档，不是所有的文档都包含所有词，有些词比其他的词更重要。一个文档的相关度评分部分取决于每个查询词在文档中的 权重 。

词频
词在文档中出现的频度越高，权重越高 。

逆向文档频率
词在集合所有文档里出现的频次越高，权重越低 
```

#### 字段长度归一

```textmate
字段的长度越短，字段的权重越高。
字段长度归一值(norm)
```

#### 组合使用

```textmate
词频（term frequency）、逆向文档频率（inverse document frequency）和字段长度归一值（field-length norm）——是在索引时计算并存储的。最后将它们结合在一起计算单个词在特定文档中的权重 。
```

### 脚本评分

```textmate
如果所有 function_score 内置的函数都无法满足应用场景，可以使用 script_score 函数自行实现逻辑
Elasticsearch 里使用 Groovy 作为默认的脚本语言
例子:
入参: 
	price和margin变量可以分别从文档中提取
	threshold、discount、target是作为参数params传入的

GET /_search
{
  "function_score": {
    "functions": [
      { ...location clause... }, 
      { ...price clause... }, 
      {
        "script_score": {
          "params": { 
            "threshold": 80,
            "discount": 0.1,
            "target": 10
          },
          "script": "price  = doc['price'].value; margin = doc['margin'].value;
          if (price < threshold) { return price * margin / target };
          return price * (1 - discount) * margin / target;" 
        }
      }
    ]
  }
}

tips: 
  1.将这些变量作为参数 params 传递，我们可以查询时动态改变脚本无须重新编译。
  2.JSON 不能接受内嵌的换行符，脚本中的换行符可以用 \n 或 ; 符号替代
```

## 人类语言处理

```textmate
分词器
  standard(标准分词器)、english(英文分词器)、icu(亚洲语言分词器)
 
错误拼写匹配-语音匹配
	搜索发音相似的词，即使他们的拼写不同。 Soundex算法
```

## 聚合

### 主要概念

```textmate
桶（Buckets）
	满足特定条件的文档的集合
指标（Metrics）
	对桶内的文档进行统计计算
每个聚合都是一个或者多个桶和零个或者多个指标的组合

桶在概念上类似于 SQL 的分组（GROUP BY），而指标则类似于 COUNT() 、 SUM() 、 MAX() 等统计方法。

例：
SELECT COUNT(color)  FROM table GROUP BY color;
1.COUNT(color) 相当于指标。
2.GROUP BY color 相当于桶。
```

### 桶

```textmate
桶 简单来说就是满足特定条件的文档的集合
1.当聚合开始被执行，每个文档里面的值通过计算来决定符合哪个桶的条件。如果匹配到，文档将放入相应的桶并接着进行聚合操作。
2.桶也可以被嵌套在其他桶里面，提供层次化的或者有条件的划分方案。
3.Elasticsearch 有很多种类型的桶，能让你通过很多种方式来划分文档（时间、最受欢迎的词、年龄区间、地理位置等等）。其实根本上都是通过同样的原理进行操作：基于条件来划分文档。
```

### 指标

```textmate
桶能让我们划分文档到有意义的集合，但是最终我们需要的是对这些桶内的文档进行一些指标的计算。分桶是一种达到目的的手段：它提供了一种给文档分组的方法来让我们可以计算感兴趣的指标。

大多数 指标 是简单的数学运算（例如最小值、平均值、最大值，还有汇总），这些是通过文档的值来计算。在实践中，指标能让你计算像平均薪资、最高出售价格、95%的查询延迟这样的数据。

聚合 
	由桶和指标组成的。 聚合可能只有一个桶，可能只有一个指标，或者可能两个都有。也有可能有一些桶嵌套在其他桶里面。
```

### 条形图

```textmate
聚合还有一个令人激动的特性就是能够十分容易地将它们转换成图表和图形。
例:
GET /cars/transactions/_search
{
   "size" : 0,
   "aggs":{
      "price":{
         "histogram":{
            "field": "price",
            "interval": 20000
         },
         "aggs":{
            "revenue": {
               "sum": { 
                 "field" : "price"
               }
             }
         }
      }
   }
}

//响应结果-直方图
{
...
   "aggregations": {
      "price": {
         "buckets": [
            {
               "key": 0,
               "doc_count": 3,
               "revenue": {
                  "value": 37000
               }
            },
            {
               "key": 20000,
               "doc_count": 4,
               "revenue": {
                  "value": 95000
               }
            }
         ]
      }
   }
}
```

### 按时间统计

```textmate
//查询脚本
GET /cars/transactions/_search
{
   "size" : 0,
   "aggs": {
      "sales": {
         "date_histogram": {
            "field": "sold",
            "interval": "month", 
            "format": "yyyy-MM-dd",
           	"min_doc_count" : 0,    //强制返回空 buckets。
            "extended_bounds" : {   //强制返回整年。
                "min" : "2014-01-01",
                "max" : "2014-12-31"
            }
         }
      }
   }
}

//返回结果
{
   ...
   "aggregations": {
      "sales": {
         "buckets": [
            {
               "key_as_string": "2014-01-01",
               "key": 1388534400000,
               "doc_count": 1
            },
            {
               "key_as_string": "2014-02-01",
               "key": 1391212800000,
               "doc_count": 1
            }
         ]
...
}
```

### Doc Values

```textmate
1.聚合使用一个叫 doc values 的数据结构。Doc values 可以使聚合更快、更高效并且内存友好
2.Doc values 的存在是因为倒排索引只对某些操作是高效的。 倒排索引的优势 在于查找包含某个项的文档，而对于从另外一个方向的相反操作并不高效，即：确定哪些项是否存在单个文档里，聚合需要这种次级的访问模式。
3.Doc Values 是在索引时与 倒排索引 同时生成。也就是说 Doc Values 和 倒排索引 一样，基于 Segement 生成并且是不可变的。同时 Doc Values 和 倒排索引 一样序列化到磁盘，这样对性能和扩展性有很大帮助。

Doc Values 通过序列化把数据结构持久化到磁盘，我们可以充分利用操作系统的内存，而不是 JVM 的 Heap 。 当 working set 远小于系统的可用内存，系统会自动将 Doc Values 驻留在内存中，使得其读写十分快速；不过，当其远大于可用内存时，系统会根据需要从磁盘读取 Doc Values，然后选择性放到分页缓存中。

原理:
	Doc values 通过转置两者间的关系来解决这个问题。倒排索引将词项映射到包含它们的文档，doc values 将文档映射到它们包含的词项
	
用途:
Doc values 不仅可以用于聚合。 任何需要查找某个文档包含的值的操作都必须使用它。 除了聚合，还包括排序，访问字段值的脚本，父子关系处理
```

## 地理位置

```textmate
Elasticsearch 提供了 两种表示地理位置的方式：
1.用纬度－经度表示的坐标点使用 geo_point 字段类型
2.用GeoJSON 格式定义的复杂地理形状，使用 geo_shape 字段类型。

Geo-points 允许你找到距离另一个坐标点一定范围内的坐标点、计算出两点之间的距离来排序或进行相关性打分、或者聚合到显示在地图上的一个网格。另一方面，Geo-shapes 纯粹是用来过滤的。它们可以用来判断两个地理形状是否有重合或者某个地理形状是否完全包含了其他地理形状。

Geohashes 是一种将经纬度坐标（ lat/lon ）编码成字符串的方式。这么做的初衷只是为了让地理位置在 url 上呈现的形式更加友好，但现在 geohashes 已经变成一种在数据库中有效索引地理坐标点和地理形状的方式。
Geohashes 把整个世界分为 32 个单元的格子 —— 4 行 8 列 —— 每一个格子都用一个字母或者数字标识。
```

## 数据建模

```textmate
Elasticsearch建模
	关联关系处理 、 嵌套对象 和 父-子关系文档 
另外ES支持多种扩容方式
```

## 运维

```textmate
支持动态更新的参数
https://www.elastic.co/guide/en/elasticsearch/reference/5.6/cluster-update-settings.html
集群备份、快照恢复
```

## ES使用时该注意什么
- 一定要配置密码,推荐[SearchGuard](https://search-guard.com/)
- [危害-在线赌场泄漏 1.08 亿投注信息，ElasticSearch 再成祸首](https://www.infoq.cn/article/ZzAZ0wZ0JmzfxSj-v1lU)
- [一个月 6 次泄露，为啥大家用 Elasticsearch 总不设密码](https://www.infoq.cn/article/Pmc0PXdFdXHB*T5CygVJ)

## 扩展阅读
- [搜索之路：Elasticsearch的诞生](https://mp.weixin.qq.com/s/mnhtYvR_5N7gtIOgjSUJmA)
- [es 在数据量很大的情况下（数十亿级别）如何提高查询效率啊？](https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/es-optimizing-query-performance.md)
- [滴滴基于 ElasticSearch 的一站式搜索中台实践](https://www.infoq.cn/article/ug*cbrk9303MiNZPrSEO)
- [让Elasticsearch飞起来！百亿级实时查询优化实战](https://mp.weixin.qq.com/s/Fvf9JcOc5oSRlLdHB4tYxA)
- [Elasticsearch读写中间件的设计](https://mp.weixin.qq.com/s/g9_eXCouaaBobU9Emjp9bA)
- [如何使用 Elasticsearch 构建企业级搜索方案？](https://www.infoq.cn/article/build-enterprise-search-scenarios-using-elasticsearch)
- [Elasticsearch学习，请先看这一篇！](https://cloud.tencent.com/developer/article/1066239)



## 案例

### 重建索引步骤
> 总体思路: 创建备份索引，复制数据，删除旧索引，新建索引，复制数据，删除备份索引
```textmate
例如： user_index  user_index_alias
# 新建备份索引
PUT user_index_bak
{   
    "settings":{
        "number_of_replicas": 1,
        "number_of_shards": 1
        -- 分词器设置
    },
    "mappings":{
        "user_index_bak":{
            "properties":{
                "id":{
                    "type": "keyword"
                }
            }
        }
    }
}

#复制数据
POST _reindex
{
  "source": {
    "index": "user_index"
  },
  "dest": {
    "index": "user_index_bak"
  }
}

#查询复制的数据
GET user_index_bak/_search
{"query":{"match_all":{}}}

# 查询配置
GET user_index_bak/_mapping
GET user_index_bak/_settings

# 删除索引
DELETE  user_index

#重建
PUT user_index
{   
    "settings":{
        "number_of_replicas": 1,
        "number_of_shards": 1
        -- 分词器设置
    },
    "mappings":{
        "user_index_bak":{
            "properties":{
                "id":{
                    "type": "keyword"
                }
            }
        }
    }
}

# 创建索引别名
PUT _alias
{
  "actions" : [{"add" : {"index" : "user_index" , "alias" : "user_index_alias"}}]
}


# 复制数据
POST _reindex
{
  "source": {
    "index": "user_index_bak"
  },
  "dest": {
    "index": "user_index_alias"
  }
}

# 查询数据
POST user_index_alias/_search
{"query":{"match_all":{}}}

# 查询配置
GET user_index_alias/_mapping
GET user_index_alias/_settings

#删除备份索引
DELETE  user_index_bak
```
