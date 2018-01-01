# Test Case & Known Bugs
Known Bugs are ordered by priority.  
## Test Case
- [first test case - walker_yf][1] **Passing**  
- [second test case - yanb25][2] **Passing**  


### testcase4
测出问题：保留站busy位在有指令流入保留站的时候，没有在对应的busy位里写入1
    (从而导致写寄存器状态表的保留站号有误)
问题来源:
    1. 保留站根据当前的CDB（准确的说是上一周期的CDB信号）的label，将对应的保留站的busy清零，表示该保留站的指令计算的数据已写入，指令可释放
    2. 保留站BCEN信号来源于pmfALU，设计的问题，导致运行一条指令的时候，BCEN信号会有两个周期有效
结果：
    1. 两个周期有效，那就会在下一个周期的之后的两个上升沿都会进行更新CDB，**给busy清零**的操作，这里两次清零就会出问题（刚好下一条指令就要放到对应的位置呢？)
修改：修改了pmfalu的状态转移方式，本来处于完成状态的alu有机会直接去到执行1阶段，现在强制先回到idle状态

[1]:/rom/testcase1.md
[2]:/rom/testcase2.md

## Known Bugs
### Critical
- ~~pmfALU~~ (fixed)   
pmfALU does not correctly deal with substraction
- ~~Reservation~~ (fixed)  
Reservation does not recognise `halt` and keeps getting instructions.
- ~~Reservation~~（fixed)  
当数据没有流动时（即没有新指入站和（或）没有指令发射时），保留站无法根据广播更新指令的数据。
- error in issue
所有的器件的“流出”时序错误。一个器件不能在“下游器件接受请求”就马上把busy清零，而应等到CDB将该指令的执行结果广播完毕后再清零。  
与寄存器换名问题相关。  
- PC & PCHelper
halt doesn't work
### Warning 
- ReservationStation  
没有在清零信号到来时，将所有的Qk,Qj,Vk,Vj等寄存器清零

### Coding Style
- Reservation Label
由于0保留站号是不可用的。由于某些历史原因，所有保留站号的高两位+1以暂时解决冲突。  
正确的冲突解决方法应该改写头文件，并让各个器件的保留站号“天然”地从正确的序号开始。  
暂时不会带来Warning或更严重的报错。  