#!/bin/bash

#解析json数据
function get_json_value(){
  local json=$1
  local key=$2

  if [[ -z "$3" ]]; then
    local num=1
  else
    local num=$3
  fi

  local value=$(echo "${json}" | awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'${key}'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p)

  echo ${value}
}


server_back=$(curl -s https://api.myjson.com/bins/15u89e)
# server_back="{\"next_update_time\": \"2019-09-09\",\"new_password\": 762321}"
# 获取服务器的新密码
new_password=$(get_json_value $server_back new_password)
# 获取过期时间
# 获取过期时间
next_update_time=$(get_json_value $server_back next_update_time)
#通过查询nvram获取当前的登录密码.
now_password=$(nvram get wan_pppoe_passwd)
# 获取当前的时间戳
now_timestamp=$(date +%s)
# 获取闪讯的时间戳.
next_timestamp=$(date -d "$next_update_time" +%s)
# 判断当前时间是否已经超过闪讯的时间戳.由于闪讯超过时间也是可以上网的.所以这个时候还是可以联网的.
# 只要我们及时的修改密码就可以继续使用了
# 相差的时间
if [ $(expr $now_timestamp - $next_timestamp) -gt 0 ]
then 
  if [ $now_password == $new_password ]
  then 
  # 已经可以修改密码了.
  # 直接修改pppoe当中的密码值
  # nvram set wan0_pppoe_passwd=$new_password
  # nvram set wan_pppoe_passwd=$new_password
  # # 提交修改
  # nvram commit
  # # 重启wan口,自动连接
  # restart_wan
  echo "The password has been modified successfully"
  else
  echo "The password is the same does not need to be modified"
  fi
else
  echo "Expiration time hasn't arrived yet"
fi




