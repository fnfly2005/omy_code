select
    my.dt,
    my.firstpage_uv my,
    dp.firstpage_uv dp,
    wxycss.firstpage_uv wxycss,
    mt.firstpage_uv mt,
    wxchwl.firstpage_uv wxchwl
from
    (
    select dt, firpage_uv as firstpage_uv from aggr_movie_dau_client_core_page_daily where dt>='$time1' and dt<'$time2'
    ) my
    left join
    (
    select dt, firstpage_uv from aggr_movie_dianping_app_conversion_daily where dt>='$time1' and dt<'$time2'
    ) dp
    on my.dt=dp.dt
    left join
    (
    select dt, firstpage_uv from aggr_movie_maoyan_weixin_daily where dt>='$time1' and dt<'$time2'
    ) wxycss
    on my.dt=wxycss.dt
    left join
    (
    select dt, firstpage_uv from aggr_movie_meituan_app_conversion_daily where dt>='$time1' and dt<'$time2'
    ) mt
    on my.dt=mt.dt
    left join
    (
    select dt, firstpage_uv from aggr_movie_weixin_app_conversion_daily where dt>='$time1' and dt<'$time2'
    ) wxchwl
    on my.dt=wxchwl.dt
;
