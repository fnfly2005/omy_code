#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

per=`fun dim_myshow_performance.sql`
psr=`fun dp_myshow__s_performancesaleremind.sql` 
file="bs25"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fpw.dt,
    fpw.performance_id,
    performance_name,
    uv,
    mp_num,
    order_num,
    totalprice
from (
    select
        PerformanceID as performance_id,
        substr(OnSaleTime,1,10) as ot,
        substr(CountdownTime,1,10) as ct
    from
        origindb.dp_myshow__s_performancesaleremind
    where
        Status=1
        and NeedRemind=1
        ) as psr
    join (
    select
        partition_date as dt,
        case when page_identifier<>'pages/show/detail/index'
            then custom['performance_id']
        else custom['id'] end as performance_id,
        count(distinct union_id) as uv
    from mart_flow.detail_flow_pv_wide_report
    where
        partition_date>='\$\$begindate'
        and partition_date<'\$\$enddate'
        and partition_log_channel='movie'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
        and page_identifier in ('c_Q7wY4','pages/show/detail/index')
    group by
        1,2
        ) as fpw
    on fpw.performance_id=psr.performance_id
        and fpw.dt>=psr.ct
        and fpw.dt<=psr.ot
    left join (
        select
            substr(CreateTime,1,10) as dt,
            performanceid as performance_id,
            count(1) mp_num
        from
            origindb.dp_myshow__s_messagepush
        where
            phonenumber is not null
            and CreateTime>='2018-03-02'
        group by
            1,2
        ) as smp
    on fpw.performance_id=smp.performance_id
    and fpw.dt=smp.dt
    left join (
        select
            partition_date as dt,
            performance_id,
            count(distinct order_id) order_num,
            sum(totalprice) totalprice
        from
            mart_movie.detail_myshow_salepayorder
        where
            partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and sellchannel<>8
        group by
            1,2
            ) as spo
    on fpw.dt=spo.dt
    and fpw.performance_id=spo.performance_id
    left join (
    $per
    ) per
    on per.performance_id=fpw.performance_id
$lim">${attach}

echo "succuess,detail see ${attach}"
