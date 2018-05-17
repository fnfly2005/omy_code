
select
    ii.item_id,
    ii.item_name,
    ii.item_no,
    ii.city_id,
    ii.type_id,
    it.type_lv1_name,
    it.type_lv2_name,
    ii.venue_id,
    ven.venue_name,
    ven.venue_type,
    cit.city_name,
    cit.province_id,
    pro.province_name,
    row_number() over (order by ii.item_id) item_nu
from (
    select id as item_id, item_no, replace(title_cn,',',' ') as item_name, type_id, venue_id, city_id from item_info
    ) ii
    left join (
    SELECT it1.id as type_id, case when it2.id is null then it1.name else it2.name end as type_lv1_name, it1.name as type_lv2_name FROM item_type it1 left JOIN item_type it2 ON it1.pid=it2.id where it1.name not like '%测试%'
    ) it
    on ii.type_id=it.type_id
    left join (
    select id as venue_id, replace(name,',',' ') as venue_name, venue_type from venue
    ) ven
    on ven.venue_id=ii.venue_id
    left join (
    select city_id, city_name, province_id from city
    ) cit
    on cit.city_id=ii.city_id
    left join (
    select province_id, province_name from province where province_name is not null
    ) pro
    on pro.province_id=cit.province_id
;
