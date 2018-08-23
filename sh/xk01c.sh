#!/bin/bash
source ./fuc.sh
spo=`fun detail_myshow_salepayorder.sql ut`
ss=`fun detail_myshow_salesplan.sql t`
cus=`fun dim_myshow_customer.sql`
md=`fun myshow_dictionary.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ss1.dt,
    ss1.customer_type_name,
    ss1.customer_lvl1_name,
    ss1.ap_num,
    sp1.sp_num,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit
from (
    select 
        dt,
        coalesce(customer_type_name,'全部') as customer_type_name,
        coalesce(customer_lvl1_name,'全部') as customer_lvl1_name,
        ap_num
    from (
        select
            ss.dt,
            cus.customer_type_name,
            cus.customer_lvl1_name,
            count(distinct ss.performance_id) as ap_num
        from (
            $ss
            and salesplan_sellout_flag=0
            ) ss
            left join (
            $cus
            ) cus
            on ss.customer_id=cus.customer_id
        group by
            ss.dt,
            cus.customer_type_name,
            cus.customer_lvl1_name
        grouping sets(
        (ss.dt,cus.customer_type_name),
        (ss.dt,cus.customer_type_name,cus.customer_lvl1_name)
        )
        ) as ss0
    ) as ss1
    left join (
        select
            dt,
            coalesce(customer_type_name,'全部') as customer_type_name,
            coalesce(customer_lvl1_name,'全部') as customer_lvl1_name,
            sp_num,
            order_num,
            ticket_num,
            totalprice,
            grossprofit
        from (
            select
                spo.dt,
                cus.customer_type_name,
                cus.customer_lvl1_name,
                count(distinct spo.performance_id) as sp_num,
                sum(order_num) as order_num,
                sum(ticket_num) as ticket_num,
                sum(totalprice) as totalprice,
                sum(grossprofit) as grossprofit
            from (
                select
                    partition_date as dt,
                    sellchannel,
                    customer_id,
                    performance_id,
                    count(distinct order_id) as order_num,
                    sum(salesplan_count*setnumber) as ticket_num,
                    sum(totalprice) as totalprice,
                    sum(grossprofit) as grossprofit
                $spo
                group by
                    partition_date,
                    sellchannel,
                    customer_id,
                    performance_id
                ) spo
                join (
                    $md
                    and key_name='sellchannel'
                    and key1<>'0'
                    ) as md
                on spo.sellchannel=md.key
                left join (
                $cus
                ) cus
                on spo.customer_id=cus.customer_id
            group by
                spo.dt,
                cus.customer_type_name,
                cus.customer_lvl1_name
            grouping sets(
            (spo.dt,cus.customer_type_name),
            (spo.dt,cus.customer_type_name,cus.customer_lvl1_name)
            )
            ) as sp0
        ) as sp1
    on sp1.dt=ss1.dt
    and sp1.customer_type_name=ss1.customer_type_name
    and sp1.customer_lvl1_name=ss1.customer_lvl1_name
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
