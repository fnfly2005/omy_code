/*项目类目表*/
SELECT
    it1.id as type_id,
    case when it2.id is null then it1.name 
    else it2.name end as type_lv1_name,
    it1.name as type_lv2_name
FROM
    item_type it1
    left JOIN item_type it2 
    ON it1.pid=it2.id
where
    it1.name not like '%测试%'
