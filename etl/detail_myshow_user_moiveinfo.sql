select
    count(1)
from (
select
    user_id,
    mobile_phone
from
    mart_movie.aggr_discount_card_seat_dwd
where
    mobile_phone is not null
    and order_time>='$$begindate'
    and order_time<'$$enddate'
    ) as csd
    left join mart_movie.detail_user_base_info ubi
    on csd.user_id=ubi.userid
