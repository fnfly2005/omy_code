select
    order_id,
    customer_id,
    bill_id,
    expressfee
from
    (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) spo
    left join
    (
    select project_id, insteaddelivery from mart_movie.dim_myshow_project
    and insteaddelivery=1
    ) dp
    using(project_id)
;