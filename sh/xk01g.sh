#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
opa=`fun dp_myshow__s_orderpartner.sql`
par=`fun dp_myshow__s_partner.sql`
md=`fun myshow_dictionary.sql`
ogi=`fun dp_myshow__s_ordergift.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    sell_type,
    sell_lv1_type,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) ticket_num
from (
    select
        substr(pay_time,1,10) as dt,
        value2 as sell_type,
        case when partner_name is null 
            then value1
        else partner_name end as sell_lv1_type,
        case when ogi.order_id is null then 0
        else 1 end as gift_flag,
        so.order_id,
        setnumber*salesplan_count as ticket_num,
        totalprice
    from (
        $so
        and sellchannel in (9,10,11)
        ) so
        left join (
        $opa
        ) opa
        on so.order_id=opa.order_id
        and so.sellchannel=11
        left join (
        $par
        ) par
        on opa.partner_id=par.partner_id
        left join (
        $ogi
        ) ogi
        on so.order_id=ogi.order_id
        and so.sellchannel in (9,10)
        left join (
        $md
        and key_name='sellchannel'
        ) md
        on md.key=so.sellchannel
    ) as s1
where
    gift_flag=0
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"

