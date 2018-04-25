
select
    '$$today{-1d}' as dt,
    count(distinct mobile) as all_num,
    count(distinct case when dmi is not null then mobile end) as yc_num,
    count(distinct case when dma is not null then mobile end) as my_num,
    count(distinct case when dmi='$$today{-1d}' then mobile end) as n_num,
    count(distinct case when dma='$$today{-1d}' then mobile end) as t_num
from (
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.detail_wg_outstockrecords
    where
        mobile is not null 
        and length(mobile)=11 
        and substr(cast(mobile as varchar),1,2)>='13' 
    union all
    select
        order_mobile as mobile,
        case when length(pay_no)>0 then 'wg' 
        else NUll end as dmi,
        NUll as dma
    from upload_table.detail_wg_saleorder
    union all
    select
        mobile,
        case when length(pay_no)>4 then 'wp' 
        else NUll end as dmi,
        NUll as dma
    from upload_table.detail_wp_saleorder
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.detail_wg_salereminders
    where
        mobile is not null 
        and length(mobile)=11 
        and substr(cast(mobile as varchar),1,2)>='13' 
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.dim_wg_users
    where
        mobile is not null 
        and length(mobile)=11 
        and substr(cast(mobile as varchar),1,2)>='13' 
    union all
    select
        phonenumber as mobile,
        NUll as dmi,
        NUll as dma
    from origindb.dp_myshow__s_messagepush
    union all
    select
        usermobileno as mobile,
        min(substr(pay_time,1,10)) as dmi,
        max(substr(pay_time,1,10)) as dma
    from mart_movie.detail_myshow_saleorder
    group by
        1
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.dim_wp_user
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from mart_movie.dim_gp_user
    ) as so
group by
    1
;
