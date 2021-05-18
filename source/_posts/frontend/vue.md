---
title: vue
description: vue
#top: 1
date: 2021-04-28 11:44:02
tags:
- vue
categories:
- 前端
- vue
---

### vue+es6接入Echarts
#### 1.安装
```shell
# echars
npm install echarts --save
```

#### 2.实现图表下钻及还原demo
```textmate
<template>
    <div style="display: inline-block" v-show="optionShow" >
        <div id="option" :style="{width: '800px', height: '600px'}"></div>
    </div>

    <div style="display: inline-block" v-show="optionSecondShow" >
        <div id="secondOption" :style="{width: '800px', height: '600px'}"></div>
    </div>
</template>

<script>
    import * as echarts from 'echarts';
    export default {
        name: 'dashboard',
        data() {
            return {
                optionShow: true,
                // echarts报表
                option: {},
                optionSecond: {},
            }
        },
        created(){
        },
        mounted(){
            //调用method中方法！！！
            let that = this;

            //渲染报表一
            let myChart = echarts.init(document.getElementById('option'))
            that.initEcharts();
            myChart.setOption(that.option);

            //报表二
            let myChartSecond = echarts.init(document.getElementById('secondOption'))
            //图表一下钻
            myChart.on('click', function (params) {
                console.log(params.name,params.value,params.seriesName);

                //重置值
                that.secondShowFun()
                myChartSecond.setOption(that.optionSecond)
            });

            //点击图表二还原数据
            myChartSecond.getZr().on('click', function (event) {
                if (!event.target) {
                    that.initEcharts();
                    myChart.setOption(that.option)
                }
            });

            //点击图表二下钻
            myChartSecond.on('click', function (params) {
                console.log(params.name,params.value,params.seriesName);

                //展示列表
                that.showTabFun()
            });

        },
        methods: {
            initEcharts(){
                this.optionShow = true;
                this.optionSecondShow = false;
                this.tableShow = false;
                this.option = {
                    tooltip: {
                        trigger: 'axis',
                        axisPointer: {            // Use axis to trigger tooltip
                            type: 'shadow'        // 'shadow' as default; can also be 'line' or 'shadow'
                        }
                    },
                    legend: {
                        data: ['项目一', '项目二', '项目三']
                    },
                    grid: {
                        left: '3%',
                        right: '4%',
                        bottom: '3%',
                        containLabel: true
                    },
                    xAxis: {
                        type: 'value'
                    },
                    yAxis: {
                        type: 'category',
                        data: ['user-center', 'user-auth', 'uaa-gateway', 'crm', 'ims', 'fms', 'cloud-gateway']
                    },
                    series: [
                        {
                            name: '项目一',
                            type: 'bar',
                            stack: 'total',
                            label: {
                                show: true,
                                valueAnimation: true
                            },
                            emphasis: {
                                focus: 'series'
                            },
                            data: [320, 302, 301, 334, 390, 330, 320]
                        },
                        {
                            name: '项目二',
                            type: 'bar',
                            stack: 'total',
                            label: {
                                show: true,
                                valueAnimation: true
                            },
                            emphasis: {
                                focus: 'series'
                            },
                            data: [120, 132, 101, 134, 90, 230, 210]
                        },
                        {
                            name: '项目三',
                            type: 'bar',
                            stack: 'total',
                            label: {
                                show: true,
                                valueAnimation: true
                            },
                            emphasis: {
                                focus: 'series'
                            },
                            data: [220, 182, 191, 234, 290, 330, 310]
                        }
                    ],
                };
            },
            secondShowFun(){
                this.optionShow = false;
                this.optionSecondShow = true;
                this.optionSecond = {
                    tooltip: {
                        trigger: 'axis',
                        axisPointer: {            // Use axis to trigger tooltip
                            type: 'shadow'        // 'shadow' as default; can also be 'line' or 'shadow'
                        }
                    },
                    legend: {
                        data: ['分类一','分类二','分类三']
                    },
                    grid: {
                        left: '3%',
                        right: '4%',
                        bottom: '3%',
                        containLabel: true
                    },
                    xAxis: {
                        type: 'value'
                    },
                    yAxis: {
                        type: 'category',
                        data: ['子项一', '子项二', '子项三']
                    },
                    series : [
                        {
                            name: '子项一',
                            type: 'bar',
                            stack: 'total',
                            label: {
                                show: true
                            },
                            emphasis: {
                                focus: 'series'
                            },
                            data: [10,2,3]
                        },
                        {
                            name: '子项二',
                            type: 'bar',
                            stack: 'total',
                            label: {
                                show: true
                            },
                            emphasis: {
                                focus: 'series'
                            },
                            data: [1,3,4]
                        },
                        {
                            name: '子项三',
                            type: 'bar',
                            stack: 'total',
                            label: {
                                show: true
                            },
                            emphasis: {
                                focus: 'series'
                            },
                            data: [2,5,6]
                        },
                    ],
                };
            },
        }
    }
</script>

<style lang="scss" scoped>
    .dashboard-editor-container {
        padding: 32px;
        background-color: rgb(240, 242, 245);
        position: relative;

    .chart-wrapper {
        background: #fff;
        padding: 16px 16px 0;
        margin-bottom: 32px;
    }
    }

    @media (max-width:1024px) {
        .chart-wrapper {
            padding: 8px;
        }
    }
</style>
```

