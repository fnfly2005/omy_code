#--------------------猫眼演出readme-------------------
#*************************api3.0*******************
#1.0优化输出方式,函数处理;2.0新增实时模版;3.0优化函数功能
#4.0函数模块化
#!/bin/bash
this="${BASH_SOURCE-$0}"
path=$(dirname -- "$this")"/"
fun() {
    if [[ ${1} =~ \. ]];then
        fil=${1}
    else
        fil="${1}.sql"
    fi
    if [[ ${1} =~ / ]];then
        pdir="${path}"
    else
        pdir="${path}sql/"
    fi
    tmp=`cat ${pdir}${fil} | grep -iv "/\*"`
    if [ -n $2 ];then
        if [[ $2 =~ d ]];then
            tmp=`echo $tmp | sed 's/where.*//'`
        fi
        if [[ $2 =~ D ]];then
            tmp=`echo $tmp | sed 's/where.*/where /'`
        fi
        if [[ $2 =~ u ]];then
            tmp=`echo $tmp | sed 's/.*from/from/'`
        fi
        if [[ $2 =~ t ]];then
            tmp=`echo $tmp | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
        fi
        if [[ $2 =~ m ]];then
            tmp=`echo $tmp | sed "s/begindate/monthfirst{-1m}/g;s/enddate/monthfirst/g"`
        fi
        if [[ $2 =~ s ]];then
            tmp=`echo $tmp | sed "s/-time1/$3/g;s/-time2/$4/g"`
        fi
    fi
    echo $tmp
}
