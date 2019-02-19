`timescale 1ns / 1ps

module lab5_TestBench();
    //Declare wires and registers that will interface with the module under test
    //Registers are initilized to known states. Wires cannot be initilized.                 
    reg sys_clkn=1;
    wire sys_clkp;
    wire [7:0] led;
    reg [3:0] button;
    
    wire ADT7420_A0;
    wire ADT7420_A1;
    wire I2C_SCL_0;
    wire I2C_SDA_0;        
    reg FSM_Clk_reg;    
    reg ILA_Clk_reg;
    reg ACK_bit;
    reg SCL;
    reg SDA;
    wire [7:0] State_out;
    wire [15:0] Temperature; 
    //Invoke the module that we like to test
    I2C_Transmit ModuleUnderTest (.button(button),.led(led),.sys_clkn(sys_clkn),.sys_clkp(sys_clkp), .ADT7420_A0(ADT7420_A0), .ADT7420_A1(ADT7420_A1),
                                  .I2C_SCL_0(), .I2C_SDA_0(), .FSM_CLK_reg(FSM_Clk_reg), .LLA_Clk_reg(ILA_Clk_reg), .ACK_bit(ACK_bit), 
                                  .SCL(SCL), .SDA(SDA), .State_out(State_out), .Temperature(Temperature)   
                                  );
    
    

    
    // Generate a clock signal. The clock will change its state every 5ns.
    //Remember that the test module takes sys_clkp and sys_clkn as input clock signals.
    //From these two signals a clock signal, clk, is derived.
    //The LVDS clock signal, sys_clkn, is always in the opposite state than sys_clkp.     
    assign sys_clkp = ~sys_clkn;    
    always begin
        #5 sys_clkn = ~sys_clkn;
    end        
      
    initial begin          
            #0 button <= 4'b1111;                                                            
            #200 button <= 4'b0111;              //PRESS FOURTH (LEFTMOST BUTTON) to start FSM    
               
    end

endmodule
