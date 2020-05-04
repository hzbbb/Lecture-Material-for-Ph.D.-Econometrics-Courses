clear

cd "D:\Dropbox\Dropbox\My documents\Rochester\博五下\TA for ECO 485\Second half\Machine Learning Recitation"

set seed 100
set obs 20

gen x=runiform(-100,100)

set obs 30
replace x=rnormal(50,30) if x==.

gen x_2=x*x
gen x_3=x*x*x
gen x_4=x*x*x*x
gen x_5=x*x*x*x*x
gen x_6=x_5*x
gen x_7=x_6*x
gen x_8=x_7*x
gen x_9=x_8*x
gen x_10=x_9*x
gen x_11=x_10*x
gen x_12=x_11*x
gen x_13=x_12*x
gen x_14=x_13*x
gen x_15=x_14*x
gen x_16=x_15*x
gen x_17=x_16*x
gen x_18=x_17*x
gen x_19=x_18*x
gen x_20=x_19*x
gen e=rnormal(0,100)
gen y=1+1.5*x+e

graph twoway scatter y x

 
reg y x
predict yhat_1
graph twoway sc y x || line yhat_1 x, sort || function y=1+1.5*x, range(-100 100)
graph export o1.png,replace

reg y x x_2
predict yhat_2
graph twoway sc y x||connected yhat_2 x, sort || function y=1+1.5*x, range(-100 100)
graph export o2.png,replace

reg y x x_2 x_3
predict yhat_3
graph twoway sc y x||connected yhat_3 x, sort || function y=1+1.5*x, range(-100 100)
graph export o3.png,replace

reg y x x_2 x_3 x_4
predict yhat_4
graph twoway sc y x||connected yhat_4 x, sort || function y=1+1.5*x, range(-100 100)
graph export o4.png,replace

reg y x x_2 x_3 x_4 x_5
predict yhat_5
graph twoway sc y x||connected yhat_5 x, sort || function y=1+1.5*x, range(-100 100)
graph export o5.png,replace

reg y x x_2 x_3 x_4 x_5 x_6
predict yhat_6
graph twoway sc y x||connected yhat_6 x, sort || function y=1+1.5*x, range(-100 100)
graph export o6.png,replace

reg y x x_2 x_3 x_4 x_5 x_6 x_7
predict yhat_7
graph twoway sc y x||connected yhat_7 x, sort || function y=1+1.5*x, range(-100 100)
graph export o7.png,replace

reg y x x_2 x_3 x_4 x_5 x_6 x_7 x_8
predict yhat_8
graph twoway sc y x||connected yhat_8 x, sort || function y=1+1.5*x, range(-100 100)
graph export o8.png,replace

reg y x x_2 x_3 x_4 x_5 x_6 x_7 x_8 x_9
predict yhat_9
graph twoway sc y x||connected yhat_9 x, sort || function y=1+1.5*x, range(-100 100)
graph export o9.png,replace

reg y x x_2 x_3 x_4 x_5 x_6 x_7 x_8
predict yhat_10
graph twoway sc y x||connected yhat_10 x, sort || function y=1+1.5*x, range(-100 100)
graph export o10.png,replace

reg y x x_2 x_3 x_4 x_5 x_6 x_7 x_8 x_9 x_10 x_11 x_12 x_13 x_14 x_15 x_16 x_17 x_18 x_19 x_20
predict yhat_20,xb
graph twoway sc y x||connected yhat_20 x, sort || function y=1+1.5*x, range(-100 100)
graph export o20.png,replace






