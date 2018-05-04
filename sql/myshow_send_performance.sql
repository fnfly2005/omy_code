/*猫眼演出项目营销短信过滤状态表*/
select
    sendtag 
from
    upload_table.myshow_send_performance_fn
where
    send_flag='0'
