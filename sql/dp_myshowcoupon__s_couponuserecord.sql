/*抵用券使用记录*/
select
    couponid as coupon_id,
    orderid as order_id,
    discountamount
from
    origindb.dp_myshowcoupon__s_couponuserecord
where
    ID is not null
