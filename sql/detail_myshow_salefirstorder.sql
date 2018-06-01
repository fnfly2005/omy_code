/*用户首末单明细表*/
select
    meituan_userid,
    first_pay_order_date,
    pay_dt_num
from
    mart_movie.detail_myshow_salefirstorder
where
    dianping_userid is not null
    and category_id=-99
