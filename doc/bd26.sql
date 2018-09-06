
select
    qrcode
from (
    select
        order_id
    from mart_movie.detail_myshow_salepayorder
    where performance_id in ($performance_id)
    ) spo
    join (
        select orderID as order_id, qrcode from origindb.dp_myshow__s_orderticket
        ) ket
    on ket.order_id=spo.order_id
;
