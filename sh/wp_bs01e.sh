#!/bin/bash
path="$private_home/my_code/"

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    from_unixtime(create_time/1000,'%Y-%m-%d') dt,
    item_id,
    mobile
from
    sale_reminder sr
    left join item_match_distributor imd
    using(online_id)
group by
    1,2,3
$lim">${attach}
echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
