#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

file="bi05"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select so.orderid as order_id,
    so.sellchannel,
    so.clientplatform,
    so.dpuserid as dianping_userid,
    so.mtuserid as meituan_userid,
    so.usermobileno,
    so.dpcityid as city_id,
    so.salesplanid as salesplan_id,
    so.salesplansupplyprice as supply_price,
    so.salesplansellprice as sell_price,
    so.salesplancount as salesplan_count,
    so.totalprice,
    so.myorderid as maoyan_order_id,
    so.tpid as customer_id,
    so.tporderid,
    so.reservestatus as order_reserve_status,
    so.deliverstatus as order_deliver_status,
    so.refundstatus as order_refund_status,
    so.createtime as order_create_time,
    so.lockedtime,
    so.payexpiretime,
    so.paidtime as pay_time,
    so.ticketedtime as ticketed_time,
    so.showstatus,
    so.wxopenid,
    so.prepayid as prepay_id,
    so.needrealname,
    case when so.paidtime is null then so.consumedtime
    when sod.fetchtype=6 then 
    case when ds.show_endtime>'$now.now()' then so.consumedtime 
    when so.consumedtime is null then ds.show_endtime 
    else so.consumedtime end
    else ds.show_endtime end as consumed_time,
    so.needseat,
    so.totalticketprice,
    sos.ordersalesplansnapshotid as ordersalesplansnapshot_id,
    sos.performanceid as performance_id,
    sos.performancename as performance_name,
    sos.shopname as shop_name,
    sos.ticketid as ticketclass_id,
    sos.ticketname as ticketclass_description,
    sos.showid as show_id,
    sos.showname as show_name,
    sos.showstarttime as show_starttime,
    ds.show_endtime,
    sos.salesplanname as salesplan_name,
    sos.isthrough as show_isthrough,
    sos.setnum as setnumber,
    sos.salesplanticketprice as ticket_price,
    sos.tpshowid,
    sos.tpsalesplanid,
    sos.agenttype as agent_type,
    sod.orderdeliveryid as orderdelivery_id,
    sod.fetchticketwayid as fetchticketway_id,
    sod.fetchtype as fetch_type,
    sod.needidcard,
    sod.recipientidno,
    sod.provincename as province_name,
    sod.cityname as city_name,
    sod.districtname as district_name,
    sod.detailedaddress,
    sod.postcode,
    sod.recipientname,
    sod.recipientmobileno,
    sod.expresscompany,
    sod.expressno,
    sod.expressfee,
    sod.delivertime as deliver_time,
    sod.deliveredtime as delivered_time,
    sod.createtime as deliver_create_time,
    sod.localeaddress,
    sod.localecontactpersons,
    sod.fetchcode,
    sod.fetchqrcode,
    dis.discountamount,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from origindb.dp_myshow__s_order as so
    join origindb.dp_myshow__s_ordersalesplansnapshot as sos
    on so.orderid=sos.orderid
    left join origindb.dp_myshow__s_orderdelivery as sod
    on so.orderid=sod.orderid
    left join mart_movie.dim_myshow_show as ds
    on sos.showid=ds.show_id
    left join (
    select
        orderid,
        sum(discountamount) as discountamount
    from
        origindb.dp_myshow__s_orderdiscountdetail
    ) as dis
    on dis.orderid=so.orderid
$lim">${attach}

echo "succuess,detail see ${attach}"

