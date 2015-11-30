module wave_display_tb();
	reg clk;//clock signal
	reg reset;//reset signal
	reg [10:0] x;//current z position if vga display
	reg [9:0] y;//current y position of VGA display
	reg valid;//if the VGA coordinates are valid for displaying data
	reg read_index;//indicates which part of RAM to read from
	reg [7:0] read_value;//data read back from RAM
	wire [8:0] read_address;//address in RAM to read
	wire valid_pixel;//if pixel (x;y) should be on
	wire [7:0] r,g,b;//colors

	wave_display wave_dis_or_dat_play (.clk(clk), .reset(reset), .x(x), .y(y), 
	.valid(valid), .read_index(read_index), .read_value(read_value),
	.read_address(read_address), .valid_pixel(valid_pixel), .r(r), .g(g), .b(b));

	//reset and set clock
	initial begin
	  clk = 1'b0;
	  reset = 1'b1;
	  repeat (4) #5 clk = ~clk;
	  reset = 1'b0;
	  forever #5 clk = ~clk;
	end
	
	initial begin
		//initialize read_index and valid
		read_index = 0;
		valid = 1;
		#50
		//set initial x to value in first quadrant; set y and read_value
		x = 11'b00011111111; y = 10'b0011111111; read_value = 8'b00000000;
		#50
		// set x to value in second quadrant
		x = 11'b00100000000; read_value = 8'b01111111;
		#50
		// set x to value between previous and current read_value
		x = 11'b00100000010; read_value = 8'b00000000;
		#100
		// set y to lower half value
		y = 10'b1000000000;
		#100
		// set y to upper half value
		y = 10'b0000000001;
		#50
		// set x to value in second quadrant
		x = 11'b00100000111; read_value = 8'b01111111;
		#50
		// set x to value in third quadrant
		x = 11'b01000001000; read_value = 8'b00000111;
		#50
		x = 11'b00000000000; y = 10'b00001111; read_value = 8'b01111111;
		#50
		$stop;
		
	end
endmodule
