
`timescale 1ns / 1ps
//pipeline direct form tb

module fir_pipe_tb;
    parameter inWL = 15;
    parameter macWL = 20;
    parameter Data_Num =500;

    reg signed [inWL-1:0] in;
    reg signed [inWL-1:0] tap;
    wire signed [macWL-1:0] out;
    reg clk;
    reg rst_n;
    
    
    fir_pipe U0(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(in),
        .data_out(out)
    );
    
    initial begin
        $dumpfile("fir.vcd");
        $dumpvars();
    end

//this is for pipline direct form 
    reg signed [inWL-1:0]  in_list[0:(Data_Num-1)];
    reg signed [macWL-1:0] Gold_list[0:(Data_Num-1)];
    reg signed [macWL-1:0] out_list[0:(Data_Num-1)];

    reg [31:0]  cnt;
    integer A,golden, f_data,f_golden, jj;
    initial begin
        cnt = 0;
        A = $fopen("/home/ubuntu/dspic_final_submit/dsp_final/data/HW_input.txt","r");
        golden = $fopen("/home/ubuntu/dspic_final_submit/dsp_final/data/HW_golden.txt","r");

        for(jj=0;jj<Data_Num;jj=jj+1) begin
            f_data = $fscanf(A,"%d", in_list[jj]);
            f_golden = $fscanf(golden,"%d", Gold_list[jj]);
            cnt = cnt + 1;
        end
    end
    reg error;
    initial begin
        clk = 1'b0;
        error = 0;
        #1 rst_n = 1'b0;
        #10 rst_n = 1'b1;
    end
    always begin
        #5 clk = ~clk;
    end

    integer i,j,k;
    
    initial begin
        for(i=0;i<(cnt);i=i+1)begin
            @(negedge clk)in = in_list[i];
        end
    end
    
    // testing
    initial begin
        @(posedge clk);
        @(posedge clk);
        #355; 
        for(k=0;k<(cnt);k=k+1)begin
            @(posedge clk) out_list[k] = out;
        end
        @(posedge clk)
        for(j=0;j<(cnt);j=j+1)begin
            if(out_list[j] == Gold_list[j])
                $display("[PASS][Pattern %3d]%5d=%5d", j, Gold_list[j], out_list[j]);
            else begin
                $display("[ERROR][Pattern %3d]%5d=%5d", j, Gold_list[j], out_list[j]);
                error = 1;
            end
        end
        if(error == 0)
            $display("All answers match golden");
        else
            $display("None");
        $finish;
    end
endmodule


/*

//transposed form tb

module fir_tb;
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



/*
//direct form
module fir_tb;
    parameter inWL = 15;
    parameter macWL = 20;
    parameter Data_Num =500;

    reg signed [inWL-1:0] in;
    reg signed [inWL-1:0] tap;
    wire signed [macWL-1:0] out;
    reg clk;
    reg rst_n;
    //this is for test direct form module
    
    fir U0(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(in),
        .data_out(out)
    );

    initial begin
        $dumpfile("fir.vcd");
        $dumpvars();
    end

    reg signed [inWL-1:0]  in_list[0:(Data_Num-1)];
    reg signed [macWL-1:0] Gold_list[0:(Data_Num-1)];
    reg signed [macWL-1:0] out_list[0:(Data_Num-1)];

    reg [31:0]  cnt;
    integer A,golden, f_data,f_golden, jj;
    initial begin
        cnt = 0;
        A = $fopen("/home/ubuntu/dspic_final_submit/dsp_final/data/HW_input.txt","r");
        golden = $fopen("/home/ubuntu/dspic_final_submit/dsp_final/data/HW_golden.txt","r");

        for(jj=0;jj<Data_Num;jj=jj+1) begin
            f_data = $fscanf(A,"%d", in_list[jj]);
            f_golden = $fscanf(golden,"%d", Gold_list[jj]);
            cnt = cnt + 1;
        end
    end
    reg error;
    initial begin
        clk = 1'b0;
        error = 0;
        #1 rst_n = 1'b0;
        #10 rst_n = 1'b1;
    end
    always begin
        #5 clk = ~clk;
    end
        

    integer i,j,k;
    initial begin
        for(i=0;i<(cnt);i=i+1)begin
            @(negedge clk)in = in_list[i];
        end
    end
    // testing
    initial begin  
        @(posedge clk);
        @(posedge clk);
        
        for(k=0;k<(cnt);k=k+1)begin
            @(posedge clk) out_list[k] = out;
        end
        @(posedge clk)
        for(j=0;j<(cnt);j=j+1)begin
            if(out_list[j] == Gold_list[j])
                $display("[PASS][Pattern %3d]%5d=%5d", j, Gold_list[j], out_list[j]);
            else begin
                $display("[ERROR][Pattern %3d]%5d=%5d", j, Gold_list[j], out_list[j]);
                error = 1;
            end
        end
        if(error == 0)
            $display("All answers match golden");
        else
            $display("None");
        $finish;
    end
endmodule
*/