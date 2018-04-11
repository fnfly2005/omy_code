
select
    '$$today{-1d}' as d,
    count(distinct bs.mobile) as wg_num,
    count(distinct so.mobile) as my_num,
    count(distinct case when bs.mobile is not null 
        then so.mobile end) as cr_num,
    count(distinct case when so.dt='$$today{-1d}' 
        then so.mobile end) as myn_num,
    count(distinct case when bs.mobile is not null 
                        and so.dt='$$today{-1d}'
                    then so.mobile end) as ncr_num
from (
    select distinct
        mobile
    from (
        select
            mobile
        from upload_table.detail_wg_outstockrecords
        where
            mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        union all
        select
             order_mobile as mobile
        from upload_table.detail_wg_saleorder
        union all
        select
            mobile
        from upload_table.detail_wg_salereminders
        where
            mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        union all
        select
            mobile
        from upload_table.dim_wg_users
        where
            mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        ) as su
    ) as bs
    full join (
        select
            mobile,
            min(dt) dt
        from (
            select
                 usermobileno as mobile,
                 min(substr(order_create_time,1,10)) as dt
            from mart_movie.detail_myshow_saleorder
            group by
                1
            union all
            select
                 phonenumber as mobile,
                 min(substr(createtime,1,10)) as dt
            from origindb.dp_myshow__s_messagepush
            group by
                1
            ) s1
        group by
            1
        ) as so
    on bs.mobile=so.mobile
group by
    1
;
