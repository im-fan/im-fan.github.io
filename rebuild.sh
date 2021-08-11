hexo clean
hexo generate
echo "编译完成====》》》"

git add public
git add db.json
git commit -m 'rebuild'
git push
echo "提交完成====》》》"

echo "正在打开Gitee Pages 》》》"
open https://gitee.com/im-fan/im-fan/pages
