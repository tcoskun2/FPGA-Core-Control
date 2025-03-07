module uart_transmitter(
    input        tranclk,      // System clock (each clock = 1 bit time)
    input  [7:0] temp1,    
    input  [7:0] temp2,    
    input  [7:0] temp3,   
    output  reg  tx        // UART TX output
);

    reg [3:0] bit_idx = 0;   // Bit counter for transmission (0-9)
    reg [1:0] byte_idx = 0;  // which core
    reg [9:0] shift_reg;     // entire transmission
    reg       sending = 0;   // Sending flag

    always @(posedge tranclk) begin
        if (!sending) begin
            // Load new byte into shift register when idle
            shift_reg <= {1'b1,  // Stop bit 
                          (byte_idx == 0) ? temp1 :     //if sending first core
                          (byte_idx == 1) ? temp2 : temp3,  // if sending second or third
                          1'b0}; // Start bit 
            sending <= 1;   // set up for transmission
            bit_idx <= 0; 
        end else begin
            // Shift out data bit-by-bit
            tx = shift_reg[0];  
            shift_reg <= shift_reg >> 1; //shift one bit
            bit_idx <= bit_idx + 1;

            // When all 10 bits are sent, move to next byte
            if (bit_idx == 9) begin
                sending <= 0;   //end transmission
                byte_idx <= (byte_idx == 2) ? 0 : byte_idx + 1; //either move to next byte or reset
            end
        end
    end
endmodule


module uart_receiver(
    input        tranclk,         // System clock (each clock = 1 bit time)
    input        rx,          // UART RX input
    output reg [7:0] temp_core0, 
    output reg [7:0] temp_core1, 
    output reg [7:0] temp_core2  
);

    reg [3:0] bit_idx = 0;   // Bit counter (0-9)
    reg [1:0] byte_idx = 0;  // Which core
    reg [9:0] shift_reg;     // entire transmission
    reg       receiving = 0; // Receiving flag

    always @(posedge tranclk) begin
        if (!receiving) begin
            // Detect start bit 
            if (rx == 0) begin
                receiving <= 1;
                bit_idx <= 0;
            end
        end else begin
            // Shift in data 
            shift_reg <= {rx, shift_reg[9:1]};
            bit_idx <= bit_idx + 1;

            // When all 10 bits are received, store the byte
            if (bit_idx == 9) begin
                receiving <= 0;
                case (byte_idx)
                    0: temp_core0 <= shift_reg[8:1]; // Extract data
                    1: temp_core1 <= shift_reg[8:1];
                    2: temp_core2 <= shift_reg[8:1];
                endcase
                byte_idx <= (byte_idx == 2) ? 0 : byte_idx + 1;
            end
        end
    end
endmodule
