---
title: Java解析Swagger文档接口及参数
description: 解析swagger-ui
date: 2020-11-11 19:30
tags:
- utils
categories:
- 后端
- 工具
---

### 相关依赖包
```text
<!--swagger依赖-->
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.9.2</version>
</dependency>
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.9.2</version>
</dependency>
<dependency>
    <groupId>com.github.xiaoymin</groupId>
    <artifactId>swagger-bootstrap-ui</artifactId>
    <version>1.9.6</version>
</dependency>

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.73</version>
</dependency>

```

### Swagger文档相关接口
```text
1.接口文档地址
    https://localhost:8080/swagger-ui.html
    https://localhost:8080/doc.html

2.JSON格式接口数据(group参数由项目中swagger配置决定)
    http://localhost:8080/v2/api-docs?group=V1版本

```

### 主要代码
```text

/**
 * 加载swagger文档中的接口信息
 * @Date 2020/11/6 11:31
 * @Author fan
**/
public boolean loadSwaggerAPI(Integer lesseeId,String url){
    try {
        log.info("开始加载Swagger文档,url={}",url);
        String result = OkhttpClientUtil.get(url);
        JSONObject jsonObject = JSON.parseObject(result);
        if(jsonObject == null){
            return false;
        }
        //移除对象描述信息
        String platform = (String) JSON.parseObject(JSON.toJSONString(jsonObject.get("info"))).get("title");
        JSONObject paths = (JSONObject) jsonObject.get("paths");
        JSONObject definitions = (JSONObject) jsonObject.get("definitions");
        Map<String,JSONObject> paramMap = JSONObject.toJavaObject(definitions,Map.class);

        List<PublicResourceInfo> resourceInfos = new ArrayList<>();
        for(Map.Entry<String,Object> entry :  paths.entrySet()){
            String apiUrl = entry.getKey();
            String perms = resourceInfoService.buildPermByApiPath(null,apiUrl);
            JSONObject methodInfo = (JSONObject) entry.getValue();

            for(Map.Entry<String,Object> methodEntry : methodInfo.entrySet()){
                String requestType = methodEntry.getKey().toUpperCase();

                JSONObject requestTypeInfo = (JSONObject) methodEntry.getValue();
                String apiName = String.valueOf(requestTypeInfo.get("summary"));
                String moduleName = StringUtils.join((List<String>)requestTypeInfo.get("tags"),",");

                PublicResourceInfo resourceInfo = new PublicResourceInfo();
                resourceInfo.setPlatformNameCn(platform);
                resourceInfo.setApiPath(apiUrl);
                resourceInfo.setPerms(perms);
                resourceInfo.setApiName(apiName);
                resourceInfo.setRequestType(requestType);
                resourceInfo.setModuleNameCn(moduleName);

                //解析swagger-ui中的出参入参
                JSONArray parameterJson = (JSONArray) requestTypeInfo.get("parameters");
                Object requestParam = null;
                Map<String,Object> requestParamMap = new HashMap<>();
                if(parameterJson != null){
                    for(Object object : parameterJson){
                        JSONObject schema = (JSONObject) ((JSONObject) object).get("schema");
                        if (schema != null){
                            String ref = (String) schema.get("$ref");
                            requestParam = parseRequestToJson(null,paramMap,ref);
                        } else {
                            String mapKey = (String) ((JSONObject) object).get("name");
                            String type = ((JSONObject) object).getString("type");
                            Object value = setValueByType(type,null);
                            requestParamMap.put(mapKey,value);
                        }
                    }
                }

                if(requestParam != null){
                    resourceInfo.setRequestParam(JSONObject.toJSONString(requestParam));
                } else {
                    resourceInfo.setRequestParam(JSONObject.toJSONString(requestParamMap));
                }

                //返回值类型都用标准类型，不解析其他格式
                JSONObject response = (JSONObject) requestTypeInfo.get("responses");
                Object responseResult = null;
                if(response != null){
                    JSONObject schema = (JSONObject) ((JSONObject)response.get("200")).get("schema");
                    if(schema != null){
                        String ref = (String) schema.get("$ref");
                        responseResult = parseRequestToJson(null,paramMap,ref);
                    }
                }
                if(responseResult != null){
                    resourceInfo.setResponseParam(JSONObject.toJSONString(responseResult));
                }

                resourceInfos.add(resourceInfo);
            }
        }
        log.info("解析完成=====>{}",JSONObject.toJSONString(resourceInfos));
    } catch (IOException e) {
        log.error("加载Swagger文档中接口失败，url={}",url);
        return false;
    }
    return true;
}

/**
 * 解析swagger-ui中出参和入参为json
 * @param paramMap 入参和出参对象map,key-对象标识，value-对象属性及类型json
 * @param paramRef 入参和出参对应的对象信息， 格式: #/definitions/R«PageResultDTO«PublicResourceInfoDTO»»
 * @Date 2020/11/11 16:01
 * @Author fan
**/
private Object parseRequestToJson(Map<String,Integer> forEachCache,Map<String,JSONObject> paramMap, String paramRef){
    if(StringUtils.isBlank(paramRef)){
        return "";
    }

    //对象标识
    String paramKey = paramRef.substring(paramRef.lastIndexOf("/")+1);

    //控制递归次数，同一个对象循环超过1次就返回空
    if(forEachCache == null){
        forEachCache = new HashMap<>();
    }
    Integer forEachCount = forEachCache.get(paramKey);
    if(forEachCount != null && forEachCount >= 1){
        return null;
    } else {
        forEachCache.put(paramKey,1);
    }

    //对象值
    JSONObject paramJson = paramMap.get(paramKey);
    JSONObject propertiesJson = JSONObject.parseObject(String.valueOf(paramJson.get("properties")));

    Map<String,Object> columnMap = new HashMap<>();
    for(Map.Entry<String,Object> entry : propertiesJson.entrySet()){
        String key = entry.getKey();
        Object value = new JSONObject();
        JSONObject valueJson = JSONObject.parseObject(String.valueOf(entry.getValue()));
        String type = valueJson.getString("type");
        Object obj = valueJson.get("items");

        if(obj != null){
            JSONObject property = JSONObject.parseObject(String.valueOf(obj));
            String ref = (String) property.get("$ref");
            //有下一级，则递归
            if(StringUtils.isNotBlank(ref)){
                value = parseRequestToJson(forEachCache,paramMap,ref);
            }
        }
        value = setValueByType(type,value);
        columnMap.put(key,value);
    }

    return columnMap;
}

/**  根据参数类型设置value **/
private Object setValueByType(String type,Object value){
    if("array".equals(type)){
        JSONArray jsonArray = new JSONArray();
        if(value == null){
            value = new JSONObject();
        }
        jsonArray.add(value);
        return JSONArray.toJSONString(jsonArray);
    }
    if("integer".equals(type)){
        return 0;
    }
    if("boolean".equals(type)){
        return true;
    }
    if("object".equals(type)){
        return value;
    }
    return "";
}
```
