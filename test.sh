#!/bin/bash
# 判断当前时间是否已经超过闪讯的时间戳.
# 由于闪讯超过时间也是可以暂时上网的.
# 我们利用这个时候获取新的密码然后更新上去.
# 就可以一直上网了.所以叫做伪固定.
#parse json data
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

# https://api.myjson.com/bins/ss0si
server_back=$(curl -s https://api.myjson.com/bins/15u89e)
# server_back="{\"next_update_time\": \"2019-09-09\",\"new_password\": 762321}"
# get myjson.com password
new_password=$(get_json_value $server_back new_password)
# get expiration time
next_update_time=$(get_json_value $server_back next_update_time)
#query nvram get now password.
now_password=$(nvram get wan_pppoe_passwd)
# get current timestamp
now_timestamp=$(date +%s)
# get ephone new timestamp
next_timestamp=$(date -d "$next_update_time" +%s)
# 相差的时间
if [ $(expr $now_timestamp - $next_timestamp) -gt 0 ]
then 
  # password equals
  if [ $now_password != $new_password ]
  then 
  # can update password
  # Modify the password value of pppoe directly
  nvram set wan0_pppoe_passwd=$new_password
  nvram set wan_pppoe_passwd=$new_password
  # commit nvram
  nvram commit
  # restart wan auto_connect
  restart_wan
  echo "The password has been modified successfully"
  else
  echo "The password is the same does not need to be modified"
  fi
else
  echo "Expiration time hasn't arrived yet"
fi




