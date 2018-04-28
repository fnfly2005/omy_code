#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == ex ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

so=`fun detail_myshow_saleorder.sql u`
per=`fun dim_myshow_performance.sql`
md=`fun myshow_dictionary.sql`
cus=`fun dim_myshow_customer.sql`

file="bs27"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sendtag,
    batch_code,
    count(distinct sed.mobile) send_num,
    sum(case when valid_flag=1 then totalprice end) totalprice,
    sum(case when valid_flag=1 then order_num end) order_num,
    sum(case when valid_flag=0 then totalprice end) un_totalprice,
    sum(case when valid_flag=0 then order_num end) un_order_num
from (
    select distinct 
        mobile,
        sendtag,
        batch_code
    from (
        select
            mobile,
            sendtag,
            batch_code
        from upload_table.send_fn_user
        where
            sendtag in ('\$sendtag') 
        union all
        select
            mobile, 
            sendtag,
            batch_code
        from upload_table.send_wdh_user
        where
            sendtag in ('\$sendtag') 
        ) sen
    ) sed
    left join (
    select
        usermobileno as mobile,
        case when performance_id in (\$send_performance_id) 
            then 1
        else 0 end as valid_flag,
        sum(totalprice) totalprice,
        count(distinct order_id) order_num
    $so
    group by
        1,2
    ) so
    on so.mobile=sed.mobile
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
