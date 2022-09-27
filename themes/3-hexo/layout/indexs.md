# Imfan
---
> 思考、记录、回顾

 
## 个人博客首页

<!--今日诗词-->
<script src="https://sdk.jinrishici.com/v2/browser/jinrishici.js" charset="utf-8"></script>
<h3>今日诗词</h3>
<div id="today-poem">正在加载今日诗词....</div>
<div>来源: <a href="https://www.jinrishici.com">今日诗词</a></div>
<script type="text/javascript">
  jinrishici.load(function(result) {
    var goodWords = result.data.content;
    var content = result.data.origin;
    var htmlTxt = '<div>'+content.title+'</div>'+
                  '<div>--'+content.author+'</div>';
    for(var i=0; i<content.content.length; i++){
        var words = content.content[i];
        if(words.includes(goodWords)){
            var wordSplit = words.split(goodWords);
            htmlTxt = htmlTxt + '<div>「'+wordSplit[0]+'<font class="goodWords_class">'+goodWords+'</font>'+wordSplit[1]+'」</div>';
        } else {
            htmlTxt = htmlTxt + '<div>'+words+'</div>';
        }
    }
    document.getElementById("today-poem").innerHTML = htmlTxt;
  });
</script>


### 关于
本博客通过 [Hexo](https://hexo.io/) 生成，部署在 [Gitee Pages](https://gitee.com/help/articles/4136#article-header0)<p>
引用主题 [3-hexo](https://yelog.org/2017/03/23/3-hexo-instruction/)


总文章:<code class="article_number"></code>篇，所有文章总字数：<code class="site_word_count"></code>字<p>
历史访问人数：<code class="site_uv"></code>人，历史访问量：<code class="site_pv"></code>次