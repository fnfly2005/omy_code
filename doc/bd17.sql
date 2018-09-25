
select distinct 
    mobile
from ( 
    select
        phonenumber as mobile    
    from origindb.dp_myshow__s_messagepush where
        performanceid in ($id)
        and 5 in ($urc)
    union all
    select
        mobile 
    from (
        select user_id from upload_table.myshowupload_user_id where 1=1
            and 8 in ($urc)
        ) rid
        left join (
            select
                user_id,
                mobile
            from mart_movie.dim_myshow_movieuser
            union all
            select
                user_id,
                mobile
            from mart_movie.dim_myshow_movieusera
            ) sra
        on rid.user_id=sra.user_id
    where
        sra.mobile is not null
    ) as ile
;
