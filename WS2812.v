// synopsys translate_off
`timescale 1 ns  / 100 ps
// synopsys translate_on

module WS2812(iSIGNAL_CLOCK, rSTART_ADDRESS, dataIn, rCONFIG, oCTRL_OUT, oReadClk, oReadAddress); //put ext_reset as part of rCONFIG
    parameter DATAEWIDTH   = 32;
    parameter ADDRESSWIDTH = 32;
    
    input iSIGNAL_CLOCK;//100 MHz clock for signal timing
    input [ADDRESSWIDTH-1:0] rSTART_ADDRESS;
    input [31:0] dataIn;// should be written to ram in a 0xXXGGRRBB format
    
    inout [ADDRESSWIDTH-1:0] rCONFIG;//configuration register 
    // bit 31 is reset and will be cleared once reset is performed
    // bits 15:0 define how many LEDs will be driven
    // the rest are not used yet idk what they might be used for either
    
    output oCTRL_OUT;
    output oReadClk;
    output [ADDRESSWIDTH-1:0] oReadAddress;


        
	
    //the following is times specified by the ws2812b datasheet
    //units are in clock periods 10ns in this case
    parameter T0H = 40; //number of clock cycles it shoud be high for a zero signal
    parameter T1H = 80; // number of clock cycles it should be high for a 1 signal
    parameter T0L = 85; // number of clock cycles it should be low for a zero signal
    parameter T1L = 45; // number of clock cycles it should be low for a 1 signal
    parameter TRS = 5100; // number of clock cycles to cause a reset condition

	

    //signal declarations
    wire [23:0] wRamData;

    wire [23:0] wCDATA;//color data read from ram
    wire [16-1:0] ledCount;
    //register declarations
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
    
    assign ext_reset=rCONFIG[31];
    assign ledCount=rCONFIG[15:0];
    assign wCDATA[23:0]= dataIn[23:0];
    assign oReadAddress = read_address;
    assign oReadClk = wRCLK;
always @(posedge iSIGNAL_CLOCK)
begin
    if (ext_reset) begin
	read_address=rSTART_ADDRESS;
	bit_counter<=0;
	signal_timer<=0;
	rCTRL_OUT<=0;
	sig_reset<=0;
        ext_reset<=0;
    end
    else begin
    	if (signal_timer==0 && ~sig_reset)
	begin
            rCTRL_OUT<=1;
	end
	if (~sig_reset) begin
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
	            if (read_address >= ledCount+rSTART_ADDRESS) begin
		        read_address<=rSTART_ADDRESS;
		    end
	            else begin
		        read_address<=read_address+4;
		    end    
                end
                if (bit_counter ==12) begin //read clock
                    wRCLK <= 1;    
                end
                if (bit_counter == 23)//read from ram output here
	        begin
                    wRCLK <= 0;
		    bit_counter <= 0;
		    srCDATA <= wCDATA;
		    if (read_address == rSTART_ADDRESS) begin// decide if need to enter reset mode here
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
	    srCDATA <= wCDATA;
            //srCDATA[23:0] <= srCDATA;
        end
        else begin
	    if (signal_timer >= TE) begin
                signal_timer <= 0;
	    end
	    else begin
	        signal_timer <= signal_timer+1; 
	    end
        end
    end
end

endmodule
	
