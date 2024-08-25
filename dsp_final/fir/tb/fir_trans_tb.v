`timescale 1ns / 1ps
//transposed form tb

module fir_trans_tb;
    parameter inWL = 15;
    parameter macWL = 20;
    parameter Data_Num =500;

    reg signed [inWL-1:0] in;
    reg signed [inWL-1:0] tap;
    wire signed [macWL-1:0] out;
    reg clk;
    reg rst_n;

    //this is for test transposed form module
    
    fir_trans U0(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(in),
        .data_out(out)
    );


    initial begin
        $dumpfile("fir.vcd");
        $dumpvars();
    end

    
    integer f_data,f_golden,error;
    reg signed [19:0] golden;
    initial begin
        clk = 1'b0;
        in = 15'd0;
        error = 0;
        golden = 20'd0;
    end

    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        f_data = $fopen("/home/ubuntu/dspic_final_submit/dsp_final/data/HW_input.txt","r");
        f_golden = $fopen("/home/ubuntu/dspic_final_submit/dsp_final/data/HW_golden.txt", "r");
        #100;
        rst_n = 1'b1;
        #100; 
        repeat(500) begin
            @(posedge clk)begin
                $fscanf(f_data, "%d", in);
                $fscanf(f_golden, "%d", golden);
            end
            @(negedge clk)begin
                if(out==golden)begin
                    $display("[PASS][Pattern]%5d=%5d",golden, out);
                end
                else begin
                    $display("[ERROR][Pattern]%5d not equal to %5d",golden, out);
                end
            end
        end
        if(error == 0)
            $display("All answers match golden");
        else
            $display("None");
       
        $fclose(f_data);
        $fclose(f_golden);

        $finish;
    end

endmodule


