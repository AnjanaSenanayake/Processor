# Processor
An implementation of a processor with basic components coded in verilog
A simple 8-bit single cycle processor using Verilog HDL, which includes an ALU, a register file and other control component.

instruction are hardcoded in the regInstructions module itself
operations     op-code
  loadi/mov       000
  add/sub         001
  and             010
  or              011
The prototypical instructions will be as follows:

add 4, 2, 1 (add value in register 1 to value in register 2, and place the result in register 4)
sub 4, 2, 1 (subtract value in register 1 from the value in register 2, and place the result in register 4)
and 4, 2, 1 (perform bit-wise AND on values in registers 1 and 2, and place the result in register 4)
or 4, 2, 1 (perform bit-wise OR on values in registers 1 and 2, and place the result in register 4)
mov 4, X, 1 (copy the value in register 1 to register 4. Ignore SOURCE 2)
loadi 4, X, 0xFF (load the immediate value 0xFF to register 4. Ignore SOURCE 2)

structure of a 32 bit instruction is below
 _____________________________________________________________
| OP-CODE      | DESTINATION   | SOURCE 2     | SOURCE 1       |
|              |               |              |                |
|(bits 31-24)  |(bits 23-16)   | (bits 15-8)  | (bits 7-0)     |
---------------------------------------------------------------

Part 1 - ALU
The heart of every computer is an Arithmetic Logic Unit (ALU). This is the part of the computer which performs arithmetic and logic operations on numbers, e.g. addition, subtraction, etc. In this part you will use the Verilog language to implement an ALU which can perform four different functions to support the six instructions specified above.

There should be two 8-bit input operands (DATA1 and DATA2), one 8-bit output (RESULT) and one control input (SELECT) which should be used to pick the required function inside the ALU out of the available five functions, based on the instruction's OP-CODE.
The 3-bit SELECT signal is derived from the three least Significant bits of the OP-CODE.

eg:- When OP-CODE is "00000000", SELECT should be "000"
When OP-CODE is "00000011", SELECT should be "011"

signal and register names as below

[7:0] DATA1
[7:0] DATA2
[7:0] RESULT
[2:0] SELECT

FORWARD functional unit should simply copy an operand value from DATA1 to RESULT. This unit will be used by the loadi and mov instructions to place the required source operand in the specified destination register.

ADD, AND and OR functional units will use the data in DATA1 and DATA2 registers and write the output to the RESULT register. (When completing the processor in part 3, you should provide the ALU with two's complement values of SOURCE 1 and SOURCE to correctly to implement both add and sub instructions using only the ADD functional unit).

Part 2 - Register File
Next you should implement a simple register file. The purpose of the register file is to store RESULT values coming from the ALU, and to supply the ALU with operands (for DATA1 and DATA2 inputs) for register-type instructions (in our case, add, sub, and and or).
Your register file should be able to store eight 8-bit values. It should contain one 8-bit input port (IN) and two 8-bit output ports (OUT1 and OUT2). To specify which register you are reading/writing with a given port, you must include address signals (INaddr, OUT1addr, OUT2addr). You may include separate control input signal(s) to change the read/write mode of the register file. Feel free to use additional control signals as appropriate.

The following module definition gives a template interface for your register file:
module reg_file(IN,OUT1,OUT2,clk,RESET,INaddr,OUT1addr,OUT2addr)
Signals IN, OUT1 and OUT2 represent the single data input and dual data outputs respectively. INaddr , OUT1addr , and OUT2addr are the register numbers for storing input IN data and for retrieving OUT1 and OUT2 data, respectively. A falling edge on clk causes the data input on IN to be written to the input register specified by the INaddr. At the rising edge of the clock, registers identified by OUT1addr and OUT2addr are read from OUT1 and OUT2 respectively.

Part 3 - Control
Now you should connect the ALU and register file you made. To do this, you will need to implement some control logic.
You need an instruction fetching mechanism with an instruction register and a PC (program counter) register which points to the next instruction. Since we do not have a memory yet, you can hardcode the instructions in your testbench file, and let your processor fetch instructions from there on every falling edge.
You need logic to decode a fetched instruction, extract the OP-CODE, source/destination registers and immediate values. Depending on the OP-CODE, control signals should be generated and sent to the register file and ALU appropriately. For arithmetic instructions (add and sub) you must perform two's complement on the operands before supplying them to the ALU. You will need to use MUXs to achieve the desired control.

harcoded instructions
  
loadi 4, X, 0xFF
loadi 6,X,0xAA
loadi 3,X,0xBB
add 5,6,3
and 1,4,5
or 2,1,6
mov 7,x,2
sub 4,7,3

final ans is 52....overflow is ignored.
