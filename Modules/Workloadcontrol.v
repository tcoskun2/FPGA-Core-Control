`timescale 1ns / 1ps

module Workcontrol(
input newinput,              //tells us when there's new data to be processed
input wire [7:0] temp_core0,
input wire [7:0] temp_core1,
input wire [7:0] temp_core2,
input wire [15:0] task_data,
output reg [15:0] data_out,
output reg [1:0] core_select
    );
    
 localparam Threshold = 8'd75; // threshold in celsius
    
always @(posedge newinput)
begin
    data_out <= task_data;


      //compare and assign to least hot.
        if (temp_core0 <= temp_core1 && temp_core0 <= temp_core2) begin
        core_select <= 2'b00;
        end
        else if (temp_core1 <= temp_core0 && temp_core1 <= temp_core2) begin
        core_select <= 2'b01;
        end
        else begin
        core_select <= 2'b10;
        end

    #5 // delay for 5 nanosecond for core to take in data
    core_select <= 2'b11; //set to no core selected
    
end
   

endmodule
