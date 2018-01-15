#!/usr/bin/python
#coding:utf-8
# python一元回归分析
import numpy as np  
import math  
import pandas as pd

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

# 从csv文件中读取数据，分别为：X列表和对应的Y列表
def get_data(file_name):
    # 1. 用pandas读取csv
    data = pd.read_csv(file_name)
    for (p1,s1),group in data.groupby(['performance_id','show_id']):
       # 2. 构造X列表和Y列表
        X_parameter = []
        Y_parameter = []
        for single_dd,single_on in zip(group['date_diff'],group['order_num']):
            X_parameter.append([float(single_dd)])
            Y_parameter.append(float(single_on))
        print p1,s1,"r",computeCorrelation(X_parameter,Y_parameter)  
        print p1,s1,"r2",str(computeCorrelation(X_parameter,Y_parameter)**2)  

#输出的是简单线性回归的皮尔逊相关度和R平方值  
get_data('~/Documents/my_code/data/pytest.csv')
