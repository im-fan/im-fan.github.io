
### 同一个事务下对同一条记录查询后修改,再查询，第二次查询走的缓存
```java
class demo{
    @Override
    @Transactional
    public PartJobPO getByIdTest(Long id) {
        PartJobPO jobPO = this.getById(id);
        jobPO.setTitle("aaaa");

        PartJobPO jobPO2 = this.getById(id);
        return jobPO2;
    }
}
```

#### 原理
DefaultSqlSession ==> BaseExecutor

//BaseExecutor中
list = resultHandler == null ? (List)this.localCache.getObject(key) : null;
if (list != null) {
this.handleLocallyCachedOutputParameters(ms, key, parameter, boundSql);
} else {
list = this.queryFromDatabase(ms, parameter, rowBounds, resultHandler, key, boundSql);
}

#### 相关原理
https://blog.csdn.net/weixin_38362455/article/details/92839515?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-92839515-blog-79615168.pc_relevant_multi_platform_whitelistv3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-92839515-blog-79615168.pc_relevant_multi_platform_whitelistv3&utm_relevant_index=1
