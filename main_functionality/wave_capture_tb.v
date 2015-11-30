module wave_capture_tb();
	reg clk;//clock signal
	reg reset;//reset signal
	reg new_sample_ready;//one-cycle pulse saying if next sample is ready
	reg [15:0] new_sample_in;//new audio sample
	reg wave_display_idle;//high when wave_display isn't rendering a fram
	wire [8:0] write_address;//address of location to write in RAM
	wire write_enable;//high when module needs to write to RAM
	wire [7:0] write_sample;//top bits of sample to write into the RAM
	wire read_index;//which part of RAM wave_display should read from

	wave_capture pop_a_cap_in_yo_a$$(.clk(clk), .reset(reset), .new_sample_ready(new_sample_ready),
		.new_sample_in(new_sample_in), .wave_display_idle(wave_display_idle), 
		.write_address(write_address), .write_enable(write_enable), .write_sample(write_sample),
		.read_index(read_index));
	
	//reset and set clock
	initial begin
	  clk = 1'b0;
	  reset = 1'b1;
	  repeat (4) #1 clk = ~clk;
	  reset = 1'b0;
	  forever #1 clk = ~clk;
	end
	
	initial begin
		//begin in armed state
		wave_display_idle = 1'b0;
		new_sample_ready = 1'b1;//new sample is ready
		new_sample_in = 16'hFFFF;//new sample
		#200;
		new_sample_in=16'h0000;//causes positive crossover, which will switch to active state
		#100
		new_sample_ready=1'b0;//will pause write adress; turn off write enable
		#20
		new_sample_ready=1'b1;//continue writing address every clock cycle	
		#600//make sure our count has reached 256 so that we are in the wait state	
		wave_display_idle = 1'b1;//swicth to armed state; foip read index
		#5;
		wave_display_idle=1'b0;//wave_display  only on for a clock pulse
		new_sample_in = 16'hFFFF;//change our sample in; wont change write enable and thus we wont be writing address
		#10;
	end
endmodule
