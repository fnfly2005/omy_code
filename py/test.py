#!/usr/bin/python
#coding:utf-8
import csv
with open('/Users/fannian/Documents/bs10.csv', 'wb') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=',',quoting=csv.QUOTE_MINIMAL)
    spamwriter.writerow(['performance_id', 'show_id', 'date_diff','order_num'])
    spamwriter.writerow(['performance_id', 'show_id', 'date_diff','order_num'])
