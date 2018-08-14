/*演出线下分销*/
select
    totalprice,
    ticket_num,
    sale_id,
    takerate
from
    upload_table.sale_offline
where
    dt>='$$begindate'
    and dt<'$$enddate'
