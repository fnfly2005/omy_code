
select 
    case when 5 in ($dim) then dt
    else 'all' end as dt,
    case when 1 in ($dim) then pt
    else 'all' end as pt,
    case when 2 in ($dim) then province_name
    else 'all' end as province_name,
    case when 3 in ($dim) then city_name
    else 'all' end as city_name,
    case when 4 in ($dim) then age
    else 'all' end as age,
    count(distinct mobile) user_num
from (
    select
        dt,
        md.value2 as pt,
        case when cit.city_id is not null then cit.city_id
        else mi.city_id end as city_id,
        datediff(dt,birthday)/365 age,
        so.mobile
    from (
        select
            dt,
            sellchannel,
            meituan_userid,
            mobile,
            row_number() over (partition by mobile order by dt desc) rank
        from (
            select
                substr(pay_time,1,10) dt,
                sellchannel,
                case when sellchannel in (1,2,5) then meituan_userid
                else -99 end as meituan_userid,
                usermobileno as mobile
            from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
                and performance_id in ($performance_id)
                and sellchannel not in (9,10,11)
                and usermobileno rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                and usermobileno not in (13800138000,13000000000)
                and 1 in ($action_flag)
            union all
            select
                substr(CreateTime,1,10) as dt,
                sellchannel,
                case when usertype=2 and sellchannel in (1,2,5) then userid
                else -99 end as meituan_userid,
                phonenumber as mobile
            from
                origindb.dp_myshow__s_messagepush 
            where
                phonenumber is not null
                and CreateTime>'2018-03-01'
                and performanceid in ($performance_id)
                and 2 in ($action_flag)
                and phonenumber rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                and phonenumber not in (13800138000,13000000000)
            ) sro
        ) so
        left join (
            select userid, birthday, city_id from mart_movie.detail_user_base_info where userid is not null and (length(birthday)=10 or city_id<>0)
                and city_id is not null
            ) dub
        on dub.userid=so.meituan_userid
        and so.meituan_userid<>-99
        and rank=1
        and $mi=0
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='sellchannel'
            ) md
        on md.key=so.sellchannel
        left join (
            select mobile, mobile_type, city_id from upload_table.mobile_info
            ) mi
        on mi.mobile=substr(so.mobile,1,7)
        left join (
            select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
            ) cit
        on cit.mt_city_id=dub.city_id
    where
        so.rank=1
        or 5 not in ($dim)
    ) sim
    left join (
        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
        ) ciy
    on ciy.city_id=sim.city_id
group by
    case when 5 in ($dim) then dt
    else 'all' end,
    case when 1 in ($dim) then pt
    else 'all' end,
    case when 2 in ($dim) then province_name
    else 'all' end,
    case when 3 in ($dim) then city_name
    else 'all' end,
    case when 4 in ($dim) then age
    else 'all' end
;
