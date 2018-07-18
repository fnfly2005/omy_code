
select 
    page_identifier,
	event_id,
    custom,
    utm_source,
    $custom_id,
    page_city_id,
	event_category,
	event_type,
	event_attribute,
	order_id
from (
    select
        page_identifier,
        event_id,
        custom,
        utm_source,
        $custom_id,
        page_city_id,
        event_category,
        event_type,
        event_attribute,
        order_id,
        row_number() over (partition by event_id order by 1) as rank
    from (
        select distinct
            page_identifier,
            event_id,
            custom,
            utm_source,
            $custom_id,
            page_city_id,
            event_category,
            event_type,
            event_attribute,
            order_id
        from (
            select
                page_identifier,
                page_identifier as event_id,
                'all' as event_category,
                'all' as event_type,
                custom as event_attribute,
                'all' as order_id,
                page_city_id,
                custom,
                utm_source,
                $custom_id,
                row_number() over (partition by page_identifier order by 1) as rak
            from mart_flow.detail_flow_pv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
                and $type=1
                and (
                    page_identifier in (
                        select
                            identifier
                        from 
                            upload_table.myshow_identifier_ver
                        where
                            $mod=1
                        )
                    or page_identifier in ('$identifier')
                    )
            union all
            select
                'all' page_identifier,
                event_id,
                event_category,
                event_type,
                event_attribute,
                order_id,
                page_city_id,
                custom,
                utm_source,
                $custom_id,
                row_number() over (partition by event_id order by 1) as rak
            from mart_movie.detail_flow_mv_wide_report where partition_date>='$$begindate' and partition_date<'$$enddate' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
                and $type=2
                and (
                    event_id in (
                        select
                            identifier
                        from 
                            upload_table.myshow_identifier_ver
                        where
                            $mod=1
                        )
                    or event_id in ('$identifier')
                    )
            ) as fw
        where
            rak<=1000
        ) as rk
    ) as ran
where
    rank<=$limit
;