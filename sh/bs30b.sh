#!/bin/bash
source ./fuc.sh

mi=`fun mobile_info.sql`
soi=`fun dp_myshow__s_orderidentification.sql u`
md=`fun myshow_dictionary.sql`
so=`fun detail_myshow_saleorder.sql u`
cit=`fun dim_myshow_city.sql`
sme=`fun dp_myshow__s_messagepush.sql u`
dmu=`fun dim_myshow_userlabel.sql u`
srs=`fun dp_myshow__s_stockoutregisterstatistic.sql`
ssr=`fun dp_myshow__s_stockoutregisterrecord.sql`

file="bs30"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    case when 5 in (\$dim) then dt
    else 'all' end as dt,
    case when 1 in (\$dim) then value2
    else 'all' end as pt,
    mi_province_name,
    mi_city_name,
    province_name,
    city_name,
    age,
    case when 6 in (\$dim) then pay_num
    else 'all' end as pay_num,
    count(distinct sim.uid) user_num,
    sum(totalprice) totalprice
from (
    select
        dt,
        case when 20 in (\$dim) then ciy.province_name
        else 'all' end as mi_province_name,
        case when 30 in (\$dim) then ciy.city_name 
        else 'all' end as mi_city_name,
        case when 2 in (\$dim) then so.province_name
        else 'all' end as province_name,
        case when 3 in (\$dim) then so.city_name 
        else 'all' end as city_name,
        age,
        totalprice,
        uid
    from (
        select
            dt, mobile,
            province_name,
            city_name,
            age,
            totalprice,
            uid,
            rank() over (partition by uid order by dt desc) rank
        from (
            select
                dt,
                case when 4 in (\$dim) then cast(substr(dt,1,4) as bigint)-yer
                else 'all' end as age,
                meituan_userid,
                mobile,
                province_name,
                city_name,
                performance_id,
                case when \$uid=1 then mobile
                else meituan_userid end as uid,
                sum(totalprice) as totalprice
            from (
                select
                    substr(pay_time,1,10) dt,
                    order_id,
                    performance_id,
                    meituan_userid,
                    province_name,
                    city_name,
                    usermobileno as mobile,
                    totalprice
                $so
                    and performance_id in (\$performance_id)
                    and sellchannel not in (9,10,11)
                    and 1 in (\$action_flag)
                ) as s1
                left join (
                    select
                        order_id,
                        cast(yer as bigint) as yer
                    from (
                        select
                            orderid as order_id,
                            min(id) id
                        $soi
                            and 4 in (\$dim)
                            and PerformanceID in (\$performance_id)
                        group by
                            orderid
                        ) as so1
                        left join (
                            select
                                id,
                                substr(IDNumber,7,4) as yer
                            $soi
                                and PerformanceID in (\$performance_id)
                            ) as so2
                        on so1.id=so2.id
                    ) as soi
                on s1.order_id=soi.order_id
            group by
                1,2,3,4,5,6,7,8
            union all
            select
                substr(CreateTime,1,10) as dt,
                'all' as age,
                userid as meituan_userid,
                phonenumber as mobile,
                'all' province_name,
                'all' city_name,
                performanceid as performance_id,
                case when \$uid=1 then phonenumber
                else userid end as uid,
                0 as totalprice
            $sme
                and performanceid in (\$performance_id)
                and 2 in (\$action_flag)
            union all
            select
                substr(createtime,1,10) as dt,
                'all' as age,
                mtuserid as meituan_userid,
                mobile,
                'all' province_name,
                'all' city_name,
                case when \$uid=1 then mobile
                else mtuserid end as uid,
                0 as totalprice
            from (
                $ssr
                    and 3 in (\$action_flag)
                ) ssr
                join (
                    $srs
                        and performanceid in (\$performance_id)
                    ) srs
                on srs.stockoutregisterstatisticid=ssr.stockoutregisterstatisticid
            ) sro
        ) so
        left join (
            $mi
            ) mi
        on mi.mobile=substr(so.mobile,1,7)
        left join (
            $cit
            ) ciy
        on ciy.city_id=mi.city_id
    where
        so.rank=1
        or 5 in (\$dim)
    ) sim
    left join (
        select
            case when \$uid=1 then mobile
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
        $md
        and key_name='sellchannel'
        ) md
    on md.key=dmu.sellchannel
group by
    1,2,3,4,5,6,7,8
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


