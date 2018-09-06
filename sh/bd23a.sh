#!/bin/bash
#选人-演出-user_id
source ./fuc.sh

bel=`fun sql/dim_myshow_userlabel.sql u`
ity=`fun sql/dim_myshow_city.sql u`

file="bd23"
lim=";"
attach="${path}doc/${file}.sql"
<<'COMMENT'
\$province_id
select distinct 
    province_id as id,
    province_name as name
from movie_mis.dim_myshow_city
\$city_id
select city_id as id,
city_name as name
from movie_mis.dim_myshow_city
where dp_flag=0
\$category_id
-99 全选
1 演唱会
2 体育赛事
3 戏曲艺术
4 话剧歌剧
5 舞蹈芭蕾
6 音乐会
7 亲子演出
8 其他
9 休闲展览
\$sellchannel
1 点评
2 美团
5 猫眼
8 格瓦拉
COMMENT
echo "
select distinct
    user_id
from (
    select
        user_id,
        category_flag
    $bel
        and city_id in (
            select
                city_id
            $ity
                and ((province_id in (\$province_id) and 1=\$pro)
                    or (city_id in (\$city_id) and 2=\$pro)
                    or 0=\$pro)
            )
        and sellchannel in (\$sellchannel)
    ) as bel
    CROSS JOIN UNNEST(category_flag) as t (category_id)
where
    category_id in (\$category_id)
    or -99 in (\$category_id)
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
