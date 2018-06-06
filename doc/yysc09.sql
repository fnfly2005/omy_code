
select
    fromTag,
    case when 1 in ($dim) then dt
    else '全部' end as dt,
    pt,
    source_id,
    avg(uv) as uv,
    sum(totalprice) as totalprice,
    sum(order_num) order_num,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit
from (
    select
        case when md1.value2 is not null then md1.value2
        when fpw.fromTag=0 then '其他'
        when fpw.fromTag is null then '其他'
        else fpw.fromTag end fromTag,
        fpw.dt,
        fpw.pt,
        case when fpw.source_id=-99 then '全部'
        else fpw.source_id end as source_id,
        sum(uv) uv,
        sum(totalprice) as totalprice,
        sum(order_num) order_num,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            fromTag,
            dt,
            value2 as pt,
            source_id,
            sum(uv) as uv
        from (
            select
                fromTag,
                dt,
                app_name,
                performance_id as source_id,
                uv
            from (
                select
                    case when page_identifier='c_Q7wY4' 
                        then custom['fromTag']
                    else utm_source
                    end as fromTag,
                    partition_date as dt,
                    case when 2 in ($dim) then app_name
                    else 'all' end as app_name,
                    case when -99 in ($pid) then -99
                    when page_identifier<>'pages/show/detail/index'
                        then custom['performance_id']
                    else custom['id'] end as performance_id,
                    approx_distinct(union_id) as uv
                from 
                    mart_flow.detail_flow_pv_wide_report
                where partition_date>='$$begindate'
                    and partition_date<'$$enddate'
                    and partition_log_channel='movie'
                    and partition_app in (
                        'movie',
                        'dianping_nova',
                        'other_app',
                        'dp_m',
                        'group'
                        )
                    and page_identifier in (
                        'c_Q7wY4',
                        'pages/show/detail/index'
                        )
                    and $source=1
                    and app_name<>'gewara'
                group by
                    1,2,3,4
                ) mv
            where (
                performance_id in ($pid)
                or -99 in ($pid)
                )
            union all
            select
                case when regexp_like(url_parameters,'fromTag=') 
                    then split_part(regexp_extract(url_parameters,'fromTag=[^&]+'),'=',2)
                when regexp_like(url,'fromTag=') 
                    then split_part(regexp_extract(url,'fromTag=[^&]+',2),'=',2)
                when regexp_like(url,'fromTag%3D') 
                    then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
                else 'other'
                end as fromTag,
                partition_date as dt,
                'all' as app_name,
                $id as source_id,
                approx_distinct(union_id) as uv
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date>='$$begindate'
                and partition_date<'$$enddate'
                and (
                    (
                        partition_log_channel='firework'
                        and $source=3
                        )
                    or (
                        partition_log_channel='cube'
                        and $source=2
                        )
                    )
                and partition_app in (
                    'movie',
                    'dianping_nova',
                    'other_app',
                    'dp_m',
                    'group'
                    )
                and regexp_like(page_name,'$id')
            group by
                1,2,3,4
            ) as fp
            left join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
                and key_name='app_name'
                ) md
            on fp.app_name=md.key
        group by
            1,2,3,4
        ) fpw
        left join (
            select
                fromTag,
                dt,
                value2 as pt,
                source_id,
                sum(totalprice) as totalprice,
                sum(order_num) order_num,
                sum(ticket_num) as ticket_num,
                sum(grossprofit) as grossprofit
            from (
                select
                    fromTag,
                    dt,
                    case when $source=1 and 2 in ($dim) then sellchannel
                    else -99 end as sellchannel,
                    case when $source=1 then performance_id
                    else $id end as source_id,
                    sum(totalprice) as totalprice,
                    count(distinct fp2.order_id) as order_num,
                    sum(ticket_num) as ticket_num,
                    sum(grossprofit) as grossprofit
                from (
                    select distinct
                        case when event_id='b_WLx9n' then custom['fromTag']
                        else utm_source
                        end as fromTag,
                        order_id
                    from
                        mart_flow.detail_flow_mv_wide_report
                    where partition_date>='$$begindate'
                        and partition_date<'$$enddate'
                        and partition_log_channel='movie'
                        and partition_etl_source='2_5x'
                        and partition_app in (
                            'movie',
                            'dianping_nova',
                            'other_app',
                            'dp_m',
                            'group'
                            )
                        and event_id in ('b_WLx9n','b_w047f3uw')
                    ) as fp2
                    join (
                        select
                            partition_date as dt,
                            sellchannel,
                            case when -99 in ($pid) then -99
                            else performance_id end as performance_id,
                            order_id,
                            totalprice,
                            (salesplan_count*setnumber) as ticket_num,
                            grossprofit
                        from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                            and sellchannel in (1,2,3,5,6,7,13)
                            and (
                                performance_id in ($pid)
                                or -99 in ($pid)
                                )
                        ) spo
                    on fp2.order_id=spo.order_id
                group by
                    1,2,3,4
                ) as sdo
                left join (
                    select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
                    and key_name='sellchannel'
                    ) md3
                on md3.key=sdo.sellchannel 
            group by
                1,2,3,4
            ) as sp
        on sp.fromTag=fpw.fromTag
        and sp.dt=fpw.dt
        and sp.pt=fpw.pt
        and sp.source_id=fpw.source_id
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='fromTag'
            ) md1
        on fpw.fromTag=md1.key
    group by
        1,2,3,4
    ) as yy
group by
    1,2,3,4
;
