
/*this module  reads the song's sequence of notes out of the provided song_rom */
module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input note_done,
    output song_done,
    output [5:0] note,
    output [5:0] duration,
    output new_note
);

	wire [11:0] value;//this holds the note and the duration concatenated together
	wire next_note;
	wire [5:0]count;//count used to make our timer
	
	//assign count = 6'b000000;
	//a timer that increments our count by 1 when our note is done and play is true
	dffre #(6) timer (.clk(clk) , .r(reset), .en(note_done && play), .d(count+1), .q(count));
	assign new_note = (note_done && count != 31); //new_note is true when the previous note is done and the count has reached its max value meaning there is a new note ready
	song_rom rom_com (.clk(clk), .addr(song*32+count), .dout(value/*next_value*/)); //increment by count with each note played, and our next_value becomes this new increemented count
	assign song_done = (count >= 31);//song is done when we have reached a count of 32
	assign note = value[11:6];//value of the note
	assign duration = value[5:0];//value of the dur ation
endmodule

