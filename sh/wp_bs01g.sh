#!/bin/bash
path="/Users/fannian/Documents/my_code/"

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
   dt,
   item_id,
   user_id
from (
    select
        from_unixtime(create_time,'%Y-%m-%d') dt,
        item_id,
        user_id
    from
        item_attentions
    union all
    select
        from_unixtime(create_time,'%Y-%m-%d') dt,
        item_id,
        user_id
    from
        item_attention
    ) as iat
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
