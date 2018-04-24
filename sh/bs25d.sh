#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

per=`fun dim_myshow_performance.sql`
psr=`fun dp_myshow__s_performancesaleremind.sql` 
md=`fun myshow_dictionary.sql`
file="bs25"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    count(distinct union_id) uv
from (
    select distinct
        PerformanceID,
        substr(OnSaleTime,1,10) ot,
        substr(CountdownTime,1,10) ct
    from
        origindb.dp_myshow__s_performancesaleremind
    where
        Status=1
        and NeedRemind=1
    ) as sp
    left join (
        select
            partition_date as dt,
            case when page_identifier<>'pages/show/detail/index'
            then custom['performance_id']
            else custom['id'] end as performance_id,
            union_id
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
            and page_identifier in ('pages/show/detail/index','c_Q7wY4')
            and app_name<>'gewara'
        group by
            partition_date,
            case when page_identifier<>'pages/show/detail/index'
                then custom['performance_id']
            else custom['id'] end,
            union_id
        ) fp1
    on fp1.performance_id=sp.PerformanceID
where 
    dt is not null
    and fp1.dt>=sp.ct
    and fp1.dt<=sp.ot
group by
    dt
$lim">${attach}

echo "succuess,detail see ${attach}"
