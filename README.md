# EPhone_password_fake_-fixation

## 闪讯密码伪固定,路由器shell脚本.

# 通过请求[myjson.com](https://www.myjson.com) 网站提供的临时json数据存放.
```
server_back=$(curl -s https://api.myjson.com/bins/15u89e)
```
# 解析返回的json数据
```shell
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

new_password=$(get_json_value $server_back new_password)
# get expiration time
next_update_time=$(get_json_value $server_back next_update_time)
```

# 从路由器的nvram当中获取当前的路由器信息和时间戳
```shell
#query nvram get now password.
now_password=$(nvram get wan_pppoe_passwd)
# get current timestamp
now_timestamp=$(date +%s)
# get ephone new timestamp
next_timestamp=$(date -d "$next_update_time" +%s)
```

# 判断时间是否已经过期,并且密码已经不同
```shell
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

```