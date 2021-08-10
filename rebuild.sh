hexo clean
hexo generate
echo "编译完成====》》》"

git add public
git commit -m 'rebuild'
git push
echo "提交完成====》》》"
