
select distinct
    so.mobile
    $out_type
from (
    select
        mobile,
        batch_code
    from upload_table.send_fn_user
    where
        sendtag in ('$sendtag') 
        and batch_code in ($batch_code)
        and 1 in ($upload_date)
    union all
    select
        mobile,
        batch_code
    from upload_table.send_wdh_user
    where
        sendtag in ('$sendtag') 
        and batch_code in ($batch_code)
        and 1 in ($upload_date)
    union all
    select
        mobile,
        batch_code
    from mart_movie.detail_myshow_msuser
    where 
        sendtag in ('$sendtag')
        and batch_code in ($batch_code)
        and 2 in ($upload_date)
    ) as so
    left join (
        select
            mobile
        from
            upload_table.black_list_fn
        where
            $fit_flag=1
        union all
        select
            mobile
        from
            upload_table.wdh_upload
        where
            $fit_flag=2
        ) bl
    on bl.mobile=so.mobile
where
    bl.mobile is null
;
