#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dms=`fun detail_myshow_salesplan.sql`
sho=`fun dim_myshow_show.sql`
cit=`fun dim_myshow_city.sql`
per=`fun dim_myshow_performance.sql`
dpr=`fun dim_myshow_project.sql`

file="xk05"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ss.dt,
    area_1_level_name,
    province_name,
    city_name,
    category_name,
    so.performance_id,
    performance_name,
    case when bd_name=0 then '无'
    else bd_name end as bd_name,
    totalprice,
    rank,
    all_ticketnum,
    us_ticketnum
from (
    select
        area_1_level_name,
        province_name,
        city_name,
        category_name,
        spo.performance_id,
        performance_name,
        totalprice,
        row_number() over (partition by area_1_level_name order by totalprice desc) rank
    from (
        select
            performance_id,
            sum(totalprice) as totalprice
        from
            mart_movie.detail_myshow_salepayorder
        where
            partition_date>='\$\$today{-7d}'
        group by
            1
        ) spo
        left join (
            $per
            ) per
        on per.performance_id=spo.performance_id
    ) so
    join (
        select
            dt,
            dms.performance_id,
            max(case when dpr.project_id is null then 0 else bd_name end) bd_name,
            count(distinct ticketclass_id) as all_ticketnum,
            count(distinct case when salesplan_sellout_flag=0 and customer_type_id=2 then ticketclass_id end) us_ticketnum
        from (
            select
                partition_date as dt,
                customer_type_id,
                performance_id,
                ticketclass_id,
                show_id,
                salesplan_sellout_flag,
                project_id,
                city_id
            from
                mart_movie.detail_myshow_salesplan
            where
                partition_date='\$\$today{-1d}'
            ) dms
            left join (
                $sho
                ) sho
            on sho.show_id=dms.show_id
            left join (
                select
                    project_id,
                    bd_name
                from
                    mart_movie.dim_myshow_project
                where
                    bd_name is not null
                ) dpr
            on dpr.project_id=dms.project_id
        group by
            1,2
        ) ss
    on so.performance_id=ss.performance_id
    and so.rank<=50
order by
    area_1_level_name,
    rank
$lim">${attach}

echo "succuess,detail see ${attach}"
