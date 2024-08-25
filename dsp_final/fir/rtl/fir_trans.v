`timescale 1ns / 1ps
module fir_trans(
    input wire clk,
    input wire rst_n,
    input wire signed[14:0] data_in,
    output wire signed[19:0] data_out
);
//io,parametr define
localparam inWL=15;
localparam macWL=20;
localparam tap_num = 37;
integer idx;

//store coeff
reg signed [inWL-1:0]  coeff   [0:tap_num-1];
//data * tap
//reg signed [19:0] mul    [0:36];
//acc
reg signed [macWL-1:0]  acc     [0:tap_num-2];
//dff for acc_buffer
reg signed [macWL-1:0]  dff_acc [0:tap_num-2];

reg signed [inWL*2-1:0] mul    [0:tap_num-1];
//taps宣告

initial begin
    coeff[0] = -15'd38; coeff[1] = -15'd137; coeff[2] = 15'd0;
    coeff[3] = 15'd241; coeff[4] = 15'd120; coeff[5] = -15'd331;
    coeff[6] = -15'd351; coeff[7] = 15'd338; coeff[8] = 15'd690;
    coeff[9] = -15'd178; coeff[10] = -15'd1114; coeff[11] = -15'd267;
    coeff[12] = 15'd1562; coeff[13] = 15'd1185; coeff[14] = -15'd1964;
    coeff[15] = -15'd3176; coeff[16] = 15'd2241; coeff[17] = 15'd11639;
    coeff[18] = 15'd16383; coeff[19] = 15'd11639; coeff[20] = 15'd2241;
    coeff[21] = -15'd3176; coeff[22] = -15'd1964; coeff[23] = 15'd1185;
    coeff[24] = 15'd1562; coeff[25] = -15'd267; coeff[26] = -15'd1114;
    coeff[27] = -15'd178; coeff[28] = 15'd690; coeff[29] = 15'd338;
    coeff[30] = -15'd351; coeff[31] = -15'd331; coeff[32] = 15'd120;
    coeff[33] = 15'd241; coeff[34] = 15'd0; coeff[35] = -15'd137;
    coeff[36] = -15'd38;
end

//multiply
always @* begin
    for(idx=0; idx < tap_num ; idx=idx+1)begin
       mul[idx] = data_in * coeff[idx];
    end

    for (idx=0; idx < tap_num-1 ; idx=idx+1)begin
        acc[idx] = dff_acc[idx] + mul[idx+1][29:10];
    end
end

//shift acc
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        for(idx=0;idx<tap_num-1;idx=idx+1)begin
            dff_acc[idx] <= 20'd0;
        end
    end
    else begin
        dff_acc[0] <= mul[0][29:10];
        for(idx=1;idx<tap_num-1;idx=idx+1)begin
            dff_acc[idx] <= acc[idx-1];
        end
    end
end


assign data_out = acc[tap_num-2];

endmodule

