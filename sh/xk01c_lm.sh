#!/bin/bash
path=""
fun() {
    tmp=`cat ${path}sql/${1} | grep -iv "/\*"`
    if [ -n $2 ];then
        if [[ $2 =~ d ]];then
            tmp=`echo $tmp | sed 's/where.*//'`
        fi
        if [[ $2 =~ u ]];then
            tmp=`echo $tmp | sed 's/.*from/from/'`
        fi
        if [[ $2 =~ t ]];then
            tmp=`echo $tmp | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
        fi
        if [[ $2 =~ m ]];then
            tmp=`echo $tmp | sed "s/begindate/monthfirst{-1m}/g;s/enddate/monthfirst/g"`
        fi
    fi
    echo $tmp
}

spo=`fun detail_myshow_salepayorder.sql m`
ss=`fun detail_myshow_salesplan.sql m`
cus=`fun dim_myshow_customer.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(ss1.dt,1,7) as mt,
    ss1.customer_type_name,
    ss1.customer_lvl1_name,
    avg(ss1.ap_num) as ap_num,
    avg(ss1.as_num) as as_num,
    avg(ss1.asp_num) as asp_num,
    avg(sp1.sp_num) as sp_num,
    sum(sp1.order_num) as order_num,
    sum(sp1.ticket_num) as ticket_num,
    sum(sp1.totalprice) as totalprice,
    sum(sp1.grossprofit) as grossprofit
from (
    select 
        dt,
        coalesce(customer_type_name,'全部') as customer_type_name,
        coalesce(customer_lvl1_name,'全部') as customer_lvl1_name,
        ap_num,
        as_num,
        asp_num
    from (
        select
            ss.dt,
            cus.customer_type_name,
            cus.customer_lvl1_name,
            count(distinct ss.performance_id) as ap_num,
            count(distinct ss.shop_id) as asp_num,
            count(distinct ss.salesplan_id) as as_num
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
                count(distinct spo.order_id) as order_num,
                sum(spo.salesplan_count*spo.setnumber) as ticket_num,
                sum(spo.totalprice) as totalprice,
                sum(spo.grossprofit) as grossprofit
            from (
                $spo
                    and sellchannel not in (9,10,11)
                ) spo
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
group by
    substr(ss1.dt,1,7),
    ss1.customer_type_name,
    ss1.customer_lvl1_name
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
