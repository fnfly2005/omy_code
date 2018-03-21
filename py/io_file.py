#!/usr/bin/python
#coding:utf-8
#csv数据输入输出
import csv
def io_file (source_file,target_file):
    with open(source_file, 'rb') as sf,open(target_file,'wb') as tf:
    #打开输入文件SF，输出文件TF
        reader=csv.reader(sf,delimiter=',',quoting=csv.QUOTE_NONE)
        #读取SF,形成数组变量
        writer=csv.writer(tf, delimiter=',',quoting=csv.QUOTE_MINIMAL)
        #读取TF,形成数组变量
        for row in reader:
            writer.writerow(row)
        #在SF数组中循环，写入TF数组并存入文件
io_file ('/Users/fannian/Documents/data/pytest.csv','/Users/fannian/Documents/test.csv')
