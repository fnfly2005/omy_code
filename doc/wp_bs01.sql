
select
   dt,
   item_id,
   user_id
from (
    select
        from_unixtime(create_time,'%Y-%m-%d') dt,
        item_id,
        user_id
    from
        item_attentions
    union all
    select
        from_unixtime(create_time,'%Y-%m-%d') dt,
        item_id,
        user_id
    from
        item_attention
    ) as iat
group by
    1,2,3
;
