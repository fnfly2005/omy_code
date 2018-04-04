
select
    ii.item_id,
    ii.item_no,
    ii.title_cn,
    ii.city_id,
    ii.type_id,
    it.type_lv1_name,
    it.type_lv2_name,
    ii.venue_id,
    ven.venue_name,
    ven.venue_type,
    cit.city_name,
    cit.province_id,
    pro.province_name
from (
    select id as item_id, item_no, title_cn, type_id, venue_id, city_id from item_info
    ) ii
    left join (
    SELECT it1.id as type_id, case when it2.id is null then it1.name else it2.name end as type_lv1_name, it1.name as type_lv2_name FROM item_type it1 left JOIN item_type it2 ON it1.pid=it2.id
    ) it
    on ii.type_id=it.type_id
    left join (
    select id as venue_id, name as venue_name, venue_type from venue
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
