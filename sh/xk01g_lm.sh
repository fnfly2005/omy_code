#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
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

so=`fun detail_myshow_saleorder.sql d`
opa=`fun dp_myshow__s_orderpartner.sql`
par=`fun dp_myshow__s_partner.sql`
md=`fun myshow_dictionary.sql`
ogi=`fun dp_myshow__s_ordergift.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mt,
    sell_type,
    sell_lv1_type,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) ticket_num
from (
    select
        substr(pay_time,1,7) as mt,
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
        where
            pay_time is not null
            and pay_time>='\$\$monthfirst{-1m}'
            and pay_time<'\$\$monthfirst'
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

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
