/*埋点字典表*/
select
    nav_flag,
    value
from
    upload_table.myshow_pv
where
    key='page_identifier'
