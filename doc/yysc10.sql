
select
    case when $dt=1 then cs.dt
    else 'all' end as dt,
    category_name,
    cs.batch_id,
    batch_name,
    batch_value,
    begindate,
    enddate,
    sum(sued_num) sued_num,
    sum(use_num) use_num,
    sum(ticket_num) as ticket_num,
    sum(totalprice) as totalprice,
    sum(grossprofit) as grossprofit
from (
    select
        spo.dt,
        case when $cat=1 then per.category_name
        else 'all' end as category_name,
        cgr.batch_id,
        cgr.batch_name,
        cgr.batch_value,
        cgr.begindate,
        cgr.enddate,
        count(distinct spo.order_id) as use_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from (
        select batch_id, batch_name, batch_value, validdatetype, undertakertype, validdays, begindate, enddate from mart_movie.dim_myshow_batch where batch_name not like '%测试%'
        and status=1
        ) cgr
        left join (
        select coupongroupid as batch_id, couponid as coupon_id, addtime from origindb.dp_myshowcoupon__s_coupon where id is not null
        ) cou
        on cgr.batch_id=cou.batch_id
        left join (
        select couponid as coupon_id, orderid as order_id, discountamount from origindb.dp_myshowcoupon__s_couponuserecord where ID is not null
        and useddate>='$$begindate'
        and useddate<'$$enddate'
        ) cur
        on cou.coupon_id=cur.coupon_id
        left join (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        and discountamount>0
        ) spo
        on spo.order_id=cur.order_id
        left join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        ) per
        on per.performance_id=spo.performance_id
    group by
        1,2,3,4,5,6,7
    ) cs
    left join (
    select mba.partition_date as dt, mba.batch_id, (mba.issuedcount-mbb.issuedcount) as sued_num from mart_movie.detail_myshow_batch mba left join mart_movie.detail_myshow_batch mbb on mba.partition_date=substr( date_add('day',-1,date_parse(mbb.partition_date,'%Y-%m-%d')), 1,10) and mba.batch_id=mbb.batch_id where mba.partition_date>='$$begindate' and mba.partition_date<'$$enddate' and mbb.partition_date>='$$begindate{-1d}' and mbb.partition_date<'$$enddate{-1d}'
    ) bat
    on bat.batch_id=cs.batch_id
    and bat.dt=cs.dt
where
    sued_num>0
    or use_num>0
group by
    1,2,3,4,5,6,7
;
