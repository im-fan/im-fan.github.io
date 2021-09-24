---
title: EasyExcel使用遇到的问题
description: excel
date: 2020-10-20 17:22:53
tags:
- utils
categories:
- 后端
- 工具
---

### 导出设置标题格式
- TitleHandler
```java
public class TitleHandler implements CellWriteHandler{

    //操作列
    private List<Integer> columnIndexs;
    //颜色
    private Short colorIndex;

    public TitleHandler(List<Integer> columnIndexs, Short colorIndex) {
        this.columnIndexs = columnIndexs;
        this.colorIndex = colorIndex;
    }

    @Override
    public void beforeCellCreate(WriteSheetHolder writeSheetHolder, WriteTableHolder writeTableHolder, Row row, Head head, Integer columnIndex, Integer relativeRowIndex, Boolean isHead) {

    }

    @Override
    public void afterCellCreate(WriteSheetHolder writeSheetHolder, WriteTableHolder writeTableHolder, Cell cell, Head head, Integer relativeRowIndex, Boolean isHead) {

    }

    @Override
    public void afterCellDataConverted(WriteSheetHolder writeSheetHolder, WriteTableHolder writeTableHolder, CellData cellData, Cell cell, Head head, Integer relativeRowIndex, Boolean isHead) {

    }

    @Override
    public void afterCellDispose(WriteSheetHolder writeSheetHolder, WriteTableHolder writeTableHolder, List<CellData> cellDataList, Cell cell, Head head, Integer relativeRowIndex, Boolean isHead) {
        if(isHead){
            // 设置列宽
            Sheet sheet = writeSheetHolder.getSheet();
            sheet.setColumnWidth(cell.getColumnIndex(), 20 * 256);
            writeSheetHolder.getSheet().getRow(0).setHeight((short)(3*256));
            Workbook workbook = writeSheetHolder.getSheet().getWorkbook();

            // 设置标题字体样式
            WriteCellStyle headWriteCellStyle = new WriteCellStyle();
            WriteFont headWriteFont = new WriteFont();
            headWriteFont.setFontName("宋体");
            headWriteFont.setFontHeightInPoints((short)14);
            headWriteFont.setBold(true);
            if (CollectionUtils.isNotEmpty(columnIndexs) &&
                    colorIndex != null &&
                    columnIndexs.contains(cell.getColumnIndex())) {
                // 设置字体颜色
                headWriteFont.setColor(colorIndex);
            }
            headWriteCellStyle.setWriteFont(headWriteFont);
            headWriteCellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            CellStyle cellStyle = StyleUtil.buildHeadCellStyle(workbook, headWriteCellStyle);
            cell.setCellStyle(cellStyle);
        }
    }
}
```

- ExcelUtils
```java
public class ExcelUtils {
    /** 导出Excel **/
    public static void exportExcel(String fileName, String sheetName,Class clazz,
                                   List data, HttpServletResponse response,
                                   CellWriteHandler... cellWriteHandlers) throws IOException {
        response.setContentType("application/vnd.ms-excel");
        response.setCharacterEncoding("utf-8");
        fileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

        // 列标题的策略
        WriteCellStyle headWriteCellStyle = new WriteCellStyle();
        // 单元格策略
        WriteCellStyle contentWriteCellStyle = new WriteCellStyle();
        // 初始化表格样式
        HorizontalCellStyleStrategy horizontalCellStyleStrategy = new HorizontalCellStyleStrategy(headWriteCellStyle, contentWriteCellStyle);

        ExcelWriterSheetBuilder excelWriterSheetBuilder = EasyExcel.write(response.getOutputStream(), clazz)
                .sheet(sheetName)
                .registerWriteHandler(horizontalCellStyleStrategy);

        if (null != cellWriteHandlers && cellWriteHandlers.length > 0) {
            for (int i = 0; i < cellWriteHandlers.length; i++) {
                excelWriterSheetBuilder.registerWriteHandler(cellWriteHandlers[i]);
            }
        }
        // 开始导出
        excelWriterSheetBuilder.doWrite(data);
    }
}
```
- 使用
```java
/** 导出excel模板**/
public void exportTemplate(List<Integer> ids,HttpServletResponse response){
    try {
        List<XXX> result = getByIds(ids);

        // 指定标红色的列
        List<Integer> columns = Arrays.asList(0,1,2,3);

        TitleHandler titleHandler = new TitleHandler(columns, IndexedColors.RED.index);
        ExcelUtils.exportExcel("文件名","sheet名称",
                XXX.class,result,response,titleHandler);
    } catch (IOException e) {
        log.warn("导出失败,error={}",e);
    }
}
```

### 设置中文文件名

```java
// 代码中添加
response.setContentType("application/vnd.ms-excel;charset=UTF-8");
response.setCharacterEncoding("utf-8");
response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
```

### 导出失败返回错误信息
```java
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

### 常见错误
#### 导出成功但是后台日志报类型转换异常
```textmate
错误日志
    No converter for [class com.hzrys.dashboard.common.result.R] with preset Content-Type 'application/vnd.ms-excel;charset=utf-8'
    org.springframework.http.converter.HttpMessageNotWritableException: No converter for [class com.hzrys.dashboard.common.result.R] with preset Content-Type 'application/vnd.ms-excel;charset=utf-8'
原因
    导出方法不能有返回值，导出文件时会设置相应头为文件格式；如果有返回值，则就会出现数据转换异常的错误
解决方法
    修改Controller中方法，改为 void 即可
```

#### poi流转对象问题(用easy-poi时遇到的问题)
```textmate
错误日志
    Your stream was neither an OLE2 stream, nor an OOXML stream.
原因
    多次操作流导致文件类型异常
解决方法
    读取远程流后，直接用当前流转换成对象
例:
    //读取远程文件工具类
    public static InputStream readUrlExcelFile(String urlPath) {
        try{
            URL url = new URL(urlPath);
            URLConnection conn = url.openConnection();
            int size = conn.getContentLength();
            if(size < 0){
                return null;
            }
            return conn.getInputStream();

        } catch (IOException e){
            e.printStackTrace();
        }
        return null;
    }
    
    //具体业务逻辑 流转对象用的是easy-poi
    public static XXService{
        public void saveExcel(String url){
            InputStream inputStream;
            try{
                inputStream = FileUtils.readUrlExcelFile(request.getFilePath());
                if(inputStream == null){
                    System.out.println("文件读取失败");
                    return;
                }
    
                ImportParams importParams = new ImportParams();
                //标识开始行
                importParams.setStartRows(0);
                List<XXX> list = ExcelImportUtil.importExcel(inputStream,
                        XXX.class,
                        importParams);
                        
            } catch(Exception e){
                e.printStackTrace();
            } finally{
                if(inputStream != null){
                    inputStream.close();
                }
            }
        }
    }
```
