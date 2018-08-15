
select 
    cel_name,
    case when 5 in ($dim) then dt
    else 'all' end as dt,
    case when 1 in ($dim) then value2
    else 'all' end as pt,
    mi_province_name,
    mi_city_name,
    province_name,
    city_name,
    age,
    sex,
    case when 6 in ($dim) then pay_num
    else 'all' end as pay_num,
    count(distinct sim.uid) user_num,
    sum(order_num) order_num,
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
        uid,
        cel_name,
        age,
        sex,
        order_num,
        totalprice
    from (
        select
            dt,
            mobile,
            province_name,
            city_name,
            uid,
            cel_name,
            case when 4 not in ($dim) then 'all'
                when soi.order_id is null then '未知'
            else cast(substr(sro.dt,1,4) as bigint)-yer end as age,
            case when 40 not in ($dim) then 'all' 
                when soi.order_id is null then '未知'
                when sex=0 then '女'
            else '男' end as sex,
            sum(distinct action_flag) action_flag,
            count(distinct case when action_flag=1 then order_id end) as order_num,
            sum(case when id_rank=1 then totalprice
                when id_rank is null then totalprice end) as totalprice 
        from (
            select
                case when 5 in ($dim) then substr(pay_time,1,10) 
                else 'all' end dt,
                usermobileno as mobile,
                province_name,
                city_name,
                performance_id,
                case when $uid=1 then usermobileno
                else meituan_userid end as uid,
                1 as action_flag,
                order_id,
                totalprice
            from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
                and (
                    performance_id in ($performance_id)
                    or -99 in ($performance_id)
                    )
                and 1 in ($action_flag)
            union all
            select
                case when 5 in ($dim) then substr(CreateTime,1,10)
                else 'all' end dt,
                phonenumber as mobile,
                'all' province_name,
                'all' city_name,
                performanceid as performance_id,
                case when $uid=1 then phonenumber
                else userid end as uid,
                10 as action_flag,
                -99 as order_id,
                0 as totalprice
            from origindb.dp_myshow__s_messagepush where phonenumber is not null and createtime>='$$begindate' and createtime<'$$enddate' and regexp_like(phonenumber,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$') and phonenumber not in (13800138000,13000000000)
                and (
                    performanceid in ($performance_id)
                    or -99 in ($performance_id)
                    )
                and 2 in ($action_flag)
            union all
            select
                case when 5 in ($dim) then substr(createtime,1,10)
                else 'all' end dt,
                mobile,
                'all' province_name,
                'all' city_name,
                performance_id,
                case when $uid=1 then mobile
                else mtuserid end as uid,
                100 as action_flag,
                -99 as order_id,
                0 as totalprice
            from (
                select stockoutregisterstatisticid, usermobileno as mobile, smssendstatus, sellchannel, mtuserid, createtime from origindb.dp_myshow__s_stockoutregisterrecord where createtime>='$$begindate' and createtime<'$$enddate'
                    and 3 in ($action_flag)
                ) ssr
                join (
                    select stockoutregisterstatisticid, performanceid as performance_id, showid show_id, showname show_name, ticketprice as ticket_price from origindb.dp_myshow__s_stockoutregisterstatistic where 1=1
                    and (
                        performanceid in ($performance_id)
                        or -99 in ($performance_id)
                        )
                    ) srs
                on srs.stockoutregisterstatisticid=ssr.stockoutregisterstatisticid
            ) sro
            join (
                select
                    performance_id,
                    '$cel_name_a' as cel_name
                from mart_movie.dim_myshow_performance where 1=1
                    and regexp_like(performance_name,'$cel_name_a')
                    and '$cel_name_a'<>'测试'
                union all
                select
                    performance_id,
                    '$cel_name_b' as cel_name
                from mart_movie.dim_myshow_performance where 1=1
                    and regexp_like(performance_name,'$cel_name_b')
                    and '$cel_name_b'<>'测试'
                union all
                select
                    performance_id,
                    case when 1=$cam then performance_id 
                    else 'all' end as cel_name
                from mart_movie.dim_myshow_performance where 1=1
                    and performance_id in ($performance_id)
                    and -99 not in ($performance_id)
                ) per
            on per.performance_id=sro.performance_id
            left join (
                select
                    orderid as order_id,
                    substr(idnumber,7,4) as yer,
                    case when length(idnumber)=15 
                        then substr(idnumber,15,1)%2
                    else substr(idnumber,17,1)%2 end as sex,
                    row_number() over (partition by order_id order by 1) as id_rank
                from origindb.dp_myshow__s_orderidentification where TicketNumber>0
                    and (
                        performanceid in ($performance_id)
                        or -99 in ($performance_id)
                        )
                    and (
                        4 in ($dim)
                        or 40 in ($dim)
                        )
                ) as soi
            on sro.order_id=soi.order_id
            and sro.action_flag=1
        group by
            1,2,3,4,5,6,7,8
        ) so
        left join (
            select mobile, mobile_type, city_id from upload_table.mobile_info where 1=1
            ) mi
        on mi.mobile=substr(so.mobile,1,7)
        left join (
            select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
            ) ciy
        on ciy.city_id=mi.city_id
    where
        so.action_flag in ($action_tag)
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
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
        and key_name='sellchannel'
        ) md
    on md.key=dmu.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10
;
