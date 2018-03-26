/*团单项目维表*/
select
    category,
    deal_id,
    bizacctid,
    title,
    cityids
from
    mart_movie.dim_deal_new
where
    dealstatus='"online"' 
    and endtime>concat(from_unixtime(unix_timestamp()-86400,'"yyyy-MM-dd' ),' 00:00:00"')  
    and category = 12
