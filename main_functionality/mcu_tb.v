module mcu_tb();
    reg clk, reset, play_button, next_button, song_done;
    wire play, reset_player;
    wire [1:0] song;

    mcu dut(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(song),
        .song_done(song_done)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    initial begin
		#200
		play_button = 0; next_button = 0; song_done = 0;//reset our play_button, next_button, and song_done
		//press play button on and off with varying delays		
		#10 play_button = 1; #10 play_button = 0; 
		#100
		#10 play_button = 1; #10 play_button = 0; 
		#50
		#10 play_button = 1; #10 play_button = 0; 
		#50
		//press next_button(on and off) with 10 ns delays
		#10 next_button = 1; #10 next_button = 0;
		#10 next_button = 1; #10 next_button = 0;
		#10 play_button = 1; #10 play_button = 0;
		#100
		#10 next_button = 1; #10 next_button = 0;
		#100
		//set song done to true, and then false
		#10 song_done = 1;   #10 song_done   = 0;
		#500
		$stop;
    end

endmodule
