`timescale 1ns / 1ps


module testing;

  reg         clk;       
  reg         fanclk;    
  reg         sensor_clk;  // Clock for updating temperature sensors
  reg         newinput;    // signal to trigger new task 
  reg  [15:0] task_data;   // Example task data

  // Wires between modules
  wire [7:0] sensor_temp1, sensor_temp2, sensor_temp3; // From tempsensors
  wire       tx;              // UART transmitter output
  
  
  wire [7:0] temp_core0, temp_core1, temp_core2; // UART receiver outputs

  wire       fan;           // fan control output
  wire [15:0] data_out;     // Workcontrol output data
  wire [1:0] core_select;   // Workcontrol core selection output

  // Temperature Sensors
  tempsensors uut_tempsensors (
    .tempclk(sensor_clk),
    .temp1(sensor_temp1),
    .temp2(sensor_temp2),
    .temp3(sensor_temp3)
  );

  // UART Transmitter
  uart_transmitter uut_uart_tx (
    .tranclk(clk),
    .temp1(sensor_temp1),
    .temp2(sensor_temp2),
    .temp3(sensor_temp3),
    .tx(tx)
  );

  // UART Receiver
  uart_receiver uut_uart_rx (
    .tranclk(clk),
    .rx(tx), 
    .temp_core0(temp_core0),
    .temp_core1(temp_core1),
    .temp_core2(temp_core2)
  );

  // Workcontrol module
  Workcontrol uut_workcontrol (
    .newinput(newinput),
    .temp_core0(temp_core0),
    .temp_core1(temp_core1),
    .temp_core2(temp_core2),
    .task_data(task_data),
    .data_out(data_out),
    .core_select(core_select)
  );

  // PWM Fan Control module
  PWM_fan_control uut_pwm (
    .temp_core0(temp_core0),
    .temp_core1(temp_core1),
    .temp_core2(temp_core2),
    .clk(fanclk), 
    .fan(fan)
  );

  // Generate system clock (clk) - period 10 ns
  initial begin
    clk = 0;
    forever #4 clk = ~clk;
  end
  
  initial begin
    fanclk = 0;
    forever #0.004 fanclk = ~fanclk;
  end

  // Generate sensor clock 
  initial begin
    sensor_clk = 0;
    forever #16 sensor_clk = ~sensor_clk;
  end

  // simulate new task arrival to see which core gets load
  initial begin
    newinput = 0;
    forever begin
      #100 newinput = 1;
      #10 newinput = 0;
    end
  end

  // scrap test value
  initial begin
    task_data = 16'd1234;
  end

  // Run simulation
  initial begin
    #5000;
    $finish;
  end

endmodule