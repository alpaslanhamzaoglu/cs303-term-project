`timescale 1ns / 1ps

module  tel_tb_2();

// I-O port names
reg clk;
reg rst;
reg startCall,answerCall;
reg endCallCaller,endCallCallee;
reg sendCharCaller,sendCharCallee;
reg [7:0] charSent;
wire[63:0] statusMsg;
wire[63:0] sentMsg;

// 100 MHz clock
always #5 clk = ~clk;

initial begin
	// initialize every input to 0
	clk = 0;
	rst = 0;
	startCall = 0;
	answerCall = 0;
	endCallCaller = 0;
	endCallCallee = 0;
	sendCharCaller = 0;
	sendCharCallee = 0;
	charSent = " ";

	// Xilinx global reset time
	#100;

	// reset your circuit
	rst=1; #20; rst=0; #20; rst=0;              // reset

	startCall=1; #10; startCall=0;              // caller starts call
	#30;                                        // statusMsg displaying "RINGING "
	answerCall=1; #10; answerCall=0;            // callee answer call
	#20;                                        // statusMsg displaying "CALLER  "

	sendCharCaller=1; charSent="W"; #10; sendCharCaller=0; #10; // caller sends "W", sentMsg displaying "       W", cost is 2
	sendCharCaller=1; charSent="h"; #10; sendCharCaller=0; #10; // caller sends "h", sentMsg displaying "      Wh", cost is 4
	sendCharCaller=1; charSent=135; #10; sendCharCaller=0; #10; // caller sends (invalid char), no change on sentMsg and cost
    #20;                                                        // caller sends nothing for 2 clock cycles
    endCallCallee=1; #10; endCallCallee=0;                      // callee ends the call
	#150;                                                       // statusMsg displaying "COST    ", sentMsg displaying "00000004"

    startCall=1; #10; startCall=0;                              // caller starts call
	#30;                                                        // statusMsg displaying "RINGING "
	answerCall=1; #10; answerCall=0;                            // callee answer call
	#20;                                                        // statusMsg displaying "CALLER  "
	sendCharCaller=1; charSent="W"; #10; sendCharCaller=0; #10; // caller sends "W", sentMsg displaying "       W", cost is 2
	sendCharCaller=1; charSent="h"; #10; sendCharCaller=0; #10; // caller sends "h", sentMsg displaying "      Wh", cost is 4
	sendCharCaller=1; charSent="o"; #10; sendCharCaller=0; #10; // caller sends "o", sentMsg displaying "     Who", cost is 6
	sendCharCaller=1; charSent=" "; #10; sendCharCaller=0; #10; // caller sends " ", sentMsg displaying "    Who ", cost is 8
	sendCharCaller=1; charSent="i"; #10; sendCharCaller=0; #10; // caller sends "i", sentMsg displaying "   Who i", cost is 10
	sendCharCaller=1; charSent="s"; #10; sendCharCaller=0; #10; // caller sends "s", sentMsg displaying "  Who is", cost is 12
	#20;                                                        // caller sends nothing for 2 clock cycles
	sendCharCaller=1; charSent=" "; #10; sendCharCaller=0; #10; // caller sends " ", sentMsg displaying " Who is ", cost is 14
	sendCharCaller=1; charSent="t"; #10; sendCharCaller=0; #10; // caller sends "t", sentMsg displaying "Who is t", cost is 16
	sendCharCaller=1; charSent="h"; #10; sendCharCaller=0; #10; // caller sends "h", sentMsg displaying "ho is th", cost is 18
	sendCharCaller=1; charSent="i"; #10; sendCharCaller=0; #10; // caller sends "i", sentMsg displaying "o is thi", cost is 20
	sendCharCaller=1; charSent="s"; #10; sendCharCaller=0; #10; // caller sends "s", sentMsg displaying " is this", cost is 22
	sendCharCaller=1; charSent="?"; #10; sendCharCaller=0; #10; // caller sends "?", sentMsg displaying "is this?", cost is 24
	#10;
	#10;
	sendCharCaller=1; charSent=127; #10; sendCharCaller=0; #10; // caller sends DEL to change turn, cost is 26
	#10;                                                        // statusMsg displaying "CALLEE  "
	#10;
	sendCharCallee=1; charSent="Y"; #10; sendCharCallee=0; #10; // callee sends "Y", sentMsg displaying "       Y", cost is 28
	sendCharCallee=1; charSent="o"; #10; sendCharCallee=0; #10; // callee sends "o", sentMsg displaying "      Yo", cost is 30
	sendCharCallee=1; charSent="u"; #10; sendCharCallee=0; #10; // callee sends "u", sentMsg displaying "     You", cost is 32
	sendCharCallee=1; charSent="r"; #10; sendCharCallee=0; #10; // callee sends "r", sentMsg displaying "    Your", cost is 34
	sendCharCallee=1; charSent=" "; #10; sendCharCallee=0; #10; // callee sends " ", sentMsg displaying "   Your ", cost is 36
	sendCharCallee=1; charSent=  8; #10; sendCharCallee=0; #10; // callee sends invalid char
    #10;                                                        // callee sends nothing for 1 clock cycle
	sendCharCallee=1; charSent=178; #10; sendCharCallee=0; #10; // callee sends invalid char
	sendCharCallee=1; charSent="T"; #10; sendCharCallee=0; #10; // callee sends "T", sentMsg displaying "  Your T", cost is 38
	sendCharCallee=1; charSent="A"; #10; sendCharCallee=0; #10; // callee sends "A", sentMsg displaying " Your TA", cost is 40
	sendCharCallee=1; charSent="."; #10; sendCharCallee=0; #10; // callee sends ".", sentMsg displaying "Your TA.", cost is 42
	#10;
    sendCharCallee=1; charSent=127; #10; sendCharCallee=0; #10; // callee sends DEL to change turn, cost is 44
	#10;
    #10;
    sendCharCaller=1; charSent="O"; #10; sendCharCaller=0; #10; // caller sends "O", sentMsg displaying "       O", cost is 46
	sendCharCaller=1; charSent="K"; #10; sendCharCaller=0; #10; // caller sends "K", sentMsg displaying "      OK", cost is 48
	sendCharCaller=1; charSent="."; #10; sendCharCaller=0; #10; // caller sends ".", sentMsg displaying "     OK.", cost is 50
    #10;
	endCallCaller=1; #10; endCallCaller=0; #10;                 // caller ends the call
	#50;	                                                    // statusMsg displaying "COST    ", sentMsg displaying "00000032"
end

// module instantiation
tel uut   (clk,
           rst,
		   startCall,answerCall,
		   endCallCaller,endCallCallee,
		   sendCharCaller,sendCharCallee,
		   charSent,
		   statusMsg,
		   sentMsg);

endmodule
