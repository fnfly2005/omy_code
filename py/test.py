#!/usr/bin/python
#coding:utf-8
#csv数据文件去重
def io_file (source_file):
    with open(source_file,'rb') as sf:
    #打开输出文件TF
        lines=sf.readlines()
        #读取文件并存入行数组

        print len(lines)


io_file ('/Users/fannian/Documents/data/pytest.csv')
