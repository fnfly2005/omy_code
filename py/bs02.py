#!/usr/bin/python
#coding:utf-8
#csv数据文件去重
#参数1 源文件 参数2 目标文件

import csv
import pandas as pd
import sys

def io_file (source_file,target_file):
    with open(source_file,'rb') as sf,open(target_file,'wb') as tf:
    #打开输出文件TF
        writer=csv.writer(tf, delimiter=',',quoting=csv.QUOTE_MINIMAL)
        #读取TF,形成数组变量
        data = pd.read_csv(source_file,header=None)
        #pandas.read_csv读取csv文件并转化为DataFrame
        data=data.drop_duplicates()
        #去重
        data.to_csv(tf,sep=',',header=False,index=False)
        #输出到CSV

sa=sys.argv[1]
#获取命令行参数1
ta=sys.argv[2]
#获取命令行参数2

io_file (sa,ta)
