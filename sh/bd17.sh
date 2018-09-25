#!/bin/bash
#非营销手机号提取
source ./fuc.sh

mp=`fun dp_myshow__s_messagepush.sql uD`
ser=`fun dim_myshow_movieuser.sql ud`
era=`fun dim_myshow_movieusera.sql ud`
rid=`fun sql/myshowupload_user_id.sql`
file=`echo $0 | sed "s/[a-z]*\.sh//g;s/.*\///g"`
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct 
    mobile
from ( 
    select
        phonenumber as mobile    
    $mp
        performanceid in (\$id)
        and 5 in (\$urc)
    union all
    select
        mobile 
    from (
        $rid
            and 8 in (\$urc)
        ) rid
        left join (
            select
                user_id,
                mobile
            $ser
            union all
            select
                user_id,
                mobile
            $era
            ) sra
        on rid.user_id=sra.user_id
    where
        sra.mobile is not null
    ) as ile
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
