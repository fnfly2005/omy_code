
select 
    case when 5 in ($dim) then dt
    else 'all' end as dt,
    case when 1 in ($dim) then value2
    else 'all' end as pt,
    mi_province_name,
    mi_city_name,
    province_name,
    city_name,
    age,
    case when 6 in ($dim) then pay_num
    else 'all' end as pay_num,
    count(distinct sim.uid) user_num,
    sum(totalprice) totalprice
from (
    select
        dt,
        case when 20 in ($dim) then ciy.province_name
        else 'all' end as mi_province_name,
        case when 30 in ($dim) then ciy.city_name 
        else 'all' end as mi_city_name,
        case when 2 in ($dim) then so.province_name
        else 'all' end as province_name,
        case when 3 in ($dim) then so.city_name 
        else 'all' end as city_name,
        age,
        totalprice,
        uid
    from (
        select
            dt,
            mobile,
            province_name,
            city_name,
            age,
            totalprice,
            uid,
            row_number() over (partition by uid order by dt desc) rank
        from (
            select
                substr(CreateTime,1,10) as dt,
                'all' as age,
                userid as meituan_userid,
                phonenumber as mobile,
                'all' province_name,
                'all' city_name,
                case when $uid=1 then phonenumber
                else userid end as uid,
                0 as totalprice
            from
                origindb.dp_myshow__s_messagepush 
            where
                phonenumber is not null
                and performanceid in ($performance_id)
                and 2 in ($action_flag)
            union all
            select
                dt,
                case when 4 in ($dim) then cast(substr(dt,1,4) as bigint)-yer
                else 'all' end as age,
                meituan_userid,
                mobile,
                province_name,
                city_name,
                case when $uid=1 then mobile
                else meituan_userid end as uid,
                sum(totalprice) as totalprice
            from (
                select
                    substr(pay_time,1,10) dt,
                    order_id,
                    meituan_userid,
                    province_name,
                    city_name,
                    usermobileno as mobile,
                    totalprice
                from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
                    and performance_id in ($performance_id)
                    and sellchannel not in (9,10,11)
                    and 1 in ($action_flag)
                ) as s1
                left join (
                    select
                        order_id,
                        cast(yer as bigint) as yer
                    from (
                        select
                            orderid as order_id,
                            min(id) id
                        from origindb.dp_myshow__s_orderidentification where TicketNumber>0
                            and 4 in ($dim)
                            and PerformanceID in ($performance_id)
                        group by
                            orderid
                        ) as so1
                        left join (
                            select
                                id,
                                substr(IDNumber,7,4) as yer
                            from origindb.dp_myshow__s_orderidentification where TicketNumber>0
                                and PerformanceID in ($performance_id)
                            ) as so2
                        on so1.id=so2.id
                    ) as soi
                on s1.order_id=soi.order_id
            group by
                1,2,3,4,5,6,7
            ) sro
        ) so
        left join (
            select mobile, mobile_type, city_id from upload_table.mobile_info
            ) mi
        on mi.mobile=substr(so.mobile,1,7)
        left join (
            select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
            ) ciy
        on ciy.city_id=mi.city_id
    where
        so.rank=1
        or 5 in ($dim)
    ) sim
    left join (
        select
            case when $uid=1 then mobile
                else user_id end as uid,
            min(sellchannel) sellchannel,
            min(pay_num) pay_num
        from
            mart_movie.dim_myshow_userlabel
        group by
            1
       ) dmu
    on dmu.uid=sim.uid
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='sellchannel'
        ) md
    on md.key=dmu.sellchannel
group by
    1,2,3,4,5,6,7,8
;
