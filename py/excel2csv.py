#!/usr/bin/python
#coding:utf-8
##################################
'''
Path: 
Description: csv excel 格式转换
Date: 2018-09-28
Version: v2.0
'''
##################################
import sys
import pandas as pd

try:
    in_file = sys.argv[1]
    out_file = sys.argv[2]
    try:
        index = int(sys.argv[3])
    except:
        index = 0
    def excel2csv():
        data_xls = pd.read_excel(in_file, sheet_name = index,index_col = 0)
        data_xls.to_csv(out_file, encoding = 'utf-8')
    if __name__ == '__main__':
        excel2csv()
except:
    print "输入参数有误"
