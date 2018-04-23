/*优惠券周期快照表*/
select
    mba.partition_date as dt,
    mba.batch_id,
    (mba.issuedcount-mbb.issuedcount) as sued_num
from
    mart_movie.detail_myshow_batch mba
    left join mart_movie.detail_myshow_batch mbb
    on mba.partition_date=substr(
    date_add('day',-1,date_parse(mbb.partition_date,'%Y-%m-%d')),
    1,10)
    and mba.batch_id=mbb.batch_id
where
    mba.partition_date>='$$begindate'
    and mba.partition_date<'$$enddate'
    and mbb.partition_date>='$$begindate{-1d}'
    and mbb.partition_date<'$$enddate{-1d}'
