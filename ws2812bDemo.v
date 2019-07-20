module top
    (
        input clk,// 100 MHz Clk
        input [7:0] SW3,//dip switches
        output [7:0] led,//led output
        output [13:0] disp,//14 segment display
        output ctrlOut // digital pin out pin 4 of X3
    );
    parameter DATAWIDTH   = 32;
    parameter DATADEPTH    = 64;
    parameter ADDRESSWIDTH = $clog2(DATADEPTH);
    parameter START_ADDRESS= 4'b1100;
    parameter NUM_LEDS = 8;
    reg [DATAWIDTH-1:0] rCONFIG;
    reg [DATAWIDTH-1:0] dataIn;
    reg [30:0] clk_div;
    reg [7:0] swStatus;
        

    wire readClk;
    wire writeClk;
    wire writeEn;
    wire [ADDRESSWIDTH-1:0] hreadAddress;
    wire [31:0] readAddress;
    reg  [ADDRESSWIDTH-1:0] writeAddress;
    wire [DATAWIDTH-1:0] dataOut;
    assign writeEn = swStatus[6];    
    assign led[7] = ~rCONFIG[31];
    assign hreadAddress = readAddress[ADDRESSWIDTH+1:2];
    simpleDualPortDualClockMemory #(.DATAWIDTH(32), .DATADEPTH(128) )
    simpleDualPortDualClockMemory(
        .readClk(readClk), 
        .writeClk(clk), 
        .writeEn(writeEn), 
        .dataIn(dataIn), 
        .readAddress(readAddress), 
        .writeAddress(writeAddress), 
        .dataOut(dataOut)
    );//creates a block of ram for the led driver periphial to run from
    //declaring the WS2812 interface
    WS2812 WS2812inst(.iSIGNAL_CLOCK(clk), .rSTART_ADDRESS(START_ADDRESS), .dataIn(dataOut), .rCONFIG(rCONFIG), .oCTRL_OUT(ctrlOut), .oReadClk(readClk), .oReadAddress(readAddress[31:2]));
    // switch interface for debuging

    `include "out.vh"  

    always @(posedge clk) begin
        clk_div <= clk_div+1;
        rCONFIG[15:0]<=NUM_LEDS;
	swStatus <= SW3;
        
        if (swStatus[7] != SW3[7]) begin
            if (swStatus[7]==0) begin
                rCONFIG[31]<=1;
                clk_div <= 0;
            end
            else begin
                rCONFIG[31]<=0;
            end
        end
        dataIn[31:24] <= 0;
        dataIn[23:22] <= SW3[5:4];
        dataIn[21:20] <= SW3[5:4];
        dataIn[19:18] <= SW3[5:4];
        dataIn[17:16] <= SW3[5:4];
        dataIn[15:14] <= SW3[3:2];
        dataIn[13:12] <= SW3[3:2];
        dataIn[11:10] <= SW3[3:2];
        dataIn[9:8]   <= SW3[3:2];
        dataIn[7:6]   <= SW3[1:0];
        dataIn[5:4]   <= SW3[1:0];
        dataIn[3:2]   <= SW3[1:0];
        dataIn[1:0]   <= SW3[1:0];
        writeAddress <= clk_div[30:28]+START_ADDRESS;
        disp <= ~display_pat[clk_div[30:28]];
        led[6:0] <= ~dataOut[6:0]; 
    end

   
endmodule

