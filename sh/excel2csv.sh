#!/bin/bash
#Description: csv excel 格式转换
tmp="$HOME/Documents/tmp.xlsx"

cp $1 $tmp
python ${CODE_HOME}py/excel2csv.py $tmp $2 $3
rm $tmp
