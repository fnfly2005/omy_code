/*优惠券券号表*/
select
    coupongroupid as batch_id,
    couponid as coupon_id,
    addtime
from
    origindb.dp_myshowcoupon__s_coupon
where
    id is not null
