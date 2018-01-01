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