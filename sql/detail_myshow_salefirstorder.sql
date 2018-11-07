/*用户首末单明细表*/
select
    mtsensitive_userid,
    first_pay_order_date,
    pay_dt_num
from
    mart_movie.detail_myshow_salefirstorder
where
    dpsensitive_userid is not null
    and category_id=-99
