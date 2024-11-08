module part1pt2 (SW, KEY, LEDR);

input [1:0] SW;
input [0:0] KEY;
output [9:0] LEDR;

wire clk, reset, w, z;

assign clk = KEY[0];
assign reset = SW[0];
assign w = SW[1];

reg [8:0] y; //y = current state
wire [8:0] Y; //Y = next state



assign Y[0] = reset; //A
assign Y[1] = ~w & (~y[0] | y[5] | y[6] | y[7] | y[8]); //B
assign Y[2] = ~w & y[1]; //C
assign Y[3] = ~w & y[2]; //D
assign Y[4] = ~w & (y[3] | y[4]); //E
assign Y[5] = w & (~y[0] | y[1] | y[2] | y[3] | y[4]); //F
assign Y[6] = w & y[5]; //G
assign Y[7] = w & y[6]; //H
assign Y[8] = w & (y[7] | y[8]); //I

always @ (posedge clk)
begin
	if (!reset)
		y <= 9'b000000000;
	else
		y <= Y;
end

assign z = y[4] | y[8];
assign LEDR[9] = z;
assign LEDR[8:0] = y;

endmodule
