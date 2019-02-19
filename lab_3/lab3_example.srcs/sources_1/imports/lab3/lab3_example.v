`timescale 1ns / 1ps
module lab3_example(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp  
    );

    reg [2:0] state = 0;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg;    
                
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    assign led = ~led_register; //map led wire to led_register
    localparam NORTH_RED_EAST_GREEN       = 3'd0;
    localparam NORTH_RED_EAST_YELLOW      = 3'd1;
    localparam NORTH_GREEN_EAST_RED      = 3'd2;
    localparam NORTH_YELLOW_EAST_RED    = 3'd3;
    localparam PEDESTRIAN_GREEN    = 3'd3;                 
      
    always @(posedge clk)
    begin       
        button_reg = ~button;
        state <= NORTH_RED_EAST_GREEN;
        begin
            case (state)
                NORTH_RED_EAST_GREEN : begin
                    if (button_reg == (4'b1111)) state <= NORTH_RED_EAST_YELLOW;                    
                    else state <= PEDESTRIAN_GREEN;                                                                        
                end

                NORTH_RED_EAST_YELLOW : begin
                    if (button_reg == 4'b1111) state <= NORTH_GREEN_EAST_RED;                    
                    else state <= PEDESTRIAN_GREEN;                                                                        
                end

                NORTH_GREEN_EAST_RED : begin
                    if (button_reg == 4'b1111) state <= NORTH_YELLOW_EAST_RED;                    
                    else state <= PEDESTRIAN_GREEN;                                                                        
                end

                NORTH_YELLOW_EAST_RED : begin
                    if (button_reg == 4'b1111) state <= NORTH_RED_EAST_GREEN;                    
                    else state <= PEDESTRIAN_GREEN;                                                                        
                end
                
                PEDESTRIAN_GREEN : begin
                    
                end
                
                default: state <= NORTH_RED_EAST_GREEN;
                
            endcase
        end                           
    end    
endmodule

