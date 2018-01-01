# Test Case & Known Bugs
Known Bugs are ordered by priority.  
## Test Case
[first test case][1]

[1]:/rom/rom.mem
## Known Bugs
### Critical
- ~~pmfALU~~ (fixed)   
pmfALU does not correctly deal with substraction
- ~~Reservation~~ (fixed)  
Reservation does not recognise `halt` and keeps getting instructions.
### Warning 
- ReservationStation  
没有在清零信号到来时，将所有的Qk,Qj,Vk,Vj等寄存器清零

### Coding Style
- Reservation Label
由于0保留站号是不可用的。由于某些历史原因，所有保留站号的高两位+1以暂时解决冲突。  
正确的冲突解决方法应该改写头文件，并让各个器件的保留站号“天然”地从正确的序号开始。  
暂时不会带来Warning或更严重的报错。  