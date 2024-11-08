module part2 (SW, KEY, LEDR);

input [1:0] SW;
input [0:0] KEY;
output [9:0] LEDR;

wire Clock, Resetn, w, z;

assign Clock = KEY[0];
assign Resetn = SW[0];
assign w = SW[1];

reg [3:0] y_Q, Y_D; //y_Q = current state, Y_D = next state
parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111, I = 4'b1000;

always @ (w, y_Q)
begin
	case (y_Q)
		A: if (!w) Y_D = B;
			else Y_D = F;

		B: if (!w) Y_D = C;
			else Y_D = F;
			
		C: if (!w) Y_D = D;
			else Y_D = F;
		
		D: if (!w) Y_D = E;
			else Y_D = F;
		
		E: if (!w) Y_D = E;
			else Y_D = F;
			
		F: if (!w) Y_D = B;
			else Y_D = G;
			
		G: if (!w) Y_D = B;
			else Y_D = H;
			
		H: if (!w) Y_D = B;
			else Y_D = I;
			
		I: if (!w) Y_D = B;
			else Y_D = I;
			
		default: Y_D = 4'bxxxx;
	endcase
end

always @ (posedge Clock)
begin
	if (!Resetn) y_Q <= A;
	else y_Q <= Y_D;
end

assign z = (y_Q == E | y_Q == I);
assign LEDR[9] = z;
assign LEDR[3:0] = y_Q;

endmodule
