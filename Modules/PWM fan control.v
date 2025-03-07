


module PWM_fan_control(
    input wire [7:0] temp_core0, //temps range from 30 to 90 C
    input wire [7:0] temp_core1,
    input wire [7:0] temp_core2,
    
    input clk, //For a 25khz pwm fan, we will need a clock frequency of 6.4MHz
    output reg fan
    );
    
    localparam lowthreshold = 8'd50;
    localparam highthreshold = 8'd70;
    
    reg [7:0] pwm_counter = 0;
    reg [7:0] pulse_length = 8'd25; //acts like duty cycle
    reg [7:0] max_temp = 8'd30;

    always @(posedge clk)begin
    
        if (temp_core0 >= temp_core1 && temp_core0 >= temp_core2)
          max_temp <= temp_core0;
       else if (temp_core1 >= temp_core0 && temp_core1 >= temp_core2)
           max_temp <= temp_core1;
       else
           max_temp <= temp_core2;
    
        if (max_temp > highthreshold)
            pulse_length <= 8'd255; // 100% duty cycle
        else if (max_temp < lowthreshold)
            pulse_length <= 8'd25;  // 10% duty cycle
        else                        //when between the two thresholds, linearly increase speed
            pulse_length <= 8'd25 + (230 * (max_temp - lowthreshold)) / (highthreshold - lowthreshold);
            
         pwm_counter <= pwm_counter + 8'd1;
         if (pwm_counter >= 8'd255)begin
            pwm_counter <= 8'd0;end
            fan <= (pwm_counter < pulse_length) ? 1:0;
    end
    
    
    
endmodule
