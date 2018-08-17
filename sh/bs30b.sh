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
per=`fun dim_myshow_performance.sql u`

file="bs30"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    cel_name,
    case when 5 in (\$dim) then dt
    else 'all' end as dt,
    case when 1 in (\$dim) then value2
    else 'all' end as pt,
    mi_province_name,
    mi_city_name,
    province_name,
    city_name,
    age,
    sex,
    case when 6 in (\$dim) then coalesce(pay_num,0)
    else 'all' end as pay_num,
    count(distinct sim.uid) user_num,
    sum(order_num) order_num,
    sum(totalprice) totalprice
from (
    select
        dt,
        case when 20 not in (\$dim) then 'all'
        else coalesce(ciy.province_name,'未知') end as mi_province_name,
        case when 30 not in (\$dim) then 'all'
        else coalesce(ciy.city_name,'未知') end as mi_city_name,
        case when 2 not in (\$dim) then 'all'
            when action_flag%2=0 then coalesce(ciy.province_name,'未知')
        else coalesce(so.province_name,ciy.province_name,'未知') end as province_name,
        case when 3 not in (\$dim) then 'all'
            when action_flag%2=0 then coalesce(ciy.city_name,'未知')
        else coalesce(so.city_name,ciy.city_name,'未知') end as city_name,
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
            case when 4 not in (\$dim) then 'all'
                when soi.order_id is null then '未知'
            else year(current_date)-yer end as age,
            case when 40 not in (\$dim) then 'all' 
                when soi.order_id is null then '未知'
                when sex=0 then '女'
            else '男' end as sex,
            sum(distinct action_flag) action_flag,
            count(distinct case when action_flag=1 then sro.order_id end) as order_num,
            sum(case when id_rank=1 then totalprice
                when id_rank is null then totalprice end) as totalprice 
        from (
            select
                case when 5 in (\$dim) then substr(pay_time,1,10) 
                else 'all' end dt,
                usermobileno as mobile,
                province_name,
                city_name,
                performance_id,
                case when \$uid=1 then usermobileno
                else meituan_userid end as uid,
                1 as action_flag,
                order_id,
                totalprice
            $so
                and (
                    performance_id in (\$performance_id)
                    or -99 in (\$performance_id)
                    )
                and 1 in (\$action_flag)
                and sellchannel not in (9,10)
            union all
            select
                case when 5 in (\$dim) then substr(CreateTime,1,10)
                else 'all' end dt,
                phonenumber as mobile,
                'all' province_name,
                'all' city_name,
                performanceid as performance_id,
                case when \$uid=1 then phonenumber
                else userid end as uid,
                10 as action_flag,
                -99 as order_id,
                0 as totalprice
            $sme
                and (
                    performanceid in (\$performance_id)
                    or -99 in (\$performance_id)
                    )
                and 2 in (\$action_flag)
            union all
            select
                case when 5 in (\$dim) then substr(createtime,1,10)
                else 'all' end dt,
                mobile,
                'all' province_name,
                'all' city_name,
                performance_id,
                case when \$uid=1 then mobile
                else mtuserid end as uid,
                100 as action_flag,
                -99 as order_id,
                0 as totalprice
            from (
                $ssr
                    and 3 in (\$action_flag)
                ) ssr
                join (
                    $srs
                    and (
                        performanceid in (\$performance_id)
                        or -99 in (\$performance_id)
                        )
                    ) srs
                on srs.stockoutregisterstatisticid=ssr.stockoutregisterstatisticid
            ) sro
            join (
                select
                    performance_id,
                    '\$cel_name_a' as cel_name
                $per
                    and regexp_like(performance_name,'\$cel_name_a')
                    and '\$cel_name_a'<>'测试'
                union all
                select
                    performance_id,
                    '\$cel_name_b' as cel_name
                $per
                    and regexp_like(performance_name,'\$cel_name_b')
                    and '\$cel_name_b'<>'测试'
                union all
                select
                    performance_id,
                    case when 1=\$cam then performance_id 
                    else 'all' end as cel_name
                $per
                    and (performance_id in (\$performance_id)
                        or ('\$cel_name_a'='测试'
                            and '\$cel_name_b'='测试'
                            and -99 in (\$performance_id)))
                ) per
            on per.performance_id=sro.performance_id
            left join (
                select
                    orderid as order_id,
                    case when length(idnumber)=15 then concat('19',substr(idnumber,7,2))
                    else substr(idnumber,7,4) end as yer,
                    case when length(idnumber)=15 then substr(idnumber,15,1)%2
                    else substr(idnumber,17,1)%2 end as sex,
                    row_number() over (partition by orderid order by 1) as id_rank
                $soi
                    and ((length(idnumber)=18
                            and regexp_like(idnumber,
                        '^[1-9]\d{5}(18|19|([23]\d))\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$'))
                        or (length(idnumber)=15
                            and regexp_like(idnumber,'^[1-9]\d{5}\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{2}$')
                        ))
                    and (
                        performanceid in (\$performance_id)
                        or -99 in (\$performance_id)
                        )
                    and (
                        4 in (\$dim)
                        or 40 in (\$dim)
                        )
                ) as soi
            on sro.order_id=soi.order_id
            and sro.action_flag=1
        group by
            1,2,3,4,5,6,7,8
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
        so.action_flag in (\$action_tag)
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
    1,2,3,4,5,6,7,8,9,10
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


