#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

file="bi04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select dso.order_id,
    dso.sellchannel,
    dso.clientplatform,
    dso.dianping_userid,
    dso.meituan_userid,
    dso.city_id,
    dso.salesplan_id,
    dso.supply_price,
    dso.sell_price,
    dso.salesplan_count,
    dso.totalprice,
    dso.maoyan_order_id,
    dso.customer_id,
    dso.tporderid,
    dso.order_create_time,
    dso.lockedtime,
    dso.payexpiretime,
    dso.pay_time,
    dso.wxopenid,
    dso.needrealname,
    dso.needseat,
    dso.totalticketprice,
    dso.ordersalesplansnapshot_id,
    dso.performance_id,
    dso.ticketclass_id,
    dso.show_id,
    dso.setnumber,
    dso.ticket_price,
    dso.tpshowid,
    dso.tpsalesplanid,
    dso.agent_type,
    dso.orderdelivery_id,
    dso.fetchticketway_id,
    dso.fetch_type,
    dso.needidcard,
    dso.province_name as deliver_province_name,
    dso.city_name as deliver_city_name,
    dso.expressfee,
    dso.deliver_create_time,
    ssp.settlementpayment_id,
    ssp.bill_id,
    ssp.contract_id,
    ssp.income,
    ssp.expense,
    ssp.grossprofit,
    ssp.takerate,
    dso.discountamount,
    dpe.shop_id,
    dpe.activity_id,
    dpe.category_id,
    dpe.province_id,
    dpo.project_id,
    dpo.bd_userid
from (
    select
        settlementpaymentid as settlementpayment_id,
        billid as bill_id,
        contractid as contract_id,
        income,
        expense,
        grossprofit,
        takerate
    from origindb.dp_myshow__s_settlementpayment
    where to_date(paytime)='$now.date'
    ) as ssp
    join (
    select order_id,
        sellchannel,
        clientplatform,
        dianping_userid,
        meituan_userid,
        city_id,
        salesplan_id,
        supply_price,
        sell_price,
        salesplan_count,
        totalprice,
        maoyan_order_id,
        customer_id,
        tporderid,
        order_create_time,
        lockedtime,
        payexpiretime,
        pay_time,
        wxopenid,
        needrealname,
        needseat,
        totalticketprice,
        ordersalesplansnapshot_id,
        performance_id,
        ticketclass_id,
        show_id,
        setnumber,
        ticket_price,
        tpshowid,
        tpsalesplanid,
        agent_type,
        orderdelivery_id,
        fetchticketway_id,
        fetch_type,
        needidcard,
        province_name as deliver_province_name,
        city_name as deliver_city_name,
        expressfee,
        deliver_create_time
    from mart_movie.detail_myshow_saleorder
    where pay_time is not null
    and to_date(pay_time)='$now.date'
    ) as dso
    on ssp.orderid=dso.order_id
    left join mart_movie.dim_myshow_performance as dpe
    on dso.performance_id=dpe.performance_id
    left join mart_movie.dim_myshow_project as dpo
    on dpe.activity_id=dpo.activity_id
    and dso.customer_id=dpo.customer_id
    and dpo.activity_id is not null
$lim">${attach}

echo "succuess,detail see ${attach}"

