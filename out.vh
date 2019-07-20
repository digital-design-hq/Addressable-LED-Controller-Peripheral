    localparam pat_len = 15;
    wire [13:0] display_pat[0:pat_len-1];
    assign display_pat[0] = 14'b00000000111111;  // 0
    assign display_pat[1] = 14'b00000100000110;  // 1
    assign display_pat[2] = 14'b10001000011011;  // 2
    assign display_pat[3] = 14'b00001000001111;  // 3
    assign display_pat[4] = 14'b10001000100110;  // 4
    assign display_pat[5] = 14'b10001000101101;  // 5
    assign display_pat[6] = 14'b10001000111101;  // 6
    assign display_pat[7] = 14'b01000100000001;  // 7
    assign display_pat[8] = 14'b10001000111111;  // 8
    assign display_pat[9] = 14'b10001000100111;  // 9
    assign display_pat[10] = 14'b10001000110111;  // A
    assign display_pat[11] = 14'b10010100111001;  // B
    assign display_pat[12] = 14'b00000000111001;  // C
    assign display_pat[13] = 14'b01000001110000;  // D
    assign display_pat[14] = 14'b00000000000000;
