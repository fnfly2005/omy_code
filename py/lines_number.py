#!/usr/bin/python
#coding:utf-8
#csv数据文件计数
import sys
def ln_file (source_file):
    with open(source_file,'rb') as sf:
    #打开输出文件TF
        lines=sf.readlines()
        #读取文件并存入行数组

        print len(lines)

sa=sys.argv[1]
#获取命令行参数1

ln_file (sa)
