#!/bin/bash
source ./fuc.sh
srs=`fun dp_myshow__s_stockoutregisterstatistic.sql`
srr=`fun dp_myshow__s_stockoutregisterrecord.sql`
so=`fun detail_myshow_saleorder.sql u`

file="yhyy01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sr_show_name,
    sr_ticket_price,
    value2 as pt,
    coalesce(show_name,'all') as show_name,
    coalesce(ticket_price,'all') as ticket_price,
    count(distinct sr.mobile) as sr_num,
    count(distinct so.mobile) as so_num,
    sum(totalprice) as totalprice,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num
from (
    select
        mobile,
        sellchannel,
        case when 2 in (\$dim) then show_name
        else 'all' end as sr_show_name,
        case when 2 in (\$dim) then ticket_price
        else 'all' end as sr_ticket_price
    from (
        $srs
            and performanceid in (\$performance_id)
        ) srs
        join (
            $srr
            and createtime>='\$str_date'
            and createtime<'\$end_date'
            and smssendstatus in (\$status)
            ) srr
        on srs.stockoutregisterstatisticid=srr.stockoutregisterstatisticid
    group by
        1,2,3,4
    ) as sr
    left join (
        $md
            and key_name='sellchannel'
        ) md
        on md.key=sr.sellchannel
    left join (
        select
            usermobileno as mobile,
            case when 4 in (\$dim) then show_name
            else 'all' end as show_name,
            case when 4 in (\$dim) then ticket_price
            else 'all' end as ticket_price,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(setnumber*salesplan_count) as ticket_num
        $so
            and performance_id in (\$performance_id)
        group by
            1,2,3
        ) so
        on so.mobile=sr.mobile
group by
    1,2,3,4,5
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


