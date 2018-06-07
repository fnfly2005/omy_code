#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
#修改字典表地址
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


spo=`fun detail_myshow_salepayorder.sql` 
md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.pt,
    fp1.first_uv,
    fp1.detail_uv,
    fp1.order_uv,
    sp1.order_num
from (
    select
        dt,
        coalesce(md.value2,'全部') as pt,
        sum(fp0.first_uv) as first_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            dt,
            app_name,
            approx_distinct(case when nav_flag=1 then union_id end) as first_uv,
            approx_distinct(case when nav_flag=2 then union_id end) as detail_uv,
            approx_distinct(case when nav_flag=4 then union_id end) as order_uv
        from (
            select
                partition_date as dt,
                app_name,
                page_identifier,
                union_id
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date='\$\$today{-1d}'
                and partition_log_channel='movie'
                and partition_app in (
                'movie',
                'dianping_nova',
                'other_app',
                'dp_m',
                'group'
                )
                and page_identifier in (
                select value
                from upload_table.myshow_pv
                where key='page_identifier'
                and page_tag1>=0
                )
            ) as fpw
            left join (
                $mp
                and page_tag1>=0
                ) mp
            on mp.value=fpw.page_identifier
        group by
            dt,
            app_name
        ) as fp0
        left join (
            $md
            and key_name='app_name'
            ) md
        on fp0.app_name=md.key
    group by
        dt,
        value2
    ) as fp1
    left join (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num
    from (
        select
            spo.dt,
            spo.sellchannel,
            count(distinct spo.order_id) as order_num
        from
            (
            $spo
            ) spo
        group by
            spo.dt,
            spo.sellchannel
        ) as sp0
        left join
        (
        $md
        and key_name='sellchannel'
        ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
