#!/bin/bash
# 脚本教程 https://www.runoob.com/linux/linux-shell.html

# 重新编译并提交代码
rebuild() {
    hexo clean
    hexo generate
    echo "编译完成====》》》"
    sleep 2
    #自定义切换git认证命令
    github-my
    git add db.json
    git commit -a -m 'rebuild'
    sleep 2
    git push -u origin "master"
    echo "提交完成====》》》"

    #echo "正在打开Gitee Pages 》》》"
    #open https://gitee.com/im-fan/im-fan/pages
}

#channel=$1

# 切换源

#if [[ $channel = '' ]]
#then
#  echo '输入 gitee or github'
#  exit;
#elif [[ $channel = 'gitee' ]]; then
#    git remote rm origin
#    git remote add origin 'git@gitee.com:im-fan/im-fan.git'
#    rebuild;
#elif [[ $1 = 'github' ]]; then
#    git remote rm origin
#    git remote add origin 'git@github.com:im-fan/im-fan.github.io.git'
#    rebuild;
#fi
rebuild;
