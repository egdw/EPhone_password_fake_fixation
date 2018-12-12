#!/bin/bash
server_back=$(curl -s "$1")
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