#!/usr/bin/python
#coding:utf-8
#csv数据文件去重

import csv
import pandas as pd
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

io_file ('/Users/fannian/Documents/data/register_mobile.csv','/Users/fannian/Documents/register_mobile.csv')
