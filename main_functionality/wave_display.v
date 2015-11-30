module wave_display(
	input clk,//clock signal
	input reset,//reset signal
	input [10:0] x,//current x position if vga display
	input	[9:0] y,//current y position of VGA display
	input	valid,//if the VGA coordinates are valid for displaying data
	input	read_index,//indicates which part of RAM to read from
	input [7:0] read_value,//data read back from RAM
	output reg [8:0] read_address,//address in RAM to read
	output valid_pixel,//if pixel (x,y) should be on
	output reg [7:0] r,g,b//colors
    );

//x-coordinates
wire change;
wire [8:0] previous_address;
wire [7:0] previous_value;

//assign the read_address
always @(*) begin
	casex(x)
		11'b000xxxxxxxx: read_address=9'd0;
		11'b001xxxxxxxx: read_address={read_index,1'b0,x[7:1]};
		11'b010xxxxxxxx: read_address={read_index,1'b1,x[7:1]};
		11'b011xxxxxxxx: read_address=9'd0;
		default: read_address=9'd0;
	endcase
end

dffre #(8) current_previous(.clk(clk),.r(reset),.en(change),.d(read_value),.q(previous_value));

//set color to white if  y is between RAM[x-1] and RAM[x]
always @(*) begin
	if(valid_pixel && (((y[8:1]>=read_value) && (y[8:1]<=previous_value)) || ((y[8:1]<=read_value) && (y[8:1]>=previous_value)))) begin
		{r,g,b} = 24'hFFFFFF;
	end else begin
		{r,g,b} = 24'h000000;
	end
end
 
//y-coordinates
//assign y={1'b0,y[8:1]};
//set valid_pixel to 0 when we are not in quadrants 1 or 2 and when we are not in top half of screen
assign valid_pixel = (valid && (x[9]^x[8]) && ~y[9]);


//RAM has one cycle latency after address change
//x input changes on every clock cycle
//RAM read_address only changes every other clock cycle


dffr #(9) whats_the_dffrence (.clk(clk),.r(reset),.d(read_address),.q(previous_address));
//change is true when read_address changes, only then accept new data sample from RAM (use change as enabler above)
assign change = read_address != previous_address;

endmodule
