/*微格场馆维表*/
select
    id as venue_id,
    replace(name,',',' ') as shop_name,
    venue_type
from
    venue
where
    name not like '%测试%'
    and name not like '%test%'
    and name not like '%废%'
    and name<>'ceshi'
