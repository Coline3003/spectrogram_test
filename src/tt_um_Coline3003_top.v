module tt_um_Coline3003_top(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
                              );

   wire reset;
   assign reset = ~rst_n;

    top top1(.reset(reset), 
	     .input_acquisition_clk(clk), 
	     .RTC_clk(ui_in[7]), 
	     .input_serial_readout_clk(uio_in[7]), 
	     .ch1({ui_in[6],ui_in[5],ui_in[4],ui_in[3],ui_in[2],ui_in[1],ui_in[0]}), 
	     .state_reg_FSM({uio_out[2], uio_out[1], uio_out[0]}),
	     .sending_pending(uio_out[3]),
	     .sending_started(uio_out[4]),
	     .read_bank(uio_out[5]),
	     .write_bank(uio_out[6]),
	     .serial_out(uo_out[0]), 
	     .SL_time(uo_out[2]), 
	     .SL_ch(uo_out[3]), 
	     .signal_detected(uo_out[4]), 
             .memorization_completed(uo_out[5]), 
	     .serial_readout(uo_out[6]), 
	     .sending_data(uo_out[7]));
	
	assign uo_out[1] = 0;
	
	assign uio_out[7] = 0;
    assign uio_oe = 8'b11111110; //inputs enable
endmodule // top
