
select
    item_name,
    city_name,
    venue_name,
    type_lv1_name,
    type_lv2_name,
    dt
from (
    select id as item_id, item_no, replace(title_cn,',',' ') as item_name, type_id, venue_id, city_id, substr(show_time,1,10) as dt from item_info where title_cn not like '%废%' and title_cn not like '%测试%' AND title_cn NOT LIKE '%调试%' AND title_cn NOT LIKE '%勿动%' AND title_cn NOT LIKE '%test%' AND title_cn NOT LIKE '%ceshi%'
    ) ii
    left join (
        select id as venue_id, replace(name,',',' ') as venue_name, venue_type from venue
        ) ve
    on ii.venue_id=ve.venue_id
    left join (
       SELECT it1.id as type_id, case when it2.id is null then it1.name else it2.name end as type_lv1_name, it1.name as type_lv2_name FROM item_type it1 left JOIN item_type it2 ON it1.pid=it2.id where it1.name not like '%测试%'
       ) it
       on it.type_id=ii.type_id
    left join (
        select city_id, city_name, province_id from city
        ) ci
        on ci.city_id=ii.city_id
;
