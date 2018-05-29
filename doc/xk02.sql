
select
    partition_date as dt,
    '平台页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=0
        )
group by
    1,2
union all                
select
    partition_date as dt,
    '演出频道页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=1
        )
group by
    1,2
union all                
select
    partition_date as dt,
    '演出详情页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=2
        )
group by
    1,2
union all                
select
    partition_date as dt,
    '确认订单页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='$$begindate'
    and partition_date<'$$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=4
        )
group by
    1,2
union all
select
    spo.dt,
    '订单' as type,
    count(distinct spo.order_id) as uv
from (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    and sellchannel=8
    ) spo
group by
    1,2
;
