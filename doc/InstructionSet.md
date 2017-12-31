# Instruction Set
## R-Format
|op(6)|rs(5)|rt(5)|rd(5)|rev(5)|func(6)|
|-|-|-|-|-|-|

|Instruction|Function Code|
|:--:|:--:|
|add|100000|
|sub|100011|
|and|100100|
|or|100101|

## I-Fromat
|op(6)|rs(5)|rt(5)|immd(16)|
|-|-|-|-|-|-|

|Instruction|Operation Code|
|:--:|:--:|
|slti|010001|
|addi|001000|
|ori|001101|
|sw|101011|
|lw|100011|

## J-Format
|op(6)|immd(26)|
|-|-|-|-|-|-|

|Instruction|Operation Code|
|:--:|:--:|
|halt|111111|
`halt` is the only instruction that is supported in this pj by now.