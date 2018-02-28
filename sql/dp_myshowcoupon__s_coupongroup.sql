/*优惠券批次表*/
select
    coupongroupid as batch_id,
    title as batch_name,
    denomination,
    validdatetype,
    undertakertype,
    validdays,
    begindate,
    enddate
from
    origindb.dp_myshowcoupon__s_coupongroup
where
    title not like '%测试%'
