/*微格订单明细表*/
select
    dt,
    item_id,
    order_id,
    order_src,
    user_id,
    order_mobile mobile,
    receive_mobile,
    pay_no,
    total_money
from
    upload_table.detail_wg_saleorder
where
    dt>='$$begindate'
    and dt<'$$enddate'
