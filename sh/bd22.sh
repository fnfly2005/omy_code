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

file="bd22"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    partner_name,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) ticket_num
from (
    select
        substr(pay_time,1,10) as dt,
        partner_name,
        so.order_id,
        setnumber*salesplan_count as ticket_num,
        totalprice
    from (
        $so
        and performance_id in (\$performance_id)
        and sellchannel=11
        ) so
        left join (
        $opa
        ) opa
        on so.order_id=opa.order_id
        left join (
        $par
        ) par
        on opa.partner_id=par.partner_id
    ) as s1
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"

