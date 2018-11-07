#!/bin/bash
#--------------------mysensitiveycsensitivereadme-------------------
#*************************来源追踪-来源/日期/平台/UV/销售数据*******************
# 优化输出方式,优化函数处理
path="$private_home/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}
path="$private_home/my_code/"

fpw=`fun detail_flow_pv_wide_report.sql` 
md=`fun myshow_dictionary.sql`
per=`fun dim_myshow_performance.sql`
spo=`fun detail_myshow_salepayorder.sql u`

file="yysc09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fromTag,
    case when 1 in (\$dim) then dt
    else '全部' end as dt,
    pt,
    sum(totalprice) as totalprice,
    avg(first_uv) as first_uv,
    avg(detail_uv) as detail_uv,
    sum(order_num) order_num,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit
from (
    select
        case when md1.value2 is not null then md1.value2
        when fpw.fromTag is null then '其他'
        else fpw.fromTag end fromTag,
        fpw.dt,
        fpw.pt,
        sum(totalprice) as totalprice,
        sum(first_uv) first_uv,
        sum(detail_uv) detail_uv,
        sum(order_num) order_num,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            fp.fromTag,
            fp.dt,
            value2 as pt,
            sum(first_uv) as first_uv,
            sum(detail_uv) as detail_uv
        from (
            select
                case when uv_src=0 then '其他'
                when uv_src is null then '其他'
                else uv_src end as fromTag,
                partition_date as dt,
                case when 2 in (\$dim) then app_name
                else 'all' end as app_name,
                count(distinct case when page_name_my='ycsensitive首页' then union_id end) as first_uv,
                count(distinct case when page_name_my='ycsensitive详情页' then union_id end) as detail_uv
            from 
                mart_movie.detail_myshow_pv_wide_report
            where partition_date>='\$\$begindate'
                and partition_date<'\$\$enddate'
                and partition_biz_bg=1
                and (
                    (
                        page_name_my in ('ycsensitive详情页','ycsensitive首页')
                        and \$source=0
                        )
                    or (
                        page_name_my='ycsensitive详情页'
                        and \$source=1
                            )
                        )
                and app_name<>'gwrsensitive'
                and (
                    uv_src in ('\$from_src')
                    or 'all' in ('\$from_src')
                    )
            group by
                case when uv_src=0 then '其他'
                when uv_src is null then '其他'
                else uv_src end,
                partition_date,
                case when 2 in (\$dim) then app_name
                else 'all' end
            union all
            select
                case when fromTag=0 then '其他'
                when fromTag is null then '其他'
                else fromTag end as fromTag,
                fph.dt,
                app_name,
                0 as first_uv,
                detail_uv
            from (
                select
                    case when url_parameters rlike 'fromTag=' 
                        then split(regexp_extract(url_parameters,'fromTag=[^&]+'),'=')[1]
                    when url rlike 'fromTag=' 
                        then split(regexp_extract(url,'fromTag=[^&]+',2),'=')[1]
                    when url rlike 'fromTag%3D'
                        then split(regexp_extract(url,'fromTag%3D[^%]+'),'%3D')[1]
                    else 'other'
                    end as fromTag,
                    partition_date as dt,
                    'all' as app_name,
                    count(distinct union_id) as detail_uv
                from
                    mart_flow.detail_flow_pv_wide_report
                where partition_date>='\$\$begindate'
                    and partition_date<'\$\$enddate'
                    and (
                        (
                            partition_log_channel='firework'
                            and \$source=3
                            )
                        or (
                            partition_log_channel='cube'
                            and \$source=2
                            )
                        )
                    and partition_app in (
                        'movie',
                        'dpsensitive_nova',
                        'other_app',
                        'dp_m',
                        'group'
                        )
                    and page_name rlike '\$id'
                    and app_name<>'gwrsensitive'
                group by
                    case when url_parameters rlike 'fromTag=' 
                        then split(regexp_extract(url_parameters,'fromTag=[^&]+'),'=')[1]
                    when url rlike 'fromTag=' 
                        then split(regexp_extract(url,'fromTag=[^&]+',2),'=')[1]
                    when url rlike 'fromTag%3D' 
                        then split(regexp_extract(url,'fromTag%3D[^%]+'),'%3D')[1]
                    else 'other'
                    end,
                    partition_date,
                    'all'
                    ) fph
            where (
                    fromTag in ('\$from_src')
                    or 'all' in ('\$from_src')
                    )
            ) as fp
            left join (
                $md
                and key_name='app_name'
                ) md
            on fp.app_name=md.key
        group by
            fp.fromTag,
            fp.dt,
            value2
        ) fpw
        left join (
            select
                fromTag,
                sdo.dt,
                value2 as pt,
                sum(totalprice) as totalprice,
                sum(order_num) order_num,
                sum(ticket_num) as ticket_num,
                sum(grossprofit) as grossprofit
            from (
                select
                    case when fromTag=0 then '其他'
                    when fromTag is null then '其他'
                    else fromTag
                    end as fromTag,
                    fp2.dt,
                    case when \$source in (0,1) and 2 in (\$dim) then sellchannel
                    else -99 end as sellchannel,
                    sum(totalprice) as totalprice,
                    count(distinct fp2.order_id) as order_num,
                    sum(ticket_num) as ticket_num,
                    sum(grossprofit) as grossprofit
                from (
                    select distinct
                        partition_date as dt,
                        case when event_id='b_w047f3uw' then utm_source
                        else custom['fromTag']
                        end as fromTag,
                        order_id
                    from
                        mart_movie.detail_flow_mv_wide_report
                    where partition_date>='\$\$begindate'
                        and partition_date<'\$\$enddate'
                        and partition_log_channel='movie'
                        and partition_app in (
                            'movie',
                            'dpsensitive_nova',
                            'other_app',
                            'dp_m',
                            'group'
                            )
                        and app_name<>'gwrsensitive'
                        and event_id in ('b_WLx9n','b_w047f3uw')
                        and (case when event_id='b_w047f3uw' then utm_source
                            else custom['fromTag'] end in ('\$from_src')
                        or 'all' in ('\$from_src'))
                    ) as fp2
                    join (
                        select
                            partition_date as dt,
                            sellchannel,
                            case when -99 in (\$pid) then -99
                            else performance_id end as performance_id,
                            order_id,
                            totalprice,
                            (salesplan_count*setnumber) as ticket_num,
                            grossprofit
                        $spo
                            and sellchannel in (1,2,3,5,6,7,13)
                            and (
                                performance_id in (\$pid)
                                or -99 in (\$pid)
                                )
                        ) spo
                    on fp2.order_id=spo.order_id
                    and spo.dt=fp2.dt
                group by
                    case when fromTag=0 then '其他'
                    when fromTag is null then '其他'
                    else fromTag end,
                    fp2.dt,
                    case when \$source in (0,1) and 2 in (\$dim) then sellchannel
                    else -99 end
                ) as sdo
                left join (
                    $md
                    and key_name='sellchannel'
                    ) md3
                on md3.key=sdo.sellchannel 
            group by
                fromTag,
                sdo.dt,
                value2
            ) as sp
        on sp.fromTag=fpw.fromTag
        and sp.dt=fpw.dt
        and sp.pt=fpw.pt
        left join (
            $md
            and key_name='fromTag'
            ) md1
        on fpw.fromTag=md1.key
    group by
        case when md1.value2 is not null then md1.value2
        when fpw.fromTag is null then '其他'
        else fpw.fromTag end,
        fpw.dt,
        fpw.pt
    ) as yy
group by
    fromTag,
    case when 1 in (\$dim) then dt
    else '全部' end,
    pt
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
