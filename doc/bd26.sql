
select
    qrcode
from (
    select
        order_id
    from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        and performance_id in ($performance_id)
    ) spo
    join (
        select orderID as order_id, qrcode from origindb.dp_myshow__s_orderticket where CreateTime>='$$begindate' and CreateTime<'$$enddate'
            and qrcode is not null
            and CreateTime>'2017-11-17'
        ) ket
    on ket.order_id=spo.order_id
;
