#!/usr/bin/python
#coding:utf-8
# python一元回归分析
import numpy as np  
import math  
import pandas as pd
import csv

#求解皮尔逊相关系数  
def computeCorrelation(X, Y):  
    xBar = np.mean(X)  
    yBar = np.mean(Y)  
    SSR = 0  
    varX = 0  
    varY = 0  
    for i in range(0, len(X)):  
        #对应分子部分  
        diffXXBar = X[i] - xBar  
        diffYYBar = Y[i] - yBar  
        SSR +=(diffXXBar * diffYYBar)  
        #对应分母求和部分  
        varX += diffXXBar**2  
        varY += diffYYBar**2  
    SST = math.sqrt(varX * varY)  
    return SSR/SST  

def polyfit(x, y, degree):  
    results = {}  
    #coeffs 为相关系数，x自变量，y因变量，degree为最高幂  
    coeffs = np.polyfit(x, y, degree)  

    #定义一个字典存放值，值为相关系数list  
    results['polynomial'] = coeffs.tolist()  

    #p相当于直线方程  
    p = np.poly1d(coeffs)    
    yhat = p(x)  #传入x，计算预测值为yhat  

    ybar = np.sum(y)/len(y)  #计算均值      
    #对应公式  
    ssreg = np.sum((yhat - ybar) ** 2)  
    sstot = np.sum((y - ybar) ** 2)  
    results['determination'] = ssreg / sstot  

    print" results :",results  
    return results  

def get_data(file_name):

    # 用open创建csv输出文件
    with open('/Users/fannian/Documents/bs10.csv', 'wb') as csvfile:
        #用CSV设置写入格式
        spamwriter = csv.writer(csvfile, delimiter=',',quoting=csv.QUOTE_MINIMAL)
        #写入表头
        spamwriter.writerow(['performance_id', 'show_id', 'r','r2'])

        # 用pandas读取csv输入文件
        data = pd.read_csv(file_name)

        # 用pandas按date_diff order_num进行分组迭代计算performance_id,show_id
        for (p1,s1),group in data.groupby(['performance_id','show_id']):
            # 4. 构造X列表和Y列表
            X_parameter = []
            Y_parameter = []
            for single_dd,single_on in zip(group['date_diff'],group['order_num']):
                X_parameter.append([float(single_dd)])
                Y_parameter.append(float(single_on))
            #输出的是简单线性回归的皮尔逊相关度和R平方值  
            spamwriter.writerow([p1, s1,computeCorrelation(X_parameter,Y_parameter),str(computeCorrelation(X_parameter,Y_parameter)**2)])

#导入文件并执行
get_data('~/Documents/data/bs10.csv')
