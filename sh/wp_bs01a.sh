#!/bin/bash
path="/Users/fannian/Documents/my_code/"

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    from_unixtime(create_time/1000,'%Y-%m-%d') dt,
    item_id,
    order_id,
    order_src,
    user_id,
    order_mobile as mobile,
    receive_mobile,
    pay_no,
    (total_money/100) as total_money
from
    report_sales_flow
where
    from_unixtime(create_time/1000,'%Y-%m-%d')>'2018-03-30'
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
