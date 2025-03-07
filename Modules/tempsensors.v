
module tempsensors(
    input  wire    tempclk,   // How often to update temps (for verification)
    output wire [7:0]  temp1,
    output wire [7:0]  temp2, 
    output wire [7:0]  temp3 
);

    // Internal counters for each sensor
    reg [7:0] counter1 = 8'd30;
    reg [7:0] counter2 = 8'd40;
    reg [7:0] counter3 = 8'd50;

    always @(posedge tempclk) begin //This very simply simulates sensors.
        if (counter1 < 8'd90)
            counter1 <= counter1 + 1;
        else
            counter1 <= 8'd30;
            
        if (counter2 < 8'd90)
            counter2 <= counter2 + 1;
        else
            counter2 <= 8'd30;
            
        if (counter3 < 8'd90)
            counter3 <= counter3 + 1;
        else
            counter3 <= 8'd30;
    end

    assign temp1 = counter1;
    assign temp2 = counter2;
    assign temp3 = counter3;

endmodule
