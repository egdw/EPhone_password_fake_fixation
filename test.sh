#!/bin/bash
#解析json数据
function get_json_value()
{
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



# server_back=$(curl -s https://api.myjson.com/bins/15u89e)
server_back="{\"next_update_time\": \"2019-09-09\",\"new_password\": 762321}"
# 获取服务器的新密码
new_password=$(get_json_value $server_back new_password)
# 获取过期时间
next_update_time=$(get_json_value $server_back next_update_time)
echo $new_password
echo $next_update_time


#通过查询nvram当中的登录密码.

# 直接修改pppoe当中的密码值
nvram set wan0_pppoe_passwd=212812
nvram set wan_pppoe_passwd=212812
# 提交修改
nvram commit
# 重启wan口,自动连接
restart_wan