/*this module takes in a step size and steps through the sine ROM, generating a sine wave with frequency
determined by the step size */
module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,//step size
    input generate_next,//true when we should generate the next sample
    output sample_ready,//true if there is a sample ready to output
    output wire [15:0] sample // generated sample
);

    wire [21:0] addr; // 22-bit address that is generated 
	 wire [9:0] rom_input;//input to go into sine_rom
	 wire [15:0] raw_sample;//output of sine-rom
	 wire previous_generate_next;//true if generate_next was true in the previous cyle
	 // output the address, which is the sum of the previous address and the step size , when generate_next is 
	 dffre #(22) timer (.clk(clk), .r(reset), .en(generate_next), .d(addr+step_size), .q(addr));
	 assign rom_input = (addr[20]) ? 22'b0-addr[19:10] : addr[19:10];// mux to  select whether we should flip horizontally or not, which is done by inverting the input to sine_rom
	 //instantiate sine_rom which will take in an adress and output a sample from the sine wave
	 sine_rom romulus (.clk(clk), .addr(rom_input), .dout(raw_sample));
	 assign sample = (addr[21 ]) ? 16'b0 - raw_sample: raw_sample;//mux to select if we should flip vertically, which is done by inverting the output to sine_rom
	 //will set the value of previous_generate_next to the value of generate_next, which will change for the next cycle
	 dffr #(1) timer2 (.clk(clk), .r(reset), .d(generate_next), .q(previous_generate_next)); 
	 //a sample is ready when we should generate the next sample and we did not generate a next sample on the previous cycle
	 assign sample_ready = (generate_next && ~previous_generate_next);
endmodule
