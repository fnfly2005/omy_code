
select 
    page_identifier,
	event_id,
    custom,
    utm_source,
    locate_city_id,
    page_city_id,
    geo_city_id,
	event_category,
	event_type,
	order_id
from (
    select
        page_identifier,
        event_id,
        custom,
        utm_source,
        locate_city_id,
        page_city_id,
        geo_city_id,
        event_category,
        event_type,
        order_id,
        row_number() over (partition by event_id order by 1) as rank
    from (
        select distinct
            page_identifier,
            event_id,
            custom,
            utm_source,
            locate_city_id,
            page_city_id,
            geo_city_id,
            event_category,
            event_type,
            order_id
        from (
            select
                page_identifier,
                event_id,
                event_category,
                event_type,
                order_id,
                page_city_id,
                geo_city_id,
                custom,
                utm_source,
                locate_city_id,
                row_number() over (partition by case when 'PV' in ('PV') 
                    then page_identifier else event_id end order by 1) as rak
            from mart_flow.detail_flow_all_report_hourly where partition_date='$$today{-0d}' and partition_log_channel='movie' and log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
                and partition_hour>=15
                and (
                    (partition_nm in ('PV')
                    and (page_identifier in (
                            select
                                identifier
                            from 
                                upload_table.myshow_identifier_ver
                            where
                                0=1
                            )
                        or page_identifier in ('pages/show/index/index','pages/show/detail/index'))
                        )
                    or 
                    (partition_nm in ('PV')
                    and (event_id in (
                        select
                            identifier
                        from 
                            upload_table.myshow_identifier_ver
                        where
                            0=1
                        )
                        or event_id in ('pages/show/index/index','pages/show/detail/index'))
                        )
                    )
            ) as fw
        where
            rak<=1000
        ) as rk
    ) as ran
where
    rank<=50
;
