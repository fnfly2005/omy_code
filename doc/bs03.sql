
select
    meituan_userid,
    dianping_userid,
    value3,
    coalesce(category_id,-99) category_id,
    first_pay_order_date,
    last_pay_order_date,
    pay_dt_num
from
(select
    meituan_userid,
    dianping_userid,
    value3,
    category_id,
    min(dt) as first_pay_order_date,
    max(dt) as last_pay_order_date, 
    count(distinct dt) as pay_dt_num,
from
(
select
    meituan_userid,
    dianping_userid,
    sellchannel,
    case when category_id is null then 8
    when category_id=0 then 8
    else category_id end as category_id,
    partition_date as dt
from
    mart_movie.detail_myshow_salepayorder
where
    partition_date>='2017-10-01'
    ) as s1
    join 
    (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='sellchannel'
    ) as dic
    on s1.sellchannel=dic.key
group by
    meituan_userid,
    dianping_userid,
    value3,
    category_id
grouping sets(
(meituan_userid,dianping_userid,value3),
(meituan_userid,dianping_userid,value3,category_id)
)
) as s2
;
