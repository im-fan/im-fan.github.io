---
title: Shell命令记录
date: 2022-03-08 11:13:00
tags:
- shell命令
categories:
- 运维
---

# 快捷打开软件
```shell
alias sublime='open -a "Sublime Text"'
```

### 获取本机IP
```shell
# 输出ip地址
alias ip="ifconfig | grep 'inet 192' | grep -Eo '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1"
```


### 判断使用的是那个shell
```shell
echo $0

# -zsh 表示使用的是zsh,对应配置文件 ~/.zshrc
# bash 标识使用的是bash,对应配置文件 ~/.bashrc
```

### 自定义alias
```shell
#在对应shell的配置文件中新增
alias key=value

#例如 alias gogogo="echo gogogo"
```

### 输入自定义的alias命令
```shell
#此命令放在自定义alias命令之前; 
# +117 行号 输入文件117行之后的内容
# 注意对应shell配置文件名名
alias my-alias="tail -n +117 ~/.zshrc"
```

## 一台电脑配置多个gitee/github公钥
### 相关命令
```shell
# 查看ssh-agent缓存
ssh-add -l

# 删除所有缓存
ssh-add -D

# 添加密钥缓存
ssh-add work_id_rsa

#将以上命令写入shell文件，然后自定义alias命令，使用的时候切换即可
alias gitee-work="sh work.sh"
```

## git获取已合并master的分支
```shell
#!/bin/bash
# 筛选出已合并过master的分支
# 指定分支名称
if [ "$1" == "" ]; then
  targetBranch="master";
fi


# 获取所有分支
branches=$(git branch -a | grep 'origin' | grep -v 'HEAD')

# 创建一个空数组用于存储结果
declare -a result

# 遍历每个分支
for branch in $branches; do

    if [ "$branch" == '' ]; then
      continue;
    fi

    # 获取当前分支的最后一次提交记录
    last_commit=$(git log -1 --pretty=format:"%H" $branch)

    # 判断指定分支是否包含该提交记录
    if git branch --contains $last_commit | grep -w 'master'; then
        result+=("$branch: 已合并到 $targetBranch")
    fi
done

# 输出结果
for res in "${result[@]}"; do
    echo $res
done

```
