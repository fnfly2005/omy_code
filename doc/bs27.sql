
select
    mobile 
from upload_table.send_fn_user
where
    sendtag in ('$sendtag') 
    and batch_code in ($batch_code)
    and send_performance_id in ($send_performance_id)
union all
select
    mobile 
from upload_table.send_wdh_user
where
    sendtag in ('$sendtag') 
    and batch_code in ($batch_code)
    and send_performance_id in ($send_performance_id)
;
