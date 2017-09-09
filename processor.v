/***************************************************************************************
*    Title: Processor with basic components in verilog
*    Author: Anjana Senanayake
*    Date: 27/08/2017  
*    Code version: v1.0
*    Availability: https://github.com/AnjanaSenanayake/Processor
*
***************************************************************************************/

module testbench;

reg clk;
reg reset;
wire [7:0] result,OUT1,OUT2,Data2,mux1out,immediate,mux2out;
wire [2:0] Select;

initial
	 $monitor("Res=%b O1=%b O2=%b D2=%b mux1=%b imm=%b mux2=%b S=%b clk=%b R=%b",result,OUT1,OUT2,Data2,mux1out,immediate,mux2out,Select,clk,reset);

proccessor myproccessor(result,OUT1,OUT2,Data2,mux1out,immediate,mux2out,Select,clk,reset);

initial
begin
	clk=1'b1;
	reset=0;
end

always #5 clk=~clk;

initial
begin
	#80 $finish;
end
endmodule

///////////////////////////////////////////////////////////////////////////////////////////////
module alu(out,Data1,Data2,Select);
input [7:0] Data1,Data2;
input [2:0] Select;
output reg [7:0] out;

always@(Data1,Data2,Select)
begin
case(Select)
3'b000:out<=Data1;
3'b001:out<=Data1+Data2;
3'b010:out<=Data1&Data2;
3'b011:out<=Data1|Data2;
endcase
end
endmodule

module regfile8x8a(OUT1,OUT2,clk,INaddr,OUT1addr,OUT2addr,IN);

input clk;
input [7:0] IN;
output [7:0] OUT1,OUT2;
input [2:0] INaddr,OUT1addr,OUT2addr;
reg [7:0] reg0, reg1, reg2, reg3,reg4,reg5,reg6,reg7;

assign OUT1 = (OUT1addr==3'b000)?reg0:
(OUT1addr==3'b001)?reg1:
(OUT1addr==3'b010)?reg2:
(OUT1addr==3'b011)?reg3:
(OUT1addr==3'b100)?reg4:
(OUT1addr==3'b101)?reg5:
(OUT1addr==3'b110)?reg6:
(OUT1addr==3'b111)?reg7:0;
// add until 8 //
assign OUT2 = OUT2addr == 0 ? reg0 :
OUT2addr == 1 ? reg1 :
OUT2addr == 2 ? reg2 :
OUT2addr == 3 ? reg3 :
OUT2addr == 4 ? reg4 :
OUT2addr == 5 ? reg5 :
OUT2addr == 6 ? reg6 :
OUT2addr == 7 ? reg7 :0;
//add until 8//
always @(negedge clk) 
begin
case(INaddr)
3'b000:reg0=IN;
3'b001:reg1=IN;
3'b010:reg2=IN;
3'b011:reg3=IN;
3'b100:reg4=IN;
3'b101:reg5=IN;
3'b110:reg6=IN;
3'b111:reg7=IN;
// your code here
endcase
end // always @ (negedgeclk)
endmodule

module CU(OUT1addr,OUT2addr,INaddr,immediate,Select,imm_signal,comp_signal,instruction);

input [31:0] instruction;
output reg [7:0] immediate;
output reg imm_signal;
output reg [2:0] Select;
output reg [2:0] OUT1addr;
output reg [2:0] OUT2addr;
output reg [2:0] INaddr;
output reg comp_signal;
always @(instruction) 
begin
	immediate = instruction[7:0];
	//opcode=instruction[31:24];
	Select = instruction[26:24];
	INaddr = instruction[18:16];
	OUT2addr = instruction[2:0];
	OUT1addr = instruction[10:8];
	imm_signal = 1'b0;
	comp_signal = 1'b0;
	case (instruction[31:24])
		8'b00001000:
			imm_signal = 1'b1;
		8'b00001001:						
			comp_signal = 1'b1;
		default:;
	endcase
end
endmodule

module mux(out,select,input1,input2);

input select,clk;
input [7:0] input1,input2;
output reg [7:0] out;
always @* begin
	if (select==1) 
		out = input1;
	else 
		out = input2;
end

endmodule

module compliment(out,in);
input [7:0] in;
output [7:0] out;
reg [7:0] comp=8'b11111111;
assign out=(comp-in)+8'b00000001;
endmodule

module regInstructions(instruction,clk,Read_Addr);
input clk;
input [2:0] Read_Addr;
output reg [31:0] instruction;

reg [31:0] addr1 = 32'b00001000000001000000000011111111;		// loadi 4, X, 0xFF
reg [31:0] addr2 = 32'b00001000000001100000000010101010;		// loadi 6, X, 0xAA
reg [31:0] addr3 = 32'b00001000000000110000000010111011;		// loadi 3, X, 0xBB
reg [31:0] addr4 = 32'b00000001000001010000011000000011;		// add   5, 6, 3
reg [31:0] addr5 = 32'b00000010000000010000010000000101;		// and   1, 4, 5
reg [31:0] addr6 = 32'b00000011000000100000000100000110;		// or    2, 1, 6 
reg [31:0] addr7 = 32'b00000000000001110000000000000010;		// mov   7, x, 2
reg [31:0] addr8 = 32'b00001001000001000000011100000011;		// sub   4, 7, 3

always @(negedge clk) 
begin
	case (Read_Addr)
		3'd0:instruction = addr1;
		3'd1:instruction = addr2;
		3'd2:instruction = addr3;
		3'd3:instruction = addr4;
		3'd4:instruction = addr5;
		3'd5:instruction = addr6;
		3'd6:instruction = addr7;
		3'd7:instruction = addr8;
		default :;
	endcase
end
endmodule

module counter (Read_addr,clk,reset);
input clk;
input reset;
output reg [2:0] Read_addr=0;
always @(negedge clk)
if(!reset) 
begin
	Read_addr<=Read_addr+3'd001;
end
else 
begin
	Read_addr<=0;	
end
endmodule

module proccessor(result,OUT1,OUT2,Data2,mux1out,immediate,mux2out,Select,clk,reset);
input reset;
input clk;
output [2:0] Select;
wire [2:0] Read_addr;
wire [31:0] instruction;
wire [2:0] OUT1addr,OUT2addr,INaddr;
output [7:0] immediate,OUT2,Data2,mux1out,result,OUT1,mux2out;
wire comp_signal,imm_signal;

counter mycounter(Read_addr,clk,reset);
regInstructions myreg(instruction,clk,Read_addr);
CU mycu(OUT1addr,OUT2addr,INaddr,immediate,Select,imm_signal,comp_signal,instruction);
regfile8x8a myregister(OUT1,OUT2,clk,INaddr,OUT1addr,OUT2addr,result);
compliment mycomp(Data2,OUT2);
mux mux1(mux1out,comp_signal,Data2,OUT2);
mux mux2(mux2out,imm_signal,immediate,mux1out);
alu myalu(result,mux2out,OUT1,Select);
regfile8x8a myregister1(OUT1,OUT2,clk,INaddr,OUT1addr,OUT2addr,result);
endmodule
