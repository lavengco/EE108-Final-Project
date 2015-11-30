`define SWIDTH 2
`define ARMED 2'b00
`define ACTIVE 2'b01
`define WAIT 2'b10

module wave_capture(
	input clk,//clock signal
	input reset,//reset signal
	input new_sample_ready,//one-cycle pulse saying if next sample is ready
	input [15:0] new_sample_in,//new audio sample
	input wave_display_idle,//high when wave_display isn't rendering a fram
	output [8:0] write_address,//address of location to write in RAM
	output write_enable,//high when module needs to write to RAM
	output [7:0] write_sample,//top bits of sample to write into the RAM
	output read_index//which part of RAM wave_display should read from
    );

	
	wire [1:0] state;//current state
	reg  [1:0] next_state;//next state based on conditions
	//change our current state
	dffr #(`SWIDTH) state_reg (.clk(clk), .r(reset), .d(next_state), .q(state));
		
	always @(*) begin
		case(state)
			`ARMED:  next_state = crossover ? `ACTIVE:`ARMED;//go from armed to active when we see positive crossover
			`ACTIVE: next_state = (count == 8'd255) ? `WAIT:`ACTIVE;//go from active to wait when we have written all 256 samples
			`WAIT:   next_state = wave_display_idle ? `ARMED:`WAIT;//go from wait to armed when wave_display_idle is 1
			default: next_state = 2'b11;//default
		endcase
	end

	//Detect crossover
	wire crossover;
	wire previous;
	//store the most sognificant bit of the previous sample
	dffre #(1) why_didnt_the_chicken_cross_the_road /*because no crossover*/ (.clk(clk), .r(reset), 
		.en(new_sample_ready), .d(new_sample_in[15]), .q(previous));
	//test for positive crossover
	assign crossover = (state==`ARMED) && (previous > new_sample_in[15]);


	wire [7:0] count;//the count
	//counter that is incremented by 1 when we are in the active state and new_sample_ready is high
	dffre #(8) count_on_me_like_123(.clk(clk), .r(reset || (state == `ARMED)),
		.en(new_sample_ready && (state == `ACTIVE)), .d(count+1'd1), .q(count));
	
	//read_index is flipped when wave_display_idle turns to 1, and we are in the wait state
	dffre #(1) reading_rainbow (.clk(clk), .r(reset), .en(wave_display_idle && (state == `WAIT)),
		.d(~read_index), .q(read_index));
	
	//write outputs
	assign write_address = {~read_index, count};//write our address
	assign write_sample = ((state == `ACTIVE)||crossover) ? (new_sample_in[15:8]+8'd128):8'hFF;//assign a sample value, taking into account proper formatting of the input sample
	assign write_enable = (new_sample_ready && ((state == `ACTIVE)||crossover));//write_enable is true when we are in the active state and a new sample is ready

endmodule
