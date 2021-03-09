`timescale 1ns / 1ps

module tel(clk, rst, startCall, answerCall, endCallCaller, endCallCallee, sendCharCaller, sendCharCallee, charSent, statusMsg, sentMsg);

	input clk, rst, startCall, answerCall, endCallCaller, endCallCallee, sendCharCaller, sendCharCallee;
	input[7:0] charSent;

	output reg[63:0] statusMsg;
	output reg[63:0] sentMsg;

	reg[31:0] cost;
	reg[5:0] current_state;
	reg[5:0] next_state;
	reg[3:0] count;

	parameter[5:0] S0 = 6'b000000;
	parameter[5:0] S1 = 6'b000001;
	parameter[5:0] S2 = 6'b000010;
	parameter[5:0] S3 = 6'b000011;
	parameter[5:0] S4 = 6'b000100;
	parameter[5:0] S5 = 6'b000101;

	// state transition
	always @(posedge clk or posedge rst)
	begin
	if (rst)  current_state <= S0;
	else     current_state <= next_state;
	end

	// combinational part
	always @(*)
	begin
	case(current_state)
	S0: //initial state - IDLE
	begin
		if (startCall)  next_state = S1;
		else 			   next_state = S0;
	end

	S1 : //ringing state
	begin
		if (endCallCallee)       next_state = S4;
		else if (endCallCaller)  next_state = S0;
		else if (count == 9)      next_state = S0;
		else if (answerCall)      next_state = S2;
		else 							 next_state = current_state;
	end

	S2 : //caller
	begin
		if (endCallCaller)  		 next_state = S5;
		else if (endCallCallee)	 next_state = S5;
		else if (charSent == 127 & sendCharCaller) next_state = S3;
		else 							 next_state = current_state;
	end

	S3 : //callee
	begin
		if (endCallCallee)       next_state = S5;
		else if (endCallCaller)  next_state = S5;
		else if (charSent == 127 & sendCharCallee) next_state = S2;
		else 							 next_state = current_state;
	end

	S4 : // rejected - callee ended
	begin
		if (count == 9) next_state = S0;
		else 				next_state = current_state;
	end

	S5 : // cost
	begin
		if (count == 4) next_state = S0;
		else 				next_state = current_state;
	end
	default: next_state = S0;
	endcase
	end

		// counter
		always @(posedge clk or posedge rst)
		begin
		if (rst) count <= 0;
		else if (startCall) count <= 0;
		else if (count == 10) count <= 0;
		else if (!endCallCaller & !endCallCallee & !answerCall)	count <= count + 1;
		else count <= 0;
	end

		// sequential part - output
		always @(posedge clk or posedge rst)
		begin
		if (rst)
			begin
					statusMsg[7:0] <= {8{8'd32}};
					statusMsg[15:8] <= {8{8'd32}};
					statusMsg[23:16] <= {8{8'd32}};
					statusMsg[31:24] <= {8{8'd32}};
					statusMsg[39:32] <= {8{8'd69}};
					statusMsg[47:40] <= {8{8'd76}};
					statusMsg[55:48] <= {8{8'd68}};
					statusMsg[63:56] <= {8{8'd73}};
					
					sentMsg[7:0] <= 32;
					sentMsg[15:8] <= 32;
					sentMsg[23:16] <= 32;
					sentMsg[31:24] <= 32;
					sentMsg[39:32] <= 32;
					sentMsg[47:40] <= 32;
					sentMsg[55:48] <= 32;
					sentMsg[63:56] <= 32;
			end
		else
			begin
			case(current_state)
			S0:
				begin
					// "IDLE    "
					statusMsg[7:0] <= {8{8'd32}};
					statusMsg[15:8] <= {8{8'd32}};
					statusMsg[23:16] <= {8{8'd32}};
					statusMsg[31:24] <= {8{8'd32}};
					statusMsg[39:32] <= {8{8'd69}};
					statusMsg[47:40] <= {8{8'd76}};
					statusMsg[55:48] <= {8{8'd68}};
					statusMsg[63:56] <= {8{8'd73}};
					cost <= 0;

					sentMsg[7:0] <= 32;
					sentMsg[15:8] <= 32;
					sentMsg[23:16] <= 32;
					sentMsg[31:24] <= 32;
					sentMsg[39:32] <= 32;
					sentMsg[47:40] <= 32;
					sentMsg[55:48] <= 32;
					sentMsg[63:56] <= 32;
				end
					S1 :
				begin
					// "RINGING "
					statusMsg[7:0] <= {8{8'd32}};
					statusMsg[15:8] <= {8{8'd71}};
					statusMsg[23:16] <= {8{8'd78}};
					statusMsg[31:24] <= {8{8'd73}};
					statusMsg[39:32] <= {8{8'd71}};
					statusMsg[47:40] <= {8{8'd78}}; 
					statusMsg[55:48] <= {8{8'd73}};
					statusMsg[63:56] <= {8{8'd82}};
					end
					S2 :
				begin
					// "CALLER  "
					statusMsg[7:0] <= {8{8'd32}};
					statusMsg[15:8] <= {8{8'd32}};
					statusMsg[23:16] <= {8{8'd82}};
					statusMsg[31:24] <= {8{8'd69}};
					statusMsg[39:32] <= {8{8'd76}};
					statusMsg[47:40] <= {8{8'd76}};
					statusMsg[55:48] <= {8{8'd65}};
					statusMsg[63:56] <= {8{8'd67}};
					if (rst)
						begin
						sentMsg <= {8{8'd32}};
						cost <= 0;
				end
					else
						begin
						if (charSent > 47 & charSent < 58 & (sendCharCallee | sendCharCaller)) cost <= cost + 1;
						else if (charSent > 31 & charSent < 128 & (sendCharCallee | sendCharCaller)) cost <= cost + 2;
				if (sendCharCaller & (charSent >= 32 & charSent <= 126))
					begin
					sentMsg[7:0] <= charSent;
				sentMsg[15:8] <= sentMsg[7:0];
				sentMsg[23:16] <= sentMsg[15:8];
				sentMsg[31:24] <= sentMsg[23:16];
				sentMsg[39:32] <= sentMsg[31:24];
				sentMsg[47:40] <= sentMsg[39:32];
				sentMsg[55:48] <= sentMsg[47:40];
				sentMsg[63:56] <= sentMsg[55:48];
				end
				else if (charSent == 127)
				begin
					sentMsg[7:0] <= 32;
					sentMsg[15:8] <= 32;
					sentMsg[23:16] <= 32;
					sentMsg[31:24] <= 32;
					sentMsg[39:32] <= 32;
					sentMsg[47:40] <= 32;
					sentMsg[55:48] <= 32;
					sentMsg[63:56] <= 32;
				end
				else
					begin
					sentMsg <= sentMsg;
				end

					end
					end
					S3 :
				begin
					// "CALLEE  "
					statusMsg[7:0] <= {8{8'd32}};
					statusMsg[15:8] <= {8{8'd32}};
					statusMsg[23:16] <= {8{8'd69}};
					statusMsg[31:24] <= {8{8'd69}};
					statusMsg[39:32] <= {8{8'd76}};
					statusMsg[47:40] <= {8{8'd76}};
					statusMsg[55:48] <= {8{8'd65}};
					statusMsg[63:56] <= {8{8'd67}};
					if (rst)
						begin
						sentMsg <= {8{8'd32}};
						cost <= 0;
				end
					else
						begin
						if (charSent > 47 & charSent < 58 & (sendCharCallee | sendCharCaller)) cost <= cost + 1;
						else if (charSent > 31 & charSent < 128 & (sendCharCallee | sendCharCaller)) cost <= cost + 2;

				if (sendCharCallee & (charSent >= 32 & charSent <= 126))
					begin
					sentMsg[7:0] <= charSent;
				sentMsg[15:8] <= sentMsg[7:0];
				sentMsg[23:16] <= sentMsg[15:8];
				sentMsg[31:24] <= sentMsg[23:16];
				sentMsg[39:32] <= sentMsg[31:24];
				sentMsg[47:40] <= sentMsg[39:32];
				sentMsg[55:48] <= sentMsg[47:40];
				sentMsg[63:56] <= sentMsg[55:48];
				end
				else if (charSent == 127)
				begin 
					sentMsg[7:0] <= 32;
					sentMsg[15:8] <= 32;
					sentMsg[23:16] <= 32;
					sentMsg[31:24] <= 32;
					sentMsg[39:32] <= 32;
					sentMsg[47:40] <= 32;
					sentMsg[55:48] <= 32;
					sentMsg[63:56] <= 32;
				end
				else
					begin
					sentMsg <= sentMsg;
				end
					end
					end

					S4 :
				begin
					// "REJECTED"
					statusMsg[7:0] <= {8{8'd68}};
					statusMsg[15:8] <= {8{8'd69}};
					statusMsg[23:16] <= {8{8'd84}};
					statusMsg[31:24] <= {8{8'd67}};
					statusMsg[39:32] <= {8{8'd69}}; 
					statusMsg[47:40] <= {8{8'd74}}; 
					statusMsg[55:48] <= {8{8'd69}}; 
					statusMsg[63:56] <= {8{8'd82}}; 
					end
					S5 :
				begin
					// "COST    "					
					statusMsg[7:0] <= {8{8'd32}};
					statusMsg[15:8] <= {8{8'd32}};
					statusMsg[23:16] <= {8{8'd32}};
					statusMsg[31:24] <= {8{8'd32}};
					statusMsg[39:32] <= {8{8'd84}}; 
					statusMsg[47:40] <= {8{8'd83}}; 
					statusMsg[55:48] <= {8{8'd79}}; 
					statusMsg[63:56] <= {8{8'd67}}; 

					if (cost[3:0] < 10) sentMsg[7:0] <= cost[3:0] + 48; else sentMsg[7:0] <= cost[3:0] + 55;
				if (cost[7:4] < 10) sentMsg[15:8] <= cost[7:4] + 48; else sentMsg[15:8] <= cost[7:4] + 55;
				if (cost[11:7] < 10) sentMsg[23:16] <= cost[11:7] + 48; else sentMsg[23:16] <= cost[11:7] + 55;
				if (cost[31:24] < 10) sentMsg[31:24] <= cost[15:12] + 48; else sentMsg[31:24] <= cost[15:12] + 55;
				if (cost[19:16] < 10) sentMsg[39:32] <= cost[19:16] + 48; else sentMsg[39:32] <= cost[19:16] + 55;
				if (cost[23:20] < 10) sentMsg[47:40] <= cost[23:20] + 48; else sentMsg[47:40] <= cost[23:20] + 55;
				if (cost[27:24] < 10) sentMsg[55:48] <= cost[27:24] + 48; else sentMsg[55:48] <= cost[27:24] + 55;
				if (cost[31:28] < 10) sentMsg[63:56] <= cost[31:28] + 48; else sentMsg[63:56] <= cost[31:28] + 55;
				end
			endcase
			end
		end

endmodule
