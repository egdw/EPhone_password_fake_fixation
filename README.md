# EPhone_password_fake_-fixation

## 闪讯密码伪固定,路由器shell脚本.

# 通过请求[myjson.com](https://www.myjson.com) 网站提供的临时json数据存放.
```
server_back=$(curl -s https://api.myjson.com/bins/XXXX)
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
if [ $(expr $now_timestamp - $next_timestamp) -lt 0 ]
then
	if [ "$now_password" == "$new_password" ]
	then
        echo "The password is the same does not need to be modified"
	else
		# can update password
		# Modify the password value of pppoe directly
		nvram set wan0_pppoe_passwd=$new_password
		nvram set wan_pppoe_passwd=$new_password
		# commit nvram
		nvram commit
		# restart wan auto_connect
		restart_wan
		echo "The password has been modified successfully"
        restart_wan
	fi
else
	echo "Expiration time hasn't arrived yet"
fi

```


# AutoReboot-GetPassword-App闪讯密码助理
自动获取闪讯密码的手机app 自动分析过期时间 自动修改路由器闪讯密码
[app地址](https://github.com/egdw/AutoReboot-GetPassword-App)
## 链接生成地址
1. [链接生成](http://myjson.com/)
2. 复制下面的数据到输入框中.
```
{"new_password":"000000","next_update_time":"2018-12-10 22:27:22"}
```
3. 获取生成的链接

## 配合Pandavan进行联动.
通过自己写的下面的脚本,可以直接在过期时间之后自动更换Pandavan中的闪讯密码.达到闪讯密码的伪固定功能.

>server_back=$(curl -s http://api.myjson.com/bins/XXXXX) 只需要修改这里的请求地址即可

```shell
#!/bin/bash
server_back=$(curl -s http://api.myjson.com/bins/XXXXX)
new_password=${server_back:17:6}
next_update_time=${server_back:45:19}
echo $new_password
echo $next_update_time
now_password=$(nvram get wan_pppoe_passwd)
now_timestamp=$(date +%s)
next_timestamp=$(date -d "$next_update_time" +%s)
# 相差的时间
if [ $(expr $now_timestamp - $next_timestamp) -lt 0 ]
then
	if [ "$now_password" == "$new_password" ]
	then
        echo "The password is the same does not need to be modified"
	else
		# can update password
		# Modify the password value of pppoe directly
		nvram set wan0_pppoe_passwd=$new_password
		nvram set wan_pppoe_passwd=$new_password
		# commit nvram
		nvram commit
		# restart wan auto_connect
		restart_wan
		echo "The password has been modified successfully"
        restart_wan
	fi
else
	echo "Expiration time hasn't arrived yet"
fi
```
设置好相应的sh脚本权限.然后在pandavan中的 高级设置->系统管理->服务->其他服务->计划任务
相当于每30分钟执行一次脚本
```
*/30 * * * * /脚本地址/脚本名字.sh
```
## app设置
在app中也需要设置好请求地址才可以相互联动.

## 注意
1. 需要通过ssh连接到路由器
2. 脚本权限记得加 chmod +x 脚本.sh
3. 记得设置好crontab计划任务.不然不能定时执行了.
4. app加入白名单.并给予发送短信和接收通知短信的权限.(安全中心中.)
