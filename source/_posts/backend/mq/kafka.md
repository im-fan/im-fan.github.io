---
title: SpringBoot集成Kafka
date: 2021-02-03 16:06:00
tags:
- message
- kafka

categories:
- 后端
- 消息队列
- kafka
---

### 简单案例
#### 引用包
```xml
<!-- 设置了版本号，有可能会报错ClassNotFound -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

#### 配置
```yaml
spring:
  kafka:
  topic: testTopic
  bootstrap-servers: 127.0.0.1:9092
  producer:
    retries: 0
    batch-size: 50
    buffer-memory: 6554432
    key-serializer: org.apache.kafka.common.serialization.StringSerializer
    value-serializer: org.apache.kafka.common.serialization.StringSerializer
    properties:
      max:
        request:
          size: 5242880
      linger.ms: 1
```

#### 发送消息
```java
@Slf4j
@Component
public class MessageService{
    
    @Autowired
    private KafkaTemplate kafkaTemplate;
    @Value("${spring.kafka.topic}")
    private String topics;
    
    public void sendSyncMessage(String resourceName){
        try{
            kafkaTemplate.send(topics,resourceName);
        } catch (Exception e) {
            log.error("message send failed, error={}", e);
        }
    }
}
```

#### 监听消息
```java
@Slf4j
@Component
public class MessageListener {

    @KafkaListener(topics = {"testTopic"}, groupId = "testGroupId")
    public void annul1(ConsumerRecord<String, String> record) {
        log.info("groupId = myContainer2, message = " + record.toString());
    }
}
```

### 双kafka案例
- [SpringBoot多kafka配置](https://www.byteblogs.com/article/434)
#### 配置文件
```yaml
spring:
  kafka:
    kafka1:
      bootstrap-servers: 127.0.0.1:9092
      producer:
        retries: 0
        batch-size: 50
        buffer-memory: 6554432
        key-serializer: org.apache.kafka.common.serialization.StringSerializer
        value-serializer: org.apache.kafka.common.serialization.StringSerializer
        properties:
          max:
            request:
              size: 5242880
          linger.ms: 1
    kafka2:
      bootstrap-servers: 127.0.0.1:9092
      producer:
        retries: 0
        batch-size: 50
        buffer-memory: 6554432
        key-serializer: org.apache.kafka.common.serialization.StringSerializer
        value-serializer: org.apache.kafka.common.serialization.StringSerializer
        properties:
          max:
            request:
              size: 5242880
          linger.ms: 1
```

#### 代码配置
- 实例1配置
```java
@Configuration
@EnableKafka
public class Kafka1Config {

    @Bean("kafka1ExtListenerKafkaProperties")
    @Primary
    @ConfigurationProperties(prefix = "spring.kafka.kafka1")
    public KafkaProperties kafka1ExtListenerKafkaProperties() {
        return new KafkaProperties();
    }

    @Bean("kafka1ListenerContainerFactory")
    @Primary
    KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<Integer, String>> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<Integer, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setConcurrency(3);
        factory.getContainerProperties().setPollTimeout(3000);
        return factory;
    }

    private ConsumerFactory<Integer, String> consumerFactory() {
        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
    }

    private Map<String, Object> consumerConfigs() {
        return kafka1ExtListenerKafkaProperties().buildConsumerProperties();
    }

    @Bean("kafkaTemplate")
    @Primary
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    private ProducerFactory<String, String> producerFactory() {
        DefaultKafkaProducerFactory<String, String> producerFactory = new DefaultKafkaProducerFactory<>(producerConfigs());
        return producerFactory;
    }

    private Map<String, Object> producerConfigs() {
        return kafka1ExtListenerKafkaProperties().buildProducerProperties();
    }
}
```

- 实例2配置
```java
@Configuration
@EnableKafka
public class Kafka2Config {

    @Bean("kafka2ListenerKafkaProperties")
    @ConfigurationProperties(prefix = "spring.kafka.kafka2")
    public KafkaProperties kafka2ListenerKafkaProperties() {
        return new KafkaProperties();
    }

    @Bean("kafka2ListenerContainerFactory")
    public KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<Integer, String>> kafka2ListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<Integer, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setConcurrency(3);
        factory.getContainerProperties().setPollTimeout(3000);
        return factory;
    }

    /**
     * 消费者工厂的bean
     *
     * @return
     */
    private ConsumerFactory<Integer, String> consumerFactory() {
        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
    }

    private Map<String, Object> consumerConfigs() {
        return kafka2ListenerKafkaProperties().buildConsumerProperties();
    }

    @Bean("kafka2Template")
    public KafkaTemplate<String, String> kafka2Template() {
        return new KafkaTemplate<>(producerFactory());
    }

    private ProducerFactory<String, String> producerFactory() {
        DefaultKafkaProducerFactory<String, String> producerFactory = new DefaultKafkaProducerFactory<>(producerConfigs());
        return producerFactory;
    }

    private Map<String, Object> producerConfigs() {
        return kafka2ListenerKafkaProperties().buildProducerProperties();
    }
}
```

#### 使用
```java
@Slf4j
@Service
public class MessageSendService{
    @Resource(name = "kafkaTemplate")
    private KafkaTemplate<String, Object> kafkaTemplate;

    @Resource(name = "kafkaTemplateForMonitor")
    private KafkaTemplate<String, Object> kafkaTemplateForMonitor;

    public boolean kafka1Send(String topic, String message) {
        try {
            if (kafkaMq) {
                kafkaTemplate.send(topic, message);
            }
        } catch (Exception e) {
            log.warn("kafka1 发送kafka消息失败 topic={},error={}",topic,e);
        }
        return true;
    }
    
    public boolean kafka2Send(String topic, String message){
        try {
            kafkaTemplateForMonitor.send(topic, message);
        } catch (Exception e) {
            log.warn("kafka2 发送kafka消息失败 topic={},error={}",topic,e);
        }
        return true;
    }
}
```
