/*this module takes in a note, looks up the
step size required to generate the correct frequency for that note, and then synthesizes a sine wave
at that frequency for as long as the note is playing.
 */
module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  // Tells the codec when we've got a sample
);
	wire [19:0] step_size;
	wire [6:0] count;
	
	//this instantiates frequency_rom, to obtain the step_size
	frequency_rom john_frequincy_adams (.clk(clk), .addr(note_to_load), .dout(step_size));
	
	//instantiate sine_reader to obtain a sine wave
	sine_reader i_saw_the_sines  (.clk(clk), .reset(reset), .step_size(step_size), .generate_next(play_enable && generate_next_sample),
	.sample_ready(new_sample_ready), .sample(sample_out));
	
	
	/*a counter that will increment our count by 1 when we are on the beat and play_enable is true; our count will be reset if 
	if reset is pressed, we have a new note to load, or the count is equal to our duration of the note*/
	dffre #(6) jeffrey_the_dffre  (.clk(clk), .r(reset || (count == duration_to_load) || load_new_note), .en(beat && play_enable), .d(count+1), .q(count));
	
	//we are done with a note when the count has recahed the duration_to_load
	assign done_with_note = (count == duration_to_load);
	
	
	
endmodule
