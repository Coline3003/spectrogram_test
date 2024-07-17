module top(
    	input input_acquisition_clk, input_serial_readout_clk, RTC_clk, reset,
	 input wire [6:0] ch1,  
	 output wire serial_out,	 
	 output SL_ch, SL_time, serial_readout, signal_detected, memorization_completed,sending_data, read_bank,
	write_bank, sending_started, sending_pending,
	output [2:0] state_reg_FSM

);

	wire [8:0] addr_in;
	wire [8:0] addr_out;
	wire [2:0] data_decode;
	wire [2:0] data_sent;
	//wire signal_detected;
	wire acquisition_clk_enable;
	wire serial_readout_clk_enable;
	wire acquisition_clk;
	wire serial_readout_clk;
	wire we, bank0_full, bank1_full, selection_bit, re, PISO_ch1, PISO_time, bank;
	wire [1:0] state_reg_memctr;
	//wire memorization_completed;


wire [7:0] idx_final;
	assign read_bank = addr_out[8];
	assign write_bank = addr_in[8];

memory_controller mem_ctl(.clk(acquisition_clk), .reset(reset), .signal_detected(signal_detected), .addr_in(addr_in[8:0]), .idx_final(idx_final[7:0]), .we(we), .bank0_full(bank0_full), .bank1_full(bank1_full),
			  .memorization_completed(memorization_completed), .state_reg(state_reg_memctr[1:0]), .bank(bank));

FSM fsm(.clk(serial_readout_clk),.reset(reset), .bank0_full(bank0_full), .bank1_full(bank1_full), .memorization_completed(memorization_completed), 
	.idx_final(idx_final[7:0]), .addr_out(addr_out[8:0]), .SL_ch(SL_ch), .SL_time(SL_time), .selection_bit(selection_bit), 
	.re(re), .serial_readout(serial_readout), .sending_data(sending_data), .state_reg(state_reg_FSM), .sending_started(sending_started),.bank(bank), 
	.sending_pending(sending_pending));

		
	//signal detector
	assign signal_detected = ch1[0];
	
	//clk _activators
	assign acquisition_clk_enable = memorization_completed || signal_detected || we || (state_reg_memctr != 0) ;
	assign serial_readout_clk_enable = memorization_completed || serial_readout || acquisition_clk_enable || (state_reg_FSM != 0) ;
	assign acquisition_clk = acquisition_clk_enable && input_acquisition_clk; 
	assign serial_readout_clk = serial_readout_clk_enable && input_serial_readout_clk;
	
	
	//encode data
	encoder enc1( .channel(ch1[6:0]), .channel_decode(data_decode[2:0]));

	memory memory1(.clk_write(acquisition_clk),.clk_read(serial_readout_clk),.write_enable(we), .address_in(addr_in[8:0]), .data_in(data_decode[2:0]),
		       .read_enable(re), .address_out(addr_out[8:0]), .data_out(data_sent[2:0]));
  	
	PISO_register reg1(.clk(serial_readout_clk), .reset(reset), .SL(SL_ch), .parallel_in(data_sent[2:0]), .serial_out(PISO_ch1));
	
	mux_2to1 mux(.PISO_ch1(PISO_ch1), .PISO_time(PISO_time), .select(selection_bit), .data_out(serial_out));

	wire [31:0] event_time;
	wire [31:0] event_time_out;
	RTC rtc(.clk(RTC_clk), .reset(reset), .sec(event_time[15:10]), .millisec(event_time[9:0]),
               .min(event_time[21:16]), .hour(event_time[26:22]), .day(event_time[31:27]));
	time_register time_reg(.clk(signal_detected), .reset(reset), .event_time(event_time[31:0]),.event_time_out(event_time_out[31:0]));
	PISO_time_register piso_time_reg(.clk(serial_readout_clk),.reset(reset), .SL(SL_time), .parallel_in(event_time_out[31:0]), .serial_out(PISO_time));


endmodule 
