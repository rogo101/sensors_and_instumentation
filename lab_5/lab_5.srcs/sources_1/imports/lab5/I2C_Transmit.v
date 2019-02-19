`timescale 1ns / 1ps

module I2C_Transmit(
  
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_0,
    inout  I2C_SDA_0,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,
    output [7:0] State_out,
    output [15:0] Temperature 
    );
    

  
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 100;   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
                                        
    reg [7:0] SingleByteData = 8'b1001_0000; // Address of temp sensor (Write)
    reg [7:0] StartReadData = 8'b1001_0001;  //Address of temp sensor (Read)
    reg [7:0] AddressRegisterData = 8'b0000_0000     ; // Address pointer register MSB
    reg [7:0] State = 8'd0;
    reg [3:0] button_reg; 
    reg error_bit = 1'b1;
    reg running_bit = 1'b1;
    reg [15:0] temperature;
    reg [15:0] final_temperature;      
       
    localparam STATE_INIT = 8'd0;    
    assign led[7] = ACK_bit;
    assign led[6] = error_bit;
    assign led[5] = running_bit;
    assign ADT7420_A0 = 1'b0;
    assign ADT7420_A1 = 1'b0;
    assign I2C_SCL_0 = SCL;
    assign I2C_SDA_0 = SDA; 
    assign State_out = State;
    
    assign Temperature = temperature;
    
    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;   
    end
    
    always @(*) begin
        button_reg = ~button;  
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;  
     
    end  
    
  
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (button_reg[3] == 1'b1) State <= 8'd1;                    
                 else begin
                      temperature <= 0;                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                  end
            end            
            
            // This is the Start sequence            
            8'd1 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1; 
                                            
            end   
            
            8'd2 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

//FRAME 1 Serial Bus Address Byte
            // transmit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[7];
                  State <= State + 1'b1;                 
            end   

            8'd4 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd5 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd6 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[6];  
                  State <= State + 1'b1;               
            end   

            8'd8 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd9 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd10 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[5]; 
                  State <= State + 1'b1;                
            end   

            8'd12 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd13 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd14 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[4]; 
                  State <= State + 1'b1;                
            end   

            8'd16 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd17 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd18 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[3]; 
                  State <= State + 1'b1;                
            end   

            8'd20 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd21 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd22 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[2]; 
                  State <= State + 1'b1;                
            end   

            8'd24 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd25 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd26 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[1];  
                  State <= State + 1'b1;               
            end   

            8'd28 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd29 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd30 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd31 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[0];      
                  State <= State + 1'b1;           
            end   

            8'd32 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd33 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd34 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
//FRAME 2 ADDRESS POINTER REGISTER BYTE
            // transmit bit 7   
            8'd39 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[7];
                  State <= State + 1'b1;                 
            end   

            8'd40 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd41 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd42 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd43 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[6];  
                  State <= State + 1'b1;               
            end   

            8'd44 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd45 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd46 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd47 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[5]; 
                  State <= State + 1'b1;                
            end   

            8'd48 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd49 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd50 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd51 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[4]; 
                  State <= State + 1'b1;                
            end   

            8'd52 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd53 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd54 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd55 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[3]; 
                  State <= State + 1'b1;                
            end   

            8'd56 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd57 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd58 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd59 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[2]; 
                  State <= State + 1'b1;                
            end   

            8'd60 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd61 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd62 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd63 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[1];  
                  State <= State + 1'b1;               
            end   

            8'd64 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd65 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd66 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd67 : begin
                  SCL <= 1'b0;
                  SDA <= AddressRegisterData[0];      
                  State <= State + 1'b1;           
            end   

            8'd68 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd69 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd70 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd71 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd72 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd73 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd74 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            8'd75: begin
                  SCL <= 1'b0;
                  State <= State +1'b1;
            end    
            
            8'd76: begin
                  SCL <= 1'b1;
                  State <= State +1'b1;
            end    
//FRAME 3: REPEATED START WITH READ BIT 
             // This is the Start sequence            
            8'd77 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1; 
                                            
            end   
            
            8'd78 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd79 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[7];
                  State <= State + 1'b1;                 
            end   

            8'd80 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd81 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd82 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd83 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[6];  
                  State <= State + 1'b1;               
            end   

            8'd84 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd85 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd86 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd87 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[5]; 
                  State <= State + 1'b1;                
            end   

            8'd88 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd89 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd90 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd91 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[4]; 
                  State <= State + 1'b1;                
            end   

            8'd92 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd93 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd94 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd95 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[3]; 
                  State <= State + 1'b1;                
            end   

            8'd96 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd97 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd98 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd99 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[2]; 
                  State <= State + 1'b1;                
            end   

            8'd100 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd101 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd102 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd103 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[1];  
                  State <= State + 1'b1;               
            end   

            8'd104 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd105 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd106 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd107 : begin
                  SCL <= 1'b0;
                  SDA <= StartReadData[0];      
                  State <= State + 1'b1;           
            end   

            8'd108 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd109 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd110 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd111 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd112 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd113 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd114 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
//FRAME 4: READ MSB
             
            // transmit bit 7   
            8'd115 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                  
            end   

            8'd116 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd117 : begin
                  SCL <= 1'b1;
                  temperature[15] <= I2C_SDA_0;
                  State <= State + 1'b1;
            end   

            8'd118 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd119 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;  
                  State <= State + 1'b1;
                                 
            end   

            8'd120 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd121 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[14] <= I2C_SDA_0;
            end   

            8'd122 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd123 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;
                                  
            end   

            8'd124 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd125 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[13] <= I2C_SDA_0;
            end   

            8'd126 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd127 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;  
                               
            end   

            8'd128 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd129 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[12] <= I2C_SDA_0;
            end   

            8'd130 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd131 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;               
            end   

            8'd132 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd133 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[11] <= I2C_SDA_0;
            end   

            8'd134 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd135 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;
                                  
            end   

            8'd136 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                 
            end   

            8'd137 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[10] <= I2C_SDA_0;
            end   

            8'd138 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd139 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;  
                  State <= State + 1'b1;
                                 
            end   

            8'd140 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd141 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[9] <= I2C_SDA_0;
            end   

            8'd142 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd143 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;      
                  State <= State + 1'b1; 
                            
            end   

            8'd144 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd145 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[8] <= I2C_SDA_0; 
            end   

            8'd146 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // Master  ACK bit 
            8'd147 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            8'd148 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd149 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd150 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
 //FRAME 5 READ LSB REGISTER  
            // transmit bit 7   
            8'd151 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;
                                   
            end   

            8'd152 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd153 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[7] <= I2C_SDA_0;
            end   

            8'd154 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd155 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;  
                  State <= State + 1'b1;
                                 
            end   

            8'd156 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd157 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[6] <= I2C_SDA_0;
            end   

            8'd158 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd159 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;
                                  
            end   

            8'd160 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd161 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[5] <= I2C_SDA_0;
            end   

            8'd162 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd163 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;
                                  
            end   

            8'd164 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd165 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[4] <= I2C_SDA_0;
            end   

            8'd166 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd167 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;
                              
            end   

            8'd168 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                     
            end   

            8'd169 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[3] <= I2C_SDA_0; 
            end   

            8'd170 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd171 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; 
                  State <= State + 1'b1;
                                 
            end   

            8'd172 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd173 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[2] <= I2C_SDA_0;
            end   

            8'd174 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd175 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;  
                  State <= State + 1'b1; 
                               
            end   

            8'd176 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd177 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[1] <= I2C_SDA_0; 
            end   

            8'd178 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd179 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;      
                  State <= State + 1'b1;  
                          
            end   

            8'd180 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  
            end   

            8'd181 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
                  temperature[0] <= I2C_SDA_0;
            end   

            8'd182 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // Master No ACK bit 
            8'd183 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;
                  State <= State + 1'b1;                 
            end   

            8'd184 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd185 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd186 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            
            
            //stop bit sequence and go back to STATE_INIT           
            8'd187 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;                
                  State <= State + 1'b1;
            end   

            8'd188 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            8'd189 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= 1'b1;                  
            end              
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end                              
        endcase                           
    end                     
endmodule
