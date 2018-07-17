#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == ex ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

file="bs27"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    so.mobile
    \$out_type
from (
    select
        mobile,
        batch_code
    from upload_table.send_fn_user
    where
        sendtag in ('\$sendtag') 
        and batch_code in (\$batch_code)
        and 1 in (\$upload_date)
    union all
    select
        mobile,
        batch_code
    from upload_table.send_wdh_user
    where
        sendtag in ('\$sendtag') 
        and batch_code in (\$batch_code)
        and 1 in (\$upload_date)
    union all
    select
        mobile,
        batch_code
    from mart_movie.detail_myshow_msuser
    where 
        sendtag in ('\$sendtag')
        and batch_code in (\$batch_code)
        and 2 in (\$upload_date)
    ) as so
    left join (
        select
            mobile
        from
            upload_table.black_list_fn
        where
            \$fit_flag=1
        union all
        select
            mobile
        from
            upload_table.wdh_upload
        where
            \$fit_flag=2
        ) bl
    on bl.mobile=so.mobile
where
    bl.mobile is null
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
