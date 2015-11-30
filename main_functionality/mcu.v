`define SONG1 2'b00
`define SONG2 2'b01
`define SONG3 2'b10
`define SONG4 2'b11
/*this module controls the overall system in 
response to the button presses and it also keeps track of what song is being played*/
module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output play,
    output reset_player,
    output [1:0] song,
    input song_done
);
	wire next_play;
	//wire next_play1;
	reg [1:0] next_song;
	/*sets the play to the value of play_button. It will set play to 0 if the song is done 
	,next_button is pressed, or reset is pressed*/
	dffre #(1) play_clock(.clk(clk), .r(song_done||next_button||reset), .en(play_button), .d(~play), .q(play));
	
	//assign next_play = play_button ? ~play : play;
	
	assign reset_player = next_button || song_done;//sets the value of reset_player to true is the next button is pressed or the song is done
	
	//case statement defining what state our song should change to
	always @(*) begin
		case (song)
			`SONG1: next_song = `SONG2;
			`SONG2: next_song = `SONG3;
			`SONG3: next_song = `SONG4;
			`SONG4: next_song = `SONG1;
			default: next_song = `SONG1;//default next song is the first song
		endcase
	end
	
	//changes the song to the next song 
	dffre #(2) song_clock(.clk(clk), .r(reset), .en(next_button||song_done), .d(next_song), .q(song));
	
endmodule
