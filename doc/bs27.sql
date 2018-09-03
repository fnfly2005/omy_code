
select
    so.mobile
    $out_type
from (
    select
        mobile,
        batch_code,
        row_number() over (partition by mobile order by 1) as rank
    from $source_table
    where 
        sendtag in ('$sendtag')
        and batch_code in ($batch_code)
    ) as so
    left join (
        select
            mobile
        from $filter_table
        ) bl
    on bl.mobile=so.mobile
where
    bl.mobile is null
    and rank=1
;
