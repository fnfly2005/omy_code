/*微格场馆维表*/
select
    id as venue_id,
    replace(name,',',' ') as venue_name,
    venue_type
from
    venue
