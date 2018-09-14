#!/usr/bin/python
#coding:utf-8
##################################
'''
Path: scripts/get_citykey.py
Description: 获取城市名称的关键词（删除行政区划）
Date: 2018-09-13
Version: v1.0
'''
##################################

import sys
dic1=['自治县','自治旗','自治州','市','县','盟','地区','区']
dic2=['各族','壮族','回族','满族','维吾尔族','苗族','彝族','土家族','藏族','蒙古族','侗族','布依族','瑶族','白族','朝鲜族','哈尼族','黎族','哈萨克族','傣族','畲族','傈僳族','仡佬族','拉祜族','佤族','水族','纳西族','羌族','土族','仫佬族','锡伯族','柯尔克孜族','景颇族','达斡尔族','撒拉族','布朗族','毛南族','塔吉克族','普米族','阿昌族','怒族','鄂温克族','京族','基诺族','德昂族','保安族','俄罗斯族','裕固族','乌孜别克族','门巴族','鄂伦春族','独龙族','赫哲族','高山族','珞巴族','塔塔尔族','东乡族']

try:
    p1=sys.argv[1]
except:
    p1=8
#获取城市名称列位置参数
try:
    p2=sys.argv[2]
except:
    p2=-1
#获取城市id列位置参数

#从右开始替换字符
def rreplace(self, old, new, *max):
    count = len(self)
    if max and str(max[0]).isdigit():
        count = max[0]
    return new.join(self.rsplit(old, count))

def workflow(key_loc,id_loc):
    for line in sys.stdin:
        line_srp = line.strip()
        city_name = line_srp.split("\t")[int(key_loc)-1]
        if id_loc == -1:
            line_pri = line_srp
            #返回全表+关键词
        else:
            line_pri = line_srp.split("\t")[int(id_loc)-1]
            #返回关系表
        
        if len(city_name) != 6 and city_name != '东乡族自治县':
            city_check = city_name
            for dit in dic2:
                city_name = city_name.replace(dit,'')
                #替换行政区划的民族前缀
            for dit in dic1:
                city_name = rreplace(city_name,dit,'',1)
                #替换行政区划
                if city_name != city_check:
                    break
        print line_pri + "\t" + city_name

if __name__ == '__main__':
    workflow(p1,p2)
