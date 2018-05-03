
select
    dt,
    pt,
    ft,
    show_name,
    case when dif_min is null then '未取票'
        when dif_min='all' then 'all'
        when -cast(dif_min as bigint)>=($hou*60) then '超时取票'
    else '正常取票' end as dif_tag,
    dif_hour,
    dif_min,
    order_num
from (
    select
        dt,
        pt,
        value2 as ft,
        show_name,
        case when 3=$det then dif_min/60
        else dif_hour end dif_hour,
        case when 2=$det then dif_hour*60
        else dif_min end dif_min,
        order_num
    from (
        select
            dt,
            value2 as pt,
            fetch_type,
            show_name,
            case when 2=$det
                then date_diff('hour',pay_time,fetched_time)
            else 'all' end as dif_hour,
            case when 3=$det
                then date_diff('minute',fetched_time,show_time)
            else 'all' end as dif_min,
            count(distinct so.order_id) as order_num
        from (
            select
                case when 1 in ($dim) then substr(pay_time,1,10)
                else 'all' end as dt,
                case when 2 in ($dim) then sellchannel
                else -99 end as sellchannel,
                fetch_type,
                case when 3 in ($dim) then show_name
                else 'all' end as show_name,
                date_parse(pay_time,'%Y-%m-%d %H:%i:%s') as pay_time,
                date_parse(show_starttime,'%Y-%m-%d %H:%i:%s') as show_time,
                order_id
            from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and performance_id in ($performance_id)
            and (fetch_type=4 or 1=$det)
            ) so
            left join (
            select
                orderid as order_id,
                date_parse(fetchedtime,'%Y-%m-%d %H:%i:%s') as fetched_time
            from origindb.dp_myshow__s_orderdelivery where OrderDeliveryID is not null
            ) sod
            on sod.order_id=so.order_id
            left join (
            select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
            and key_name='sellchannel'
            ) md
            on md.key=so.sellchannel
        group by
            1,2,3,4,5,6
        ) sd
        left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='fetch_type'
        ) md
        on md.key=sd.fetch_type
    ) as sen
;
