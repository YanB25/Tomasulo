# Test Case & Known Bugs
Known Bugs are ordered by priority.  
## Test Case
- [first test case - walker_yf][1] **Passing**  
- [second test case - yanb25][2] **Passing**  
- [third test case - walker_yf][3] **Passing**
- [forth test case - walker_yf][4] **Passing**
- [fifth test case - yanb25][5] **Passing**
- [sixth test case - walker_yf][6] **Passing**


[1]:/rom/testcase1.md
[2]:/rom/testcase2.md
[3]:/rom/testcase3.md
[4]:/rom/testcase4.md
[5]:/rom/testcase5.md
[6]:/rom/testcase6.md

## Known Bugs
### Critical
- ~~pmfALU~~ (fixed)   
pmfALU does not correctly deal with substraction
- ~~Reservation~~ (fixed)  
Reservation does not recognise `halt` and keeps getting instructions.
- ~~Reservation~~（fixed)  
当数据没有流动时（即没有新指入站和（或）没有指令发射时），保留站无法根据广播更新指令的数据。
- ~~error in issue~~(fixed)
所有的器件的“流出”时序错误。一个器件不能在“下游器件接受请求”就马上把busy清零，而应等到CDB将该指令的执行结果广播完毕后再清零。  
与寄存器换名问题相关。  
- ~~PC & PCHelper~~(fix)  
halt doesn't work
### Warning 
- ReservationStation  
没有在清零信号到来时，将所有的Qk,Qj,Vk,Vj等寄存器清零

### Coding Style
- Reservation Label
由于0保留站号是不可用的。由于某些历史原因，所有保留站号的高两位+1以暂时解决冲突。  
正确的冲突解决方法应该改写头文件，并让各个器件的保留站号“天然”地从正确的序号开始。  
暂时不会带来Warning或更严重的报错。  
- isLastState
使用了不优美的isLastState信号来同步Queue和RAM之间的工作。  
isLastState不是最后一个阶段，而是倒数第二个阶段。  
本质原因是缺少流水的段寄存器。  
- ResStationDst
在op为sw和lw时，将ResStationDst设为`2'b11`会出错，导致halt指令无法被识别。故在top模块采用了变通的方法。