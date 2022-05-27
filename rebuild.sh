hexo clean
hexo generate
echo "编译完成====》》》"

git add docs
git add db.json
git commit -m 'rebuild'
sleep 2
git push
echo "提交完成====》》》"

echo "正在打开GitHub Pages 》》》"
open https://github.com/im-fan/im-fan.github.io/actions
