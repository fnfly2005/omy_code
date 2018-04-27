#!/bin/bash
path="/Users/fannian/Documents/my_code/"
file="wp_bs02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mobile,
    max(substr(create_time,1,10)) as dt
from
    passport_user
where
    mobile is not null
    and length(mobile)=11
    and substr(mobile,1,2)>='13'
    and substr(create_time,1,10)>
group by
    1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
