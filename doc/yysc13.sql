
select
    fp1.dt,
    fp1.uv_source,
    all_uv,
    detail_uv,
    order_num,
    ticket_num,
    totalprice,
    grossprofit
from (
    select
        dt,
        uv_source,
        approx_distinct(union_id) as all_uv,
        approx_distinct(
            case when page_identifier in (
                'c_Q7wY4',
                'packages/show/pages/detail/index',
                'pages/show/detail/index'
                ) then union_id end) as detail_uv
    from (
        select
            partition_date as dt,
            case when page_identifier in ('c_Q7wY4','c_oEWlZ') then custom['fromTag']
            else utm_source end as uv_source,
            page_identifier,
            union_id
        from mart_flow.detail_flow_pv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
        and page_identifier in (
            'c_Q7wY4',
            'c_oEWlZ',
            'pages/show/detail/index',
            'packages/show/pages/detail/index',
            'pages/show/index/index',
            'packages/show/pages/index/index'
            )
        ) fpw
    where
        uv_source is not null
        and uv_source<>'0'
        and (uv_source in ('$sou')
            or 'all' in ('$sou')
            )
    group by
        1,2
    ) fp1
    left join (
        select
            fmw.dt,
            uv_source,
            count(distinct fmw.order_id) order_num,
            sum(ticket_num) as ticket_num,
            sum(totalprice) as totalprice,
            sum(grossprofit) as grossprofit
        from (
            select
                partition_date as dt,
                case when event_id in ('b_XZfmh','b_WLx9n') 
                    then custom['fromTag']
                else utm_source end as uv_source,
                order_id
            from mart_movie.detail_flow_mv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
            and event_id in (
                'b_XZfmh',
                'b_WLx9n',
                'b_w047f3uw'
                ) 
            ) fmw
            join (
                select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                and sellchannel not in (9,10,11)
                ) spo
            on spo.order_id=fmw.order_id
            and spo.dt=fmw.dt
            and uv_source is not null
            and uv_source<>'0'
            and (uv_source in ('$sou')
                or 'all' in ('$sou')
                )
        group by
            1,2
        ) as sp1
        on fp1.dt=sp1.dt
        and fp1.uv_source=sp1.uv_source
;
