#!/usr/bin/python
#coding:utf-8
##################################
'''
Path: 
Description: csv excel 格式转换
Date: 2018-09-25
Version: v1.0
'''
##################################
import sys
import pandas as pd

try:
    in_file = sys.argv[1]
    out_file = sys.argv[2]
    def excel2csv():
        data_xls = pd.read_excel(in_file, index_col=0)
        data_xls.to_csv(out_file, encoding = 'utf-8')
    if __name__ == '__main__':
        excel2csv()
except:
    print "请在文件所在路径下执行，且文件路径无中文名，输入参数：参数1-输入文件，参数2-输出文件"
