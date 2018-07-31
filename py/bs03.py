# -*- coding: UTF-8 -*-
#!/Users/fannian/anaconda2/bin/python
import jieba
import sys

reload(sys)
sys.setdefaultencoding('utf8') #设置python默认编码为utf8

pat="/Users/fannian/Documents/data/"


with open(pat+sys.argv[1]) as c1, open(pat+sys.argv[2],'w') as c2:
#参数1为输入文件c1，参数2为输出文件c2
    for cws in c1:
        c=cws.encode('utf-8').split(',',2)#切分2次
        result=jieba.cut(c[1])#取第二个切片，精准分词
        l=0
        for r in result:
            if r!='\n' and r!=' ':
                c2.write(c[0]+","+r+","+str(l)+'\n')
                l+=1
