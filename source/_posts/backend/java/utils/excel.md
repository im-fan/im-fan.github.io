---
title: EasyExcel使用遇到的问题
description: excel
date: 2020-10-20 17:22:53
tags:
- utils
categories:
- 后端
- Java
---

### 设置中文文件名
```text
// 代码中添加
response.setContentType("application/vnd.ms-excel;charset=UTF-8");
response.setCharacterEncoding("utf-8");
response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

```

### 导出失败返回错误信息
```text
// 重写响应信息数据类型
response.reset();
response.setContentType("application/json");
response.setCharacterEncoding("utf-8");
try {
    response.getWriter().println(result);
} catch (IOException ioException) {
    log.warn("业务异常  msg={}",ioException);
}
```

### 导出成功但是后台日志报类型转换异常
- 错误日志
```text
-No converter for [class com.hzrys.dashboard.common.result.R] with preset Content-Type 'application/vnd.ms-excel;charset=utf-8'
org.springframework.http.converter.HttpMessageNotWritableException: No converter for [class com.hzrys.dashboard.common.result.R] with preset Content-Type 'application/vnd.ms-excel;charset=utf-8'
```
- 原因
```text
导出方法不能有返回值，导出文件时会设置相应头为文件格式；如果有返回值，则就会出现数据转换异常的错误
```
- 解决方法
```text
修改Controller中方法，改为 void 即可
```
