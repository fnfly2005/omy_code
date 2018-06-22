#!/bin/bash
path="/Users/fannian/Documents/my_code/"
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

per=`fun dim_myshow_performance.sql` 
fpw=`fun detail_flow_pv_wide_report.sql`
spo=`fun detail_myshow_salepayorder.sql u`
ss=`fun detail_myshow_salesplan.sql u`
md=`fun myshow_dictionary.sql`

file="bs35"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 1 in (\$dim) then substr(fpw.dt,1,7)
    else 'all' end as mt, 
    case when 2 in (\$dim) then fpw.dt
    else 'all' end as dt, 
    case when 3 in (\$dim) then fpw.pt
    else 'all' end as pt,
    case when 4 in (\$dim) then per.area_1_level_name
    else 'all' end as area_1_level_name,
    case when 5 in (\$dim) then per.area_2_level_name
    else 'all' end as area_2_level_name,
    case when 6 in (\$dim) then per.province_name
    else 'all' end as province_name,
    case when 7 in (\$dim) then per.city_name
    else 'all' end as city_name,
    case when 8 in (\$dim) then per.category_name
    else 'all' end as category_name,
    case when 9 in (\$dim) then per.shop_name
    else 'all' end as shop_name,
    count(distinct per.performance_id) as p_num
from (
    select distinct
        dt,
        value2 as pt,
        performance_id
    from (
        select distinct
            partition_date as dt,
            app_name,
            case when page_identifier in (
                'pages/show/detail/index',
                'packages/show/pages/detail/index')
                then custom['id'] 
            when page_identifier='c_b5okwrne'
                then custom['dramaId']
            else custom['performance_id'] end as performance_id
        from mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app in (
                'movie','dianping_nova','other_app','dp_m','group'
                )
            and page_identifier in (
                'c_b5okwrne',
                'packages/show/pages/detail/index',
                'pages/show/detail/index',
                'c_Q7wY4'
                )
        ) as fp1
        left join (
            $md
            and key_name='app_name'
            ) md
        on md.key=fp1.app_name
    where
        performance_id is not null
        and performance_id>0
    ) as fpw
    join (
        select distinct
            partition_date as dt,
            performance_id
        $ss
        and salesplan_sellout_flag=0
        ) ss
    on ss.dt=fpw.dt
    and ss.performance_id=fpw.performance_id
    left join (
        $per
        ) as per
    on per.performance_id=fpw.performance_id
group by
    1,2,3,4,5,6,7,8,9
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
