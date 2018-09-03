#!/bin/bash
#营销手机号提取
source ./fuc.sh
file="bs27"
lim=";"
attach="${path}doc/${file}.sql"
#source_table in ('upload_table.send_wdh_user','upload_table.send_fn_user','mart_movie.detail_myshow_msuser')
#filter_table in ('upload_table.black_list_fn','upload_table.wdh_upload')
#out_type in (' ',',batch_code')
echo "
select
    so.mobile
    \$out_type
from (
    select
        mobile,
        batch_code,
        row_number() over (partition by mobile order by 1) as rank
    from \$source_table
    where 
        sendtag in ('\$sendtag')
        and batch_code in (\$batch_code)
    ) as so
    left join (
        select
            mobile
        from \$filter_table
        ) bl
    on bl.mobile=so.mobile
where
    bl.mobile is null
    and rank=1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
