module sine_reader_tb();

    reg clk, reset, generate_next;
    reg [19:0] step_size;
    wire sample_ready;
    wire [15:0] sample;
    sine_reader reader(
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(sample)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests that change the value of generate_next, as well as step_size
    initial begin
		generate_next = 0;
		#200
		generate_next = 1;//generate next sample
		step_size = {10'd10, 10'd0};//set our step size
		#10;
		generate_next=0;//do not generate next sample
		#10;
		generate_next=1;//generate next sample
		#200;
    end

endmodule
