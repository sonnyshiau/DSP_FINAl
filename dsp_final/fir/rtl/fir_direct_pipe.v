`timescale 1ns / 1ps
module fir_pipe(
    input wire clk,
    input wire rst_n,
    input wire signed[14:0] data_in,
    output wire signed[19:0] data_out
);
//io,parametr define
localparam inWL=15;
localparam macWL=20;
localparam tap_num = 37;

//store coeff
reg signed [inWL-1:0]   coeff  [0:tap_num-1];
//shift register for store data
reg  signed [inWL-1:0]   data_in_reg0  [0:tap_num-2]; 
reg  signed [inWL-1:0]   data_in_reg1  [0:tap_num-2]; 
reg  signed [inWL*2-1:0] mul;

//acc
reg signed  [macWL-1:0]  acc        [0:tap_num-1];
reg signed  [macWL-1:0]  acc_dff    [0:tap_num-1];

integer j;


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
//data_in pass 2 stage DFF 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (j = 0; j < tap_num-1; j = j + 1) begin
            data_in_reg0[j] <= 0;
            data_in_reg1[j] <= 0;
        end
    end else begin
        data_in_reg0[0] <= data_in;
        data_in_reg1[0] <= data_in_reg0[0];
        for (j = 1; j < tap_num-1; j = j + 1)  begin
            data_in_reg0[j] <= data_in_reg1[j-1];
            data_in_reg1[j] <= data_in_reg0[j];
        end
    end
end
//acc pass one DFF
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (j = 0; j < tap_num; j = j + 1) begin
            acc[j] <= 0;
        end
    end else begin
        for (j = 0; j < tap_num; j = j + 1) begin
            acc[j] <= acc_dff[j];
        end
    end
end
//calculation
always@*begin
    for (j=0;j<tap_num;j=j+1)begin
        mul = (j==0)? data_in * coeff[0] :data_in_reg1[j-1] * coeff[j];
        acc_dff[j] = (j==0)? mul[29:10]:acc[j-1]+ mul[29:10];
    end
end

/*
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        
        $display("Resetting FIR pipeline at time: %t", $time);
    end else begin
        
        for (j = 0; j < tap_num; j = j + 1) begin
            $display("Time: %t,  data_in_reg1[%0d]: %d, data_in_reg0[%0d]: %d,mul: %d, mul_truncate: %d,acc_dff[%0d]: %d,acc[%0d]: %d"
                    , $time, j, data_in_reg1[j], j, data_in_reg0[j],mul, mul_truncate, j,acc_dff[j],j,acc[j]);
        end
    end
end

*/
assign data_out = acc_dff[tap_num-1]; 



endmodule

