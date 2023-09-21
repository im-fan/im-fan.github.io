---
title: Stable Diffusion Web UI(二)-资源
date: 2023-09-06
tags:
- AIGC,SD,StableDiffusion
categories:
- AI
---

## 搭建指南 & 使用教程
- [吴东子-使用教程(转)](https://mp.weixin.qq.com/s/eFi-xoVDQomzCBr5kO9nHA)
- [幻术AI](https://mp.weixin.qq.com/s?__biz=MzA3MjgyNTc4OQ==&mid=2247488963&idx=1&sn=e0e895739c4a1d8bfa12c6e6f7dbbf96&chksm=9f193b11a86eb2070f9c192c55862f70b1983bcb02320c1f77c789849cc6dbbffeaf5b8ecc72&scene=132&exptype=timeline_recommend_article_extendread_samebiz#wechat_redirect)

## Prompt词学习

### prompt词库
- [元素魔法典-01](https://docs.qq.com/doc/DWFdSTHJtQWRzYk9k)
- [元素魔法典-02](https://docs.qq.com/doc/DWHl3am5Zb05QbGVs?dver=)
- [各种角色魔法典](https://danbooru.donmai.us/wiki_pages/tag_groups)
- [Tag网站](https://thereisnospon.github.io/NovelAiTag/)

### 通用词示例
- 反向词
```textmate
(worst quality:2), (low quality:2), (normal quality:2), lowres, ((monochrome)), ((grayscale)), bad anatomy,DeepNegative, skin spots, acnes, skin blemishes,(fat:1.2),facing away, looking away,tilted head, lowres,bad anatomy,bad hands, missing fingers,extra digit, fewer digits,bad feet,poorly drawn hands,poorly drawn face,mutation,deformed,extra fingers,extra limbs,extra arms,extra legs,malformed limbs,fused fingers,too many fingers,long neck,cross-eyed,mutated hands,polar lowres,bad body,bad proportions,gross proportions,missing arms,missing legs,extra digit, extra arms, extra leg, extra foot,teethcroppe,signature, watermark, username,blurry,cropped,jpeg artifacts,text,error
```

## 模型

### 模型网站
> 模型名称需要改成英文
- [huggingface](https://huggingface.co/)
- [civitai](https://civitai.com/)
- [LiblibAI](www.liblibai.com)  号称国内最大，大多来自于civitai
- [炼丹阁](www.liandange.com)  国内，大多来自于civitai


### 基础模型推荐

| 模型名称             | 简介   | 来源                           | 下载地址                                                     |
| -------------------- |------| ------------------------------ | ------------------------------------------------------------ |
| majicmix-realistic   | 真人模型 | hugginface                     | [majicMIX_realistic_v6](https://huggingface.co/emilianJR/majicMIX_realistic_v6) |
| Stable Diffusion 2.0 |      | 768-v-ema.ckpt与768-v-ema.yaml | [sd2.0](https://huggingface.co/stabilityai/stable-diffusion-2/resolve/main/768-v-ema.ckpt)[sd2.0-yml](https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-inference.yaml) |
| Stable Diffusion 2.1 |      |                                | [SD2.1](https://huggingface.co/stabilityai/stable-diffusion-2-1) |

### ControlNet模型
- [下载地址](https://huggingface.co/lllyasviel/ControlNet-v1-1/tree/main)
> 只用下载pth结尾的文件，下载后放在 "stable-diffusion-webui\extensions\sd-webui-controlnet\models" 文件夹中

- 模型介绍

| 模型名称                          | 模型描述                                             | 模型和配置文件                                               |
| --------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| control_v11p_sd15_canny           | 使用 Canny 边缘检测算法的模型                        | control_v11p_sd15_canny.pth / control_v11p_sd15_canny.yaml   |
| control_v11p_sd15_mlsd            | 使用最小长度分割线检测算法 (MLSD) 的模型             | control_v11p_sd15_mlsd.pth / control_v11p_sd15_mlsd.yaml     |
| control_v11f1p_sd15_depth         | 生成深度信息的模型                                   | control_v11f1p_sd15_depth.pth / control_v11f1p_sd15_depth.yaml |
| control_v11p_sd15_normalbae       | 应用法线估计和自编码器 (BAE) 的模型                  | control_v11p_sd15_normalbae.pth / control_v11p_sd15_normalbae.yaml |
| control_v11p_sd15_seg             | 用于图像分割的模型                                   | control_v11p_sd15_seg.pth / control_v11p_sd15_seg.yaml       |
| control_v11p_sd15_inpaint         | 用于图像修复的模型                                   | control_v11p_sd15_inpaint.pth / control_v11p_sd15_inpaint.yaml |
| control_v11p_sd15_lineart         | 用于线稿生成的模型                                   | control_v11p_sd15_lineart.pth / control_v11p_sd15_lineart.yaml |
| control_v11p_sd15s2_lineart_anime | 用于动漫线稿生成的模型                               | control_v11p_sd15s2_lineart_anime.pth / control_v11p_sd15s2_lineart_anime.yaml |
| control_v11p_sd15_openpose        | 用于人体姿势估计的模型                               | control_v11p_sd15_openpose.pth / control_v11p_sd15_openpose.yaml |
| control_v11p_sd15_scribble        | 用于涂鸦生成的模型                                   | control_v11p_sd15_scribble.pth / control_v11p_sd15_scribble.yaml |
| control_v11p_sd15_softedge        | 用于软边缘生成的模型                                 | control_v11p_sd15_softedge.pth / control_v11p_sd15_softedge.yaml |
| control_v11e_sd15_shuffle         | 使用深度估计和卷积神经网络的模型进行图像重排         | control_v11e_sd15_shuffle.pth / control_v11e_sd15_shuffle.yaml |
| control_v11e_sd15_ip2p            | 使用图像修复和卷积神经网络的模型进行图像到图像的转换 | control_v11e_sd15_ip2p.pth / control_v11e_sd15_ip2p.yaml     |
| control_v11f1e_sd15_tile          | 使用深度估计和图像瓦片生成的模型                     | control_v11f1e_sd15_tile.pth / control_v11f1e_sd15_tile.yaml |

## SDWebUI插件

- [默认插件加载地址](https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui-extensions/master/index.json)

- [gitcode地址](https://gitcode.net/rubble7343/sd-webui-extensions/raw/master/index.json)

| 名称                                      | 简介                   | 下载地址                                                                                                                                                                                                                          |
| ----------------------------------------- | ---------------------- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| sd-webui-bilingual-localization           | 双语翻译               | https://github.com/journey-ad/sd-webui-bilingual-localization                                                                                                                                                                 |
| stable-diffusion-webui-localization-zh_CN | 汉化包，搭配上面的使用 | https://github.com/dtlnor/stable-diffusion-webui-localization-zh_CN                                                                                                                                                           |
| sd-webui-controlnet                       | 模型细节控制           | https://github.com/Mikubill/sd-webui-controlnet.git                                                                                                                                                                           |
| sd-webui-infinite-image-browsing          | 图片管理器             |                                                                                                                                                                                                                               |
| WD 1.4 Tagger                             | 图片描述信息拆解       |                                                                                                                                                                                                                               |
| segment anything                          | 抠图插件               |                                                                                                                                                                                                                               |
| vae                                       | 解码器/滤镜，非必须    | [VAE介绍](https://zhuanlan.zhihu.com/p/646853233)                                                                                                                                                                               |
| tagcomplete                               | tag提示                | https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git[设置提示词翻译](https://xie.infoq.cn/article/ef345282c4de3ec742952b344)[中文Tag地址](https://github.com/DominikDoom/a1111-sd-webui-tagcomplete/files/9834821/danbooru.csv) |
| LightDiffusionFlow                        | SD工作流               | [Lightdiffusionflow-Gitee](https://gitee.com/mirrors/lightdiffusionflow) |


## 其他相关链接
- [SD-online](https://stablediffusionweb.com/)
- [无限创意-fusionbrain](https://editor.fusionbrain.ai/)
- [图片修复](https://github.com/upscayl/upscayl)
- [文生图-免费](http://www.liuyuxiang.com:9999/chatIMG.html)
