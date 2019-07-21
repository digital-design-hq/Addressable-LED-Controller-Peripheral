// synopsys translate_off
`timescale 1 ns  / 100 ps
// synopsys translate_on

module WS2812(iSIGNAL_CLOCK, dataIn, rCONFIG, oCTRL_OUT, oReadAddress); //put ext_reset as part of rCONFIG
    
    input iSIGNAL_CLOCK;//100 MHz clock for signal timing
    input [31:0] dataIn;// should be written to ram in a 0xXXGGRRBB format need some interface for the fifo
    
    inout [31:0] rCONFIG;//configuration register 
    // bit 31 is reset and will be cleared once reset is performed
    // bits 15:0 define how many LEDs will be driven
    // the rest are not used yet idk what they might be used for either
    
    output oCTRL_OUT;


        
	
    //the following is times specified by the ws2812b datasheet
    //units are in clock periods 10ns in this case
    parameter T0H = 40; //number of clock cycles it shoud be high for a zero signal
    parameter T1H = 80; // number of clock cycles it should be high for a 1 signal
    parameter T0L = 85; // number of clock cycles it should be low for a zero signal
    parameter T1L = 45; // number of clock cycles it should be low for a 1 signal
    parameter TRS = 5100; // number of clock cycles to cause a reset condition

	

    //signal declarations

    wire [23:0] wCDATA;//color data read from ram
    wire [16-1:0] ledCount;
    wire runOnce;
    wire allOff;
    wire run;
    //register declarations
    reg [15:0] ledCounter;
    reg wRCLK;
    reg [12:0] signal_timer;
    reg [4:0] bit_counter;
    reg [23:0] srCDATA;
    reg rCTRL_OUT;
    reg sig_reset;
    reg [6:0] TH;
    reg [6:0] TE;
    //assignments
    assign oCTRL_OUT=rCTRL_OUT;
    assign run = rCONFIG[31] 
    assign ext_reset=rCONFIG[30];
    assign runOnce= rconfig[29];
    assign allOff= rconfig[28]
    assign ledCount=rCONFIG[15:0];
    
    assign wCDATA[23:0]= dataIn[23:0];
    assign oReadAddress = read_address;
    assign oReadClk = wRCLK;
always @(posedge iSIGNAL_CLOCK) // I think this should be always_ff but it seems to break if I try that
begin
    if ((run || runOnce || allOff)&& !fifo_empty) begin
    
        if (ext_reset) begin
	    bit_counter<=0;
	    signal_timer<=0;
	    rCTRL_OUT<=0;
	    sig_reset<=1;
            ext_reset<=0;
            ledIdx<=0;
            srCDATA<=0;
        end
        else begin
    	    if (signal_timer==0 && !sig_reset)
	    begin
                rCTRL_OUT<=1;
	    end
	    if (!sig_reset) begin
	        if (srCDATA[23])
	        begin
		    TH<=T1H;
		    TE<=T1H+T1L;
	        end
	        else
	        begin
	            TH<=T0H;
	            TE<=T0H+T0L;
	        end
	        rCTRL_OUT<=(signal_timer < TH)?1:0;//toggles control line
	        if (signal_timer >= TE)
	        begin
	            srCDATA<=srCDATA<<1;//shift 1 bit at a time and use that to determine pulse times
	            if (bit_counter == 11) begin//change read address here
	                if (ledIdx >= ledCount) begin
		            ledIdx<=0;
		        end
	                else begin
		            ledIdx<=ledIdx+1;
		        end    
                    end
                    if (bit_counter == 23)//read from ram output here
	            begin
                    
		        bit_counter <= 0;
                        if (all_off) begin
                            srCDATA <= 0;
                        end
                        else begin
                            srCDATA <= wCDATA;//read from fifo
                        end
		        if (!ledIdx) begin// decide if need to enter reset mode here
	                    sig_reset <= 1;
		        end
	            end
	            else
	            begin
		        bit_counter<=bit_counter+1;
	            end
	        end
            end
            if (sig_reset && signal_timer>TRS) begin// impliment reset timer
	        signal_timer <= 0;
	        sig_reset <= 0;
	        srCDATA <= wCDATA;//read fifo here no latency hiding 
                //srCDATA[23:0] <= srCDATA;
                end
            else begin
	        if (signal_timer >= TE) begin
                    signal_timer <= 0;
                    allOff<=0;
                    runOnce<=0;
	        end
	        else begin
	            signal_timer <= signal_timer+1; 
	        end
            end
        end
    end
end

endmodule
	
