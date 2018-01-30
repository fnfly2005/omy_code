
select
    dt,
    case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
    when regexp_like(url,'fromTag%3D') then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
    when regexp_like(url,'from=') then split_part(regexp_extract(url,'from=[^&]+'),'=',2)
    else 'other'
    end as fromtag,
    count(distinct union_id) as uv
from
    (
    select partition_date as dt, url_parameters, substr(url,40,40) as url, page_name, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2' and partition_log_channel='firework' and partition_app in ( select key from upload_table.myshow_dictionary where key_name='partition_app' ) and page_bg='猫眼文化'
    and regexp_like(page_name,'')
    ) as pw
group by
    1,2
;
