#!/bin/bash
path="/Users/fannian/Documents/my_code/"

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    id as user_id,
    mobile,
    from_unixtime(register_time/1000,'%Y-%m-%d') dt
from
    passport_user
where
    from_unixtime(register_time/1000,'%Y-%m-%d')>'2018-04-08'
$lim">${attach}
echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
