/*新美大流量宽表*/
select
    partition_date,
    custom,
    union_id
from
    mart_flow.detail_flow_pv_wide_report
where
    partition_date>='$time1'
    and partition_date<'$time2'
    and partition_log_channel='movie'
    and partition_app in ('movie',
    'dianping_nova',
    'other_app',
    'dp_m',
    'group')
    and page_identifier in ('pages/show/index/index',
    'pages/show/search/index',
    'pages/show/list/index',
    'pages/show/detail/index',
    'pages/show/ticket/ticket',
    'pages/show/order/confirm',
    'pages/show/seats/area',
    'pages/show/seats/seats',
    'pages/show/user/index',
    'pages/show/order/index',
    'pages/show/mooc/invoice',
    'c_73h2xggs',
    'c_dqihv0si',
    'c_zn3lm8i0',
    'c_oEWlZ',
    'c_6yPP8',
    'c_Q7wY4',
    'c_8UWcP',
    'c_EIA9h',
    'c_l1Ub4')
