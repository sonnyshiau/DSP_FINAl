`timescale 1ns / 1ps
module fir(
    input wire clk,
    input wire rst_n,
    input wire [14:0] data_in,
    output wire [19:0] data_out
);
//io,parametr define
localparam inWL=15;
localparam macWL=20;
localparam tap_num = 37;

//store coeff
reg signed [inWL-1:0]   coeff  [0:tap_num-1];
//shift register for store data
reg  signed [inWL-1:0]   shift  [0:tap_num-1];
//data * tap
wire signed [inWL*2-1:0] mul    [0:tap_num-1];
//acc
wire signed [macWL-1:0]  acc    [0:tap_num-1];

//taps宣告


initial begin
    coeff[0] = -15'd38; coeff[1] = -15'd137; coeff[2] = 15'd0;
    coeff[3] = 15'd241; coeff[4] = 15'd120; coeff[5] = -15'd331;
    coeff[6] = -15'd351; coeff[7] = 15'd338; coeff[8] = 15'd690;
    coeff[9] = -15'd178; coeff[10] = -15'd1114; coeff[11] = -15'd267;
    coeff[12] = 15'd1562; coeff[13] = 15'd1185; coeff[14] = -15'd1964;
    coeff[15] = -15'd3176; coeff[16] = 15'd2241;coeff[17] = 15'd11639;
    coeff[18] = 15'd16383; 
    coeff[19] = 15'd11639; coeff[20] = 15'd2241;coeff[21] = -15'd3176; 
    coeff[22] = -15'd1964; coeff[23] = 15'd1185; coeff[24] = 15'd1562; 
    coeff[25] = -15'd267; coeff[26] = -15'd1114;
    coeff[27] = -15'd178; coeff[28] = 15'd690; coeff[29] = 15'd338;
    coeff[30] = -15'd351; coeff[31] = -15'd331; coeff[32] = 15'd120;
    coeff[33] = 15'd241; coeff[34] = 15'd0; coeff[35] = -15'd137;
    coeff[36] = -15'd38;
end

//第一級acc結果為0
genvar idx;
generate
    for(idx=0;idx<tap_num;idx=idx+1)begin
        assign mul[idx] = shift[idx]*coeff[idx];
    end
endgenerate
//將前一級的acc_pre做accumulation
generate
    for(idx = 0; idx < tap_num; idx = idx + 1) begin
        if (idx == 0) begin
            assign acc[idx] = mul[idx][29:10];
        end 
        else begin
            assign acc[idx] = acc[idx - 1] + mul[idx][29:10];
        end
    end
endgenerate
//shift register

integer j;
always@(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        for(j=0;j<tap_num;j=j+1)
            shift[j] <= 0;
    end
    else begin
        shift[0]<=data_in;
        for(j=1;j<tap_num;j=j+1)
            shift[j]<=shift[j-1];
    end
end

assign data_out = acc[tap_num-1];

endmodule

