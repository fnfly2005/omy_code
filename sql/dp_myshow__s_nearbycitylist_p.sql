/*附近城市行转列-presto*/
select 
    cityid as dp_city_id,
    near_city_id as ner_city_id,
    tag as dis_tag
from (
    SELECT 
        cityid,
        near_city_id,
        tag,
        row_number() over (partition by cityid,near_city_id order by tag) rank
    from (
        select 
            cityid,
            near_city_id,
            100 as tag
        from 
            origindb.dp_myshow__s_nearbycitylist
            CROSS JOIN UNNEST(split(regexp_extract(nearbycityidsin100km,'[0-9,]+'),',')) AS t (near_city_id)
        union ALL 
        SELECT 
            cityid,
            near_city_id,
            200 as tag
        from 
            origindb.dp_myshow__s_nearbycitylist
            CROSS JOIN UNNEST(split(regexp_extract(nearbycityidsin200km,'[0-9,]+'),',')) AS t (near_city_id)
        union ALL 
        SELECT 
            cityid,
            near_city_id,
            500 as tag
        from 
            origindb.dp_myshow__s_nearbycitylist
            CROSS JOIN UNNEST(split(regexp_extract(nearbycityidsin500km,'[0-9,]+'),',')) AS t (near_city_id)
        ) mic
    ) mir
where 
    rank=1
