
select
    spo.dt,
    cgr.batch_id,
    cgr.batch_name,
    cgr.denomination,
    cgr.begindate,
    cgr.enddate,
    count(distinct cur.order_id) as use_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit
from (
    select coupongroupid as batch_id, title as batch_name, denomination, validdatetype, undertakertype, validdays, begindate, enddate from origindb.dp_myshowcoupon__s_coupongroup where title not like '%测试%'
    ) cgr
    join (
    select coupongroupid as batch_id, couponid as coupon_id, addtime from origindb.dp_myshowcoupon__s_coupon where id is not null
    ) cou
    on cgr.batch_id=cou.batch_id
    join (
    select couponid as coupon_id, orderid as order_id, discountamount from origindb.dp_myshowcoupon__s_couponuserecord where ID is not null
    ) cur
    on cou.coupon_id=cur.coupon_id
    join (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    and discountamount>0
    ) spo
    on spo.order_id=cur.order_id
group by
    spo.dt,
    cgr.batch_id,
    cgr.batch_name,
    cgr.denomination,
    cgr.begindate,
    cgr.enddate
;
