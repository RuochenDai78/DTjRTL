//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES top file                                                ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  AES top                                                     ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:57  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:22  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module aes(clk,reset,load_i,decrypt_i,data_i,key_i,ready_o,data_o);

input clk;
input reset;
input load_i;
input decrypt_i;
input [127:0] data_i;
input [127:0] key_i;
output ready_o;
output [127:0] data_o;

reg ready_o;
reg [127:0] data_o;

reg next_ready_o;

reg keysched_start_i;
reg [3:0] keysched_round_i;
reg [127:0] keysched_last_key_i;
wire [127:0] keysched_new_key_o;
wire keysched_ready_o;
wire keysched_sbox_access_o;
wire [7:0] keysched_sbox_data_o;
wire keysched_sbox_decrypt_o;

reg mixcol_start_i;
reg [127:0] mixcol_data_i;
wire mixcol_ready_o;
wire [127:0] mixcol_data_o;

reg subbytes_start_i;
reg [127:0] subbytes_data_i;
wire subbytes_ready_o;
wire [127:0] subbytes_data_o;
wire [7:0] subbytes_sbox_data_o;
wire subbytes_sbox_decrypt_o;

wire [7:0] sbox_data_o;
reg [7:0] sbox_data_i;
reg sbox_decrypt_i;

reg state;
reg next_state;
reg [3:0] round;
reg [3:0] next_round;
reg [127:0] addroundkey_data_o;
reg [127:0] next_addroundkey_data_reg;
reg [127:0] addroundkey_data_reg;
reg [127:0] addroundkey_data_i;
reg addroundkey_ready_o;
reg next_addroundkey_ready_o;
reg addroundkey_start_i;
reg next_addroundkey_start_i;
reg [3:0] addroundkey_round;
reg [3:0] next_addroundkey_round;
reg first_round_reg;
reg next_first_round_reg;

sbox sbox1 (.clk(clk), .reset(reset), .data_i(sbox_data_i), .decrypt_i(sbox_decrypt_i), .data_o(sbox_data_o));
subbytes sub1 (.clk(clk), .reset(reset), .start_i(subbytes_start_i), .decrypt_i(decrypt_i), .data_i(subbytes_data_i), .ready_o(subbytes_ready_o), .data_o(subbytes_data_o), .sbox_data_o(subbytes_sbox_data_o), .sbox_data_i(sbox_data_o), .sbox_decrypt_o(subbytes_sbox_decrypt_o));
mixcolum mix1 (.clk(clk), .reset(reset), .decrypt_i(decrypt_i), .start_i(mixcol_start_i), .data_i(mixcol_data_i), .ready_o(mixcol_ready_o), .data_o(mixcol_data_o));
keysched ks1 (.clk(clk), .reset(reset), .start_i(keysched_start_i), .round_i(keysched_round_i), .last_key_i(keysched_last_key_i), .new_key_o(keysched_new_key_o), .ready_o(keysched_ready_o), .sbox_access_o(keysched_sbox_access_o), .sbox_data_o(keysched_sbox_data_o), .sbox_data_i(sbox_data_o), .sbox_decrypt_o(keysched_sbox_decrypt_o));

//registers:
always @(posedge clk or negedge reset)
begin

  if(!reset)
  begin

    state = (0);
    ready_o = (0);
    round = (0);
    addroundkey_round = (0);
    addroundkey_data_reg = (0);
    addroundkey_ready_o = (0);
    addroundkey_start_i = (0);
    first_round_reg = (0);

  end
  else
  begin

    state = (next_state);
    ready_o = (next_ready_o);
    round = (next_round);
    addroundkey_round = (next_addroundkey_round);
    addroundkey_data_reg = (next_addroundkey_data_reg);
    addroundkey_ready_o = (next_addroundkey_ready_o);
    first_round_reg = (next_first_round_reg);
    addroundkey_start_i = (next_addroundkey_start_i);

  end

end


//control:
always @(state or round or addroundkey_data_o or data_i or load_i or decrypt_i or addroundkey_ready_o or mixcol_ready_o or subbytes_ready_o or subbytes_data_o or mixcol_data_o or first_round_reg)
begin
	
  next_state = (state);
  next_round = (round);
  data_o = (addroundkey_data_o);
  next_ready_o = (0);
	
  //To key schedule module
				
  next_first_round_reg = (0);
	
  subbytes_data_i = (0);	
  mixcol_data_i = (0);
  addroundkey_data_i = (0);
  next_addroundkey_start_i = (first_round_reg);
  mixcol_start_i = ((addroundkey_ready_o&decrypt_i&round!=10)|(subbytes_ready_o&!decrypt_i));
  subbytes_start_i = ((addroundkey_ready_o&!decrypt_i)|(mixcol_ready_o&decrypt_i)|(addroundkey_ready_o&decrypt_i&round==10));	
		
  if(decrypt_i&&round!=10)
    begin
     
      addroundkey_data_i = (subbytes_data_o);
      subbytes_data_i = (mixcol_data_o);
      mixcol_data_i = (addroundkey_data_o);
    
    end
    else if(!decrypt_i&&round!=0)
    begin
     
      addroundkey_data_i = (mixcol_data_o);	
      subbytes_data_i = (addroundkey_data_o);
      mixcol_data_i = (subbytes_data_o);
    
    end
    else
    begin
	
      mixcol_data_i = (subbytes_data_o);
      subbytes_data_i = (addroundkey_data_o);
      addroundkey_data_i = (data_i);
   
    end


    case(state)
		
      0:
       begin
         if(load_i)
         begin
        
           next_state = (1);

           if(decrypt_i)
             next_round = (10);
           else
             next_round = (0);

           next_first_round_reg = (1);

         end
       end
			
      1:
       begin
	
        //Counter	
        if(!decrypt_i&&mixcol_ready_o)
        begin
         
          next_addroundkey_start_i = (1);
          addroundkey_data_i = (mixcol_data_o);	
          next_round = (round+1);

        end
        else if(decrypt_i&&subbytes_ready_o)
        begin
 
          next_addroundkey_start_i = (1);
          addroundkey_data_i = (subbytes_data_o);
          next_round = (round-1);
 
        end

        //Output
        if((round==9&&!decrypt_i)||(round==0&&decrypt_i))
        begin
 
          next_addroundkey_start_i = (0);
          mixcol_start_i = (0);

          if(subbytes_ready_o)
          begin
 
            addroundkey_data_i = (subbytes_data_o);
            next_addroundkey_start_i = (1);
            next_round = (round+1);
 
         end
 
        end

        if((round==10&&!decrypt_i)||(round==0&&decrypt_i))
        begin

          addroundkey_data_i = (subbytes_data_o);
          subbytes_start_i = (0);

          if(addroundkey_ready_o)
          begin
 
            next_ready_o = (1);
            next_state = (0);
            next_addroundkey_start_i = (0);
            next_round = (0);
      
          end
	
        end
 			
       end
			
    default:
     begin
  
       next_state = (0);

     end

  endcase

end


//addroundkey:
reg[127:0] data_var,round_data_var,round_key_var;
always @(addroundkey_data_i or addroundkey_start_i or addroundkey_data_reg or addroundkey_round or keysched_new_key_o or keysched_ready_o or key_i or round)
begin

  round_data_var=addroundkey_data_reg;
  next_addroundkey_data_reg = (addroundkey_data_reg);
  next_addroundkey_ready_o = (0);
  next_addroundkey_round = (addroundkey_round);
  addroundkey_data_o = (addroundkey_data_reg);
	
  if(addroundkey_round==1||addroundkey_round==0)
    keysched_last_key_i = (key_i);
  else
    keysched_last_key_i = (keysched_new_key_o);
	
  keysched_start_i = (0);
	
  keysched_round_i = (addroundkey_round);
		
  if(round==0&&addroundkey_start_i)
  begin

    //Take the input and xor them with data if round==0;
    data_var=addroundkey_data_i;	
    round_key_var=key_i;
    round_data_var=round_key_var^data_var;
    next_addroundkey_data_reg = (round_data_var);
    next_addroundkey_ready_o = (1);
	
  end
  else if(addroundkey_start_i&&round!=0)
  begin

    keysched_last_key_i = (key_i);	
    keysched_start_i = (1);
    keysched_round_i = (1);
    next_addroundkey_round = (1);
	
  end
  else if(addroundkey_round!=round&&keysched_ready_o)
  begin

    next_addroundkey_round = (addroundkey_round+1);
    keysched_last_key_i = (keysched_new_key_o);
    keysched_start_i = (1);
    keysched_round_i = (addroundkey_round+1);
	
  end
  else if(addroundkey_round==round&&keysched_ready_o)
  begin

    data_var=addroundkey_data_i;	
    round_key_var=keysched_new_key_o;
    round_data_var=round_key_var^data_var;
    next_addroundkey_data_reg = (round_data_var);
    next_addroundkey_ready_o = (1);
    next_addroundkey_round = (0);

  end

end

//sbox_muxes:
always @(keysched_sbox_access_o or keysched_sbox_decrypt_o or keysched_sbox_data_o or subbytes_sbox_decrypt_o or subbytes_sbox_data_o)
begin
	
  if(keysched_sbox_access_o)
  begin

    sbox_decrypt_i = (keysched_sbox_decrypt_o);
    sbox_data_i = (keysched_sbox_data_o);
	
  end
  else
  begin

    sbox_decrypt_i = (subbytes_sbox_decrypt_o);
    sbox_data_i = (subbytes_sbox_data_o);
	
  end

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Mixcolumns for 8 bit                                        ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Mixcolum for a byte                                         ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:57  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:22  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module byte_mixcolum(a,b,c,d,outx,outy);

input [7:0] a,b,c,d;
output [7:0] outx, outy;

reg [7:0] outx, outy;

function [7:0] xtime;

  input [7:0] in;
  reg [3:0] xtime_t;

  begin

    xtime[7:5] = in[6:4];
    xtime_t[3] = in[7];
    xtime_t[2] = in[7];
    xtime_t[1] = 0;
    xtime_t[0] = in[7];
    xtime[4:1] =xtime_t^in[3:0];
    xtime[0] = in[7];

  end

endfunction

reg [7:0] w1,w2,w3,w4,w5,w6,w7,w8,outx_var;

always @ (a, b, c, d)
begin
 
  w1 = a ^b;
  w2 = a ^c;
  w3 = c ^d;
  w4 = xtime(w1);
  w5 = xtime(w3);
  w6 = w2 ^w4 ^w5;
  w7 = xtime(w6);
  w8 = xtime(w7);

  outx_var = b^w3^w4;
  outx=outx_var;
  outy=w8^outx_var;

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Key schedule                                                ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Generate the next round key from the previous one           ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:57  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:22  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module keysched(clk,reset,start_i,round_i,last_key_i,new_key_o,ready_o,sbox_access_o,sbox_data_o,sbox_data_i,sbox_decrypt_o);

input clk;
input reset;
input start_i;
input [3:0] round_i;
input [127:0] last_key_i;
output [127:0] new_key_o;
output ready_o;
output sbox_access_o;
output [7:0] sbox_data_o;
input [7:0] sbox_data_i;
output sbox_decrypt_o;

reg [127:0] new_key_o;
reg ready_o;
reg sbox_access_o;
reg [7:0] sbox_data_o;
reg sbox_decrypt_o;

reg [2:0] next_state;
reg [2:0] state/*verilator public*/;
reg [7:0] rcon_o;
reg [31:0] next_col;
reg [31:0] col;
reg [127:0] key_reg;
reg [127:0] next_key_reg;
reg next_ready_o;


//rcon:
always @(  round_i)
begin

  case(round_i)

    1:
     begin
       rcon_o = (1);
     end
    2:
     begin
       rcon_o = (2);
     end
    3:
     begin
       rcon_o = (4);
     end
    4:
     begin
       rcon_o = (8);
     end
    5:
     begin
       rcon_o = ('h10);
     end
    6:
     begin
       rcon_o = ('h20);
     end
    7:
     begin
       rcon_o = ('h40);
     end
    8:
     begin
       rcon_o = ('h80);
     end
    9:
     begin
       rcon_o = ('h1B);
     end
   10:
     begin
       rcon_o = ('h36);
     end
   default:
     begin
       rcon_o = (0);
     end
  endcase

end


//registers:
always @(posedge clk or negedge reset)
begin

  if(!reset)
    begin
 
      state = (0);
      col = (0);
      key_reg = (0);
      ready_o = (0);

    end
    else
    begin
	
      state = (next_state);	
      col = (next_col);
      key_reg = (next_key_reg);
      ready_o = (next_ready_o);

    end

end


//generate_key:
reg[127:0] K_var,W_var;
reg[31:0] col_t;
reg[23:0] zero;
	
always @(start_i or last_key_i or sbox_data_i or state or rcon_o or col or key_reg)
begin

  zero=0;
	
  col_t=col;
  W_var=0;
	
  next_state = (state);
  next_col = (col);
	
  next_ready_o = (0);
  next_key_reg = (key_reg);
  new_key_o = (key_reg);
	
  sbox_decrypt_o = (0);
  sbox_access_o = (0);
  sbox_data_o = (0);
  K_var=last_key_i;
		
  case(state)
  //Substitute the bytes while rotating them
  //Four accesses to SBox are needed

    0:
     begin
       if(start_i)
       begin
	
         col_t=0;
         sbox_access_o = (1);
         sbox_data_o = (K_var[31:24]);
         next_state = (1);
	
       end
     end

    1:
     begin
	
       sbox_access_o = (1);
       sbox_data_o = (K_var[23:16]);
       col_t[7:0]=sbox_data_i;
       next_col = (col_t);
       next_state = (2);

     end

    2:
     begin

       sbox_access_o = (1);
       sbox_data_o = (K_var[15:8]);
       col_t[31:24]=sbox_data_i;
       next_col = (col_t);
       next_state = (3);

     end

    3:
     begin

       sbox_access_o = (1);
       sbox_data_o = (K_var[7:0]);	
       col_t[23:16]=sbox_data_i;
       next_col = (col_t);
       next_state = (4);
 
     end

    4:
     begin

       sbox_access_o = (1);
       col_t[15:8]=sbox_data_i;
       next_col = (col_t);
       W_var[127:96]=col_t^K_var[127:96]^{rcon_o,zero};		
       W_var[95:64]=W_var[127:96]^K_var[95:64];
       W_var[63:32]=W_var[95:64]^K_var[63:32];
       W_var[31:0]=W_var[63:32]^K_var[31:0];
       next_ready_o = (1);
       next_key_reg = (W_var);	
       next_state = (0);

     end

    default:
     begin
       
       next_state = (0);

     end

  endcase

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Mixcolumns module implementation                            ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Mixcolum module                                             ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:57  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:22  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module mixcolum(clk,reset,decrypt_i,start_i,data_i,ready_o,data_o);
input clk;
input reset;
input decrypt_i;
input start_i;
input [127:0] data_i;
output ready_o;
output [127:0] data_o;

reg ready_o;
reg [127:0] data_o;

reg [127:0] data_reg;
reg [127:0] next_data_reg;
reg [127:0] data_o_reg;
reg [127:0] next_data_o;
reg next_ready_o;
reg [1:0] state;
reg [1:0] next_state;

wire [31:0] outx;
wire [31:0] outy;

reg [31:0] mix_word;
reg [31:0] outmux;

word_mixcolum w1 (.in(mix_word), .outx(outx), .outy(outy));

//assign_data_o:
always @(data_o_reg)
begin

  data_o = (data_o_reg);

end


//mux:
always @(outx or outy or decrypt_i)
begin

  outmux = (decrypt_i?outy:outx);

end


//registers:
always @(posedge clk or negedge reset)
begin

  if(!reset)
  begin

    data_reg = (0);
    state = (0);
    ready_o = (0);
    data_o_reg = (0);
  end
  else			  
  begin

    data_reg = (next_data_reg);
    state = (next_state);
    ready_o = (next_ready_o);
    data_o_reg = (next_data_o);

  end

end


//mixcol:
reg[127:0] data_i_var;
reg[31:0] aux;
reg[127:0] data_reg_var;

always @(decrypt_i or start_i or state or data_reg or outmux or data_o_reg or data_i)
begin

  data_i_var=data_i;
  data_reg_var=data_reg;
  next_data_reg = (data_reg);
  next_state = (state);
	
  mix_word = (0);
	
  next_ready_o = (0);
  next_data_o = (data_o_reg);
		
  case(state)

    0:
      begin
        if(start_i)
        begin
          aux=data_i_var[127:96];
          mix_word = (aux);
          data_reg_var[127:96]=outmux;
          next_data_reg = (data_reg_var);
          next_state = (1);
        end
      end
    1:
      begin
        aux=data_i_var[95:64];
        mix_word = (aux);
        data_reg_var[95:64]=outmux;
        next_data_reg = (data_reg_var);
        next_state = (2);
      end
    2:
      begin
        aux=data_i_var[63:32];
        mix_word = (aux);
        data_reg_var[63:32]=outmux;
        next_data_reg = (data_reg_var);
        next_state = (3);
      end
    3:
      begin
        aux=data_i_var[31:0];
        mix_word = (aux);
        data_reg_var[31:0]=outmux;
        next_data_o = (data_reg_var);
        next_ready_o = (1);
        next_state = (0);
      end	
    default:
      begin
      end

endcase

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  S-Box calculation                                           ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  S-box calculation calculating inverse on gallois field      ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:57  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:22  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module sbox(clk,reset,data_i,decrypt_i,data_o);
input clk;
input reset;
input [7:0] data_i;
input decrypt_i;
output [7:0] data_o;

reg [7:0] data_o;

reg [7:0] inva;
reg [3:0] ah;
reg [3:0] al;
reg [3:0] ah2;
reg [3:0] al2;
reg [3:0] alxh;
reg [3:0] alph;
reg [3:0] d;
reg [3:0] ahp;
reg [3:0] alp;
reg [3:0] to_invert;
reg [3:0] next_to_invert;
reg [3:0] ah_reg;
reg [3:0] next_ah_reg;
reg [3:0] next_alph;


//registers:
always @(posedge clk or negedge reset)
begin

  if(!reset)
  begin
 
    to_invert = (0);
    ah_reg = (0);
    alph = (0);	
  
  end
  else
  begin
    
    to_invert = (next_to_invert);
    ah_reg = (next_ah_reg);
    alph = (next_alph);	

  end

end


//first_mux:
reg[7:0] first_mux_data_var;
reg[7:0] first_mux_InvInput;
reg[3:0] first_mux_ah_t,first_mux_al_t;
reg first_mux_aA,first_mux_aB,first_mux_aC,first_mux_aD;
	
always @(data_i or decrypt_i)
begin

  first_mux_data_var=data_i;
  first_mux_InvInput=first_mux_data_var;
	
  case(decrypt_i)
    1:
     begin
      
       //Apply inverse affine trasformation
       first_mux_aA=first_mux_data_var[0]^first_mux_data_var[5];first_mux_aB=first_mux_data_var[1]^first_mux_data_var[4];
       first_mux_aC=first_mux_data_var[2]^first_mux_data_var[7];first_mux_aD=first_mux_data_var[3]^first_mux_data_var[6];
       first_mux_InvInput[0]=(!first_mux_data_var[5])^first_mux_aC;
       first_mux_InvInput[1]=first_mux_data_var[0]^first_mux_aD;
       first_mux_InvInput[2]=(!first_mux_data_var[7])^first_mux_aB;
       first_mux_InvInput[3]=first_mux_data_var[2]^first_mux_aA;
       first_mux_InvInput[4]=first_mux_data_var[1]^first_mux_aD;
       first_mux_InvInput[5]=first_mux_data_var[4]^first_mux_aC;
       first_mux_InvInput[6]=first_mux_data_var[3]^first_mux_aA;
       first_mux_InvInput[7]=first_mux_data_var[6]^first_mux_aB;

     end

   default:
     begin

       first_mux_InvInput=first_mux_data_var;
     
     end

  endcase
	
	
  //Convert elements from GF(2^8) into two elements of GF(2^4^2)
	
  first_mux_aA=first_mux_InvInput[1]^first_mux_InvInput[7];
  first_mux_aB=first_mux_InvInput[5]^first_mux_InvInput[7];
  first_mux_aC=first_mux_InvInput[4]^first_mux_InvInput[6];
	
  first_mux_al_t[0]=first_mux_aC^first_mux_InvInput[0]^first_mux_InvInput[5];
  first_mux_al_t[1]=first_mux_InvInput[1]^first_mux_InvInput[2];
  first_mux_al_t[2]=first_mux_aA;
  first_mux_al_t[3]=first_mux_InvInput[2]^first_mux_InvInput[4];
	
  first_mux_ah_t[0]=first_mux_aC^first_mux_InvInput[5];
  first_mux_ah_t[1]=first_mux_aA^first_mux_aC;
  first_mux_ah_t[2]=first_mux_aB^first_mux_InvInput[2]^first_mux_InvInput[3];
  first_mux_ah_t[3]=first_mux_aB;

  al = (first_mux_al_t);
  ah = (first_mux_ah_t);
  next_ah_reg = (first_mux_ah_t);
 
end
//end_mux:


reg[7:0] end_mux_data_var,end_mux_data_o_var;
reg end_mux_aA,end_mux_aB,end_mux_aC,end_mux_aD;

always @(decrypt_i or inva)
begin

  //Take the output of the inverter
  end_mux_data_var=inva;

  case(decrypt_i)

    0:
     begin
       //Apply affine trasformation

       end_mux_aA=end_mux_data_var[0]^end_mux_data_var[1];end_mux_aB=end_mux_data_var[2]^end_mux_data_var[3];
       end_mux_aC=end_mux_data_var[4]^end_mux_data_var[5];end_mux_aD=end_mux_data_var[6]^end_mux_data_var[7];
       end_mux_data_o_var[0]=(!end_mux_data_var[0])^end_mux_aC^end_mux_aD;
       end_mux_data_o_var[1]=(!end_mux_data_var[5])^end_mux_aA^end_mux_aD;
       end_mux_data_o_var[2]=end_mux_data_var[2]^end_mux_aA^end_mux_aD;
       end_mux_data_o_var[3]=end_mux_data_var[7]^end_mux_aA^end_mux_aB;
       end_mux_data_o_var[4]=end_mux_data_var[4]^end_mux_aA^end_mux_aB;
       end_mux_data_o_var[5]=(!end_mux_data_var[1])^end_mux_aB^end_mux_aC;
       end_mux_data_o_var[6]=(!end_mux_data_var[6])^end_mux_aB^end_mux_aC;
       end_mux_data_o_var[7]=end_mux_data_var[3]^end_mux_aC^end_mux_aD;
 
       data_o = (end_mux_data_o_var);
     end

    default:
     begin

       data_o = (end_mux_data_var);
     end
  endcase

end


//inversemap:
reg[3:0] aA,aB;
reg[3:0] inversemap_alp_t,inversemap_ahp_t;
reg[7:0] inversemap_inva_t;

always @(alp or ahp)
begin
	
  inversemap_alp_t=alp;
  inversemap_ahp_t=ahp;
	
  aA=inversemap_alp_t[1]^inversemap_ahp_t[3];
  aB=inversemap_ahp_t[0]^inversemap_ahp_t[1];

  inversemap_inva_t[0]=inversemap_alp_t[0]^inversemap_ahp_t[0];
  inversemap_inva_t[1]=aB^inversemap_ahp_t[3];
  inversemap_inva_t[2]=aA^aB;
  inversemap_inva_t[3]=aB^inversemap_alp_t[1]^inversemap_ahp_t[2];
  inversemap_inva_t[4]=aA^aB^inversemap_alp_t[3];
  inversemap_inva_t[5]=aB^inversemap_alp_t[2];
  inversemap_inva_t[6]=aA^inversemap_alp_t[2]^inversemap_alp_t[3]^inversemap_ahp_t[0];
  inversemap_inva_t[7]=aB^inversemap_alp_t[2]^inversemap_ahp_t[3];

  inva = (inversemap_inva_t);

end

//mul1:
reg[3:0] mul1_alxh_t;
reg[3:0] mul1_aA,mul1_a;

always @(ah or al)
begin

  //alxah
  mul1_aA=al[0]^al[3];
  mul1_a=al[2]^al[3];
	
  mul1_alxh_t[0]=(al[0]&ah[0])^(al[3]&ah[1])^(al[2]&ah[2])^(al[1]&ah[3]);
  mul1_alxh_t[1]=(al[1]&ah[0])^(mul1_aA&ah[1])^(mul1_a&ah[2])^((al[1]^al[2])&ah[3]);
  mul1_alxh_t[2]=(al[2]&ah[0])^(al[1]&ah[1])^(mul1_aA&ah[2])^(mul1_a&ah[3]);
  mul1_alxh_t[3]=(al[3]&ah[0])^(al[2]&ah[1])^(al[1]&ah[2])^(mul1_aA&ah[3]);
	
  alxh = (mul1_alxh_t);

end


//mul2:
reg[3:0] mul2_ahp_t;
reg[3:0] mul2_aA,mul2_aB;

always @(d or ah_reg)
begin

//ahxd
	
  mul2_aA=ah_reg[0]^ah_reg[3];
  mul2_aB=ah_reg[2]^ah_reg[3];
	
  mul2_ahp_t[0]=(ah_reg[0]&d[0])^(ah_reg[3]&d[1])^(ah_reg[2]&d[2])^(ah_reg[1]&d[3]);
  mul2_ahp_t[1]=(ah_reg[1]&d[0])^(mul2_aA&d[1])^(mul2_aB&d[2])^((ah_reg[1]^ah_reg[2])&d[3]);
  mul2_ahp_t[2]=(ah_reg[2]&d[0])^(ah_reg[1]&d[1])^(mul2_aA&d[2])^(mul2_aB&d[3]);
  mul2_ahp_t[3]=(ah_reg[3]&d[0])^(ah_reg[2]&d[1])^(ah_reg[1]&d[2])^(mul2_aA&d[3]);
	
  ahp = (mul2_ahp_t);

end


//mul3:
reg[3:0] mul3_alp_t;
reg[3:0] mul3_aA,mul3_aB;

always @(d or alph)
begin

  //dxal
	
  mul3_aA=d[0]^d[3];
  mul3_aB=d[2]^d[3];

  mul3_alp_t[0]=(d[0]&alph[0])^(d[3]&alph[1])^(d[2]&alph[2])^(d[1]&alph[3]);
  mul3_alp_t[1]=(d[1]&alph[0])^(mul3_aA&alph[1])^(mul3_aB&alph[2])^((d[1]^d[2])&alph[3]);
  mul3_alp_t[2]=(d[2]&alph[0])^(d[1]&alph[1])^(mul3_aA&alph[2])^(mul3_aB&alph[3]);
  mul3_alp_t[3]=(d[3]&alph[0])^(d[2]&alph[1])^(d[1]&alph[2])^(mul3_aA&alph[3]);
	
  alp = (mul3_alp_t);

end


//intermediate:
reg[3:0] intermediate_aA,intermediate_aB;
reg[3:0] intermediate_ah2e,intermediate_ah2epl2,intermediate_to_invert_var;
	
always @(ah2 or al2 or alxh)
begin

  //ah square is multiplied with e
  intermediate_aA=ah2[0]^ah2[1];
  intermediate_aB=ah2[2]^ah2[3];
  intermediate_ah2e[0]=ah2[1]^intermediate_aB;
  intermediate_ah2e[1]=intermediate_aA;
  intermediate_ah2e[2]=intermediate_aA^ah2[2];
  intermediate_ah2e[3]=intermediate_aA^intermediate_aB;
	
  //Addition of intermediate_ah2e plus al2
  intermediate_ah2epl2[0]=intermediate_ah2e[0]^al2[0];
  intermediate_ah2epl2[1]=intermediate_ah2e[1]^al2[1];
  intermediate_ah2epl2[2]=intermediate_ah2e[2]^al2[2];
  intermediate_ah2epl2[3]=intermediate_ah2e[3]^al2[3];
	
  //Addition of last result with the result o f(alxah)
  intermediate_to_invert_var[0]=intermediate_ah2epl2[0]^alxh[0];
  intermediate_to_invert_var[1]=intermediate_ah2epl2[1]^alxh[1];
  intermediate_to_invert_var[2]=intermediate_ah2epl2[2]^alxh[2];
  intermediate_to_invert_var[3]=intermediate_ah2epl2[3]^alxh[3];

  //Registers
  next_to_invert = (intermediate_to_invert_var);

end


//inversion:
reg[3:0] inversion_to_invert_var;
reg[3:0] inversion_aA,inversion_d_t;
	
always @(to_invert)
begin

  inversion_to_invert_var=to_invert;
	
  //Invert theresult in GF(2^4)
  inversion_aA=inversion_to_invert_var[1]^inversion_to_invert_var[2]^inversion_to_invert_var[3]^(inversion_to_invert_var[1]&inversion_to_invert_var[2]&inversion_to_invert_var[3]);
  inversion_d_t[0]=inversion_aA^inversion_to_invert_var[0]^(inversion_to_invert_var[0]&inversion_to_invert_var[2])^(inversion_to_invert_var[1]&inversion_to_invert_var[2])^(inversion_to_invert_var[0]&inversion_to_invert_var[1]&inversion_to_invert_var[2]);
  inversion_d_t[1]=(inversion_to_invert_var[0]&inversion_to_invert_var[1])^(inversion_to_invert_var[0]&inversion_to_invert_var[2])^(inversion_to_invert_var[1]&inversion_to_invert_var[2])^inversion_to_invert_var[3]^(inversion_to_invert_var[1]&inversion_to_invert_var[3])^(inversion_to_invert_var[0]&inversion_to_invert_var[1]&inversion_to_invert_var[3]);
  inversion_d_t[2]=(inversion_to_invert_var[0]&inversion_to_invert_var[1])^inversion_to_invert_var[2]^(inversion_to_invert_var[0]&inversion_to_invert_var[2])^inversion_to_invert_var[3]^(inversion_to_invert_var[0]&inversion_to_invert_var[3])^(inversion_to_invert_var[0]&inversion_to_invert_var[2]&inversion_to_invert_var[3]);
  inversion_d_t[3]=inversion_aA^(inversion_to_invert_var[0]&inversion_to_invert_var[3])^(inversion_to_invert_var[1]&inversion_to_invert_var[3])^(inversion_to_invert_var[2]&inversion_to_invert_var[3]);

  d = (inversion_d_t);

end


//sum1:
reg[3:0] sum1_alph_t;
	
always @(ah or al)
begin
	
  sum1_alph_t[0]=al[0]^ah[0];
  sum1_alph_t[1]=al[1]^ah[1];
  sum1_alph_t[2]=al[2]^ah[2];
  sum1_alph_t[3]=al[3]^ah[3];
	
  next_alph = (sum1_alph_t);

end


//square1:
reg[3:0] square1_ah_t;
	
always @(ah)
begin
	
  square1_ah_t[0]=ah[0]^ah[2];
  square1_ah_t[1]=ah[2];
  square1_ah_t[2]=ah[1]^ah[3];
  square1_ah_t[3]=ah[3];
	
  ah2 = (square1_ah_t);

end


//square2:
reg[3:0] square2_al_t;
	
always @(al)
begin
	
  square2_al_t[0]=al[0]^al[2];
  square2_al_t[1]=al[2];
  square2_al_t[2]=al[1]^al[3];
  square2_al_t[3]=al[3];

  al2 = (square2_al_t);

end

endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Subbytes module implementation                              ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Subbytes module implementation                              ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:57  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:23  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module subbytes(clk,reset,start_i,decrypt_i,data_i,ready_o,data_o,sbox_data_o,sbox_data_i,sbox_decrypt_o);
input clk;
input reset;
input start_i;
input decrypt_i;
input [127:0] data_i;
output ready_o;
output [127:0] data_o;
output [7:0] sbox_data_o;
input [7:0] sbox_data_i;
output sbox_decrypt_o;

reg ready_o;
reg [127:0] data_o;
reg [7:0] sbox_data_o;
reg sbox_decrypt_o;

reg [4:0] state;
reg [4:0] next_state;
reg [127:0] data_reg;
reg [127:0] next_data_reg;
reg next_ready_o;
























































//registers:
always @(posedge clk or negedge reset)
begin

  if(!reset)
  begin

    data_reg = (0);
    state = (0);
    ready_o = (0);
	
  end
  else
  begin

    data_reg = (next_data_reg);
    state = (next_state);
    ready_o = (next_ready_o);
	
  end

end


//sub:
reg[127:0] data_i_var,data_reg_128;
reg[7:0] data_array[15:0],data_reg_var[15:0];

always @(decrypt_i or start_i or state or data_i or sbox_data_i or data_reg)
begin

  data_i_var=data_i;

  data_array[0]=data_i_var[127:120];
  data_array[1]=data_i_var[119:112];
  data_array[2]=data_i_var[111:104];
  data_array[3]=data_i_var[103:96];
  data_array[4]=data_i_var[95:88];
  data_array[5]=data_i_var[87:80];
  data_array[6]=data_i_var[79:72];
  data_array[7]=data_i_var[71:64];
  data_array[8]=data_i_var[63:56];
  data_array[9]=data_i_var[55:48];
  data_array[10]=data_i_var[47:40];
  data_array[11]=data_i_var[39:32];
  data_array[12]=data_i_var[31:24];
  data_array[13]=data_i_var[23:16];
  data_array[14]=data_i_var[15:8];
  data_array[15]=data_i_var[7:0];
	
  data_reg_var[0]=data_reg[127:120];
  data_reg_var[1]=data_reg[119:112];
  data_reg_var[2]=data_reg[111:104];
  data_reg_var[3]=data_reg[103:96];
  data_reg_var[4]=data_reg[95:88];
  data_reg_var[5]=data_reg[87:80];
  data_reg_var[6]=data_reg[79:72];
  data_reg_var[7]=data_reg[71:64];
  data_reg_var[8]=data_reg[63:56];
  data_reg_var[9]=data_reg[55:48];
  data_reg_var[10]=data_reg[47:40];
  data_reg_var[11]=data_reg[39:32];
  data_reg_var[12]=data_reg[31:24];
  data_reg_var[13]=data_reg[23:16];
  data_reg_var[14]=data_reg[15:8];
  data_reg_var[15]=data_reg[7:0];
	
		
  sbox_decrypt_o = (decrypt_i);
  sbox_data_o = (0);
  next_state = (state);
  next_data_reg = (data_reg);
		
  next_ready_o = (0);
  data_o = (data_reg);
	
  case(state)
	
    0:
     begin
       if(start_i)
       begin

         sbox_data_o = (data_array[0]);
         next_state = (1);

       end
    end

   16:
    begin
	
      data_reg_var[15]=sbox_data_i;
      //Make shift rows stage
      case(decrypt_i)
        0:
         begin
           
  data_reg_128[127:120]=data_reg_var[0];
  data_reg_128[119:112]=data_reg_var[5];
  data_reg_128[111:104]=data_reg_var[10];
  data_reg_128[103:96]=data_reg_var[15];
  data_reg_128[95:88]=data_reg_var[4];
  data_reg_128[87:80]=data_reg_var[9];
  data_reg_128[79:72]=data_reg_var[14];
  data_reg_128[71:64]=data_reg_var[3];
  data_reg_128[63:56]=data_reg_var[8];
  data_reg_128[55:48]=data_reg_var[13];
  data_reg_128[47:40]=data_reg_var[2];
  data_reg_128[39:32]=data_reg_var[7];
  data_reg_128[31:24]=data_reg_var[12];
  data_reg_128[23:16]=data_reg_var[1];
  data_reg_128[15:8]=data_reg_var[6];
  data_reg_128[7:0]=data_reg_var[11];
         end
        1:
         begin			
           
  data_reg_128[127:120]=data_reg_var[0];
  data_reg_128[119:112]=data_reg_var[13];
  data_reg_128[111:104]=data_reg_var[10];
  data_reg_128[103:96]=data_reg_var[7];
  data_reg_128[95:88]=data_reg_var[4];
  data_reg_128[87:80]=data_reg_var[1];
  data_reg_128[79:72]=data_reg_var[14];
  data_reg_128[71:64]=data_reg_var[11];
  data_reg_128[63:56]=data_reg_var[8];
  data_reg_128[55:48]=data_reg_var[5];
  data_reg_128[47:40]=data_reg_var[2];
  data_reg_128[39:32]=data_reg_var[15];
  data_reg_128[31:24]=data_reg_var[12];
  data_reg_128[23:16]=data_reg_var[9];
  data_reg_128[15:8]=data_reg_var[6];
  data_reg_128[7:0]=data_reg_var[3];
         end
      endcase
		
      next_data_reg = (data_reg_128);
      next_ready_o = (1);
      next_state = (0);

    end
   default:
    begin
      
	  sbox_data_o = (data_array[state]);
      data_reg_var[state-1]=sbox_data_i;
      
  data_reg_128[127:120]=data_reg_var[0];
  data_reg_128[119:112]=data_reg_var[1];
  data_reg_128[111:104]=data_reg_var[2];
  data_reg_128[103:96]=data_reg_var[3];
  data_reg_128[95:88]=data_reg_var[4];
  data_reg_128[87:80]=data_reg_var[5];
  data_reg_128[79:72]=data_reg_var[6];
  data_reg_128[71:64]=data_reg_var[7];
  data_reg_128[63:56]=data_reg_var[8];
  data_reg_128[55:48]=data_reg_var[9];
  data_reg_128[47:40]=data_reg_var[10];
  data_reg_128[39:32]=data_reg_var[11];
  data_reg_128[31:24]=data_reg_var[12];
  data_reg_128[23:16]=data_reg_var[13];
  data_reg_128[15:8]=data_reg_var[14];
  data_reg_128[7:0]=data_reg_var[15];
      next_data_reg = (data_reg_128);
      next_state = (state+1);

    end
	
  endcase

end

endmodule
`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Wishbone Interface for AES128 Coprocessor                   ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
`timescale 1ns / 10ps

module wb_aes_controller(clk,reset,wb_stb_i,wb_dat_o,wb_dat_i,wb_ack_o,
                         wb_adr_i,wb_we_i,wb_cyc_i,wb_sel_i,
                         load_o,decrypt_o,ready_i,data_o,key_o,data_i);

input         clk;
input         reset;
input         wb_stb_i;
output [31:0] wb_dat_o;
input  [31:0] wb_dat_i;
output        wb_ack_o;
input  [31:0] wb_adr_i;
input         wb_we_i;
input         wb_cyc_i;
input  [3:0]  wb_sel_i;

output         load_o;
output         decrypt_o;
output [127:0] data_o;
output [127:0] key_o;
input  [127:0] data_i;
input          ready_i;

reg  [31:0]  wb_dat_o;
reg          wb_ack_o;

reg  [127:0]  data_o;
reg  [127:0]  key_o;
wire         load_o;
wire         decrypt_o;

reg  [31:0]  control_reg;
reg  [127:0]  cypher_data_reg;

assign load_o = control_reg[0];
assign decrypt_o = control_reg[2];

always @(posedge clk or posedge reset)
begin
     if(reset==1)
     begin
       wb_ack_o<=#1 0;
       wb_dat_o<=#1 0;
       control_reg <= #1 32'h0;
       cypher_data_reg <= #1 127'h0;
       key_o <= #1 127'h0;
       data_o <= #1 127'h0;
     end
     else
     begin
       if(ready_i)
       begin
        control_reg[1] <= #1 1'b1;  
        cypher_data_reg <= #1 data_i;
       end
         
       if(wb_stb_i && wb_cyc_i && wb_we_i && ~wb_ack_o)
       begin
         wb_ack_o<=#1 1;
         case(wb_adr_i[7:0])
             8'h0:
             begin
                 //Writing control register
                 control_reg<= #1 wb_dat_i;
             end
             8'h4:
              begin
                 data_o[127:96]<= #1 wb_dat_i;
             end                 
             8'h8:
             begin
                 data_o[95:64]<= #1 wb_dat_i;
             end                 
			 8'hC:
              begin
                 data_o[63:32]<= #1 wb_dat_i;
             end                 
             8'h10:
             begin
                 data_o[31:0]<= #1 wb_dat_i;
             end                 
             8'h14:
             begin
                 key_o[127:96]<= #1 wb_dat_i;
             end                 
             8'h18:
             begin
                 key_o[95:64]<= #1 wb_dat_i;
             end                 
             8'h1C:
             begin
                 key_o[63:32]<= #1 wb_dat_i;
             end                 
             8'h20:
             begin
                 key_o[31:0]<= #1 wb_dat_i;
             end                 
         endcase
       end
       else if(wb_stb_i && wb_cyc_i && ~wb_we_i && ~wb_ack_o)
       begin
           wb_ack_o<=#1 1;
           case(wb_adr_i[7:0])
             8'h0:
             begin
                 wb_dat_o<= #1 control_reg;
                 control_reg[1]<=1'b0;
             end
             8'h24:
             begin
                 wb_dat_o<= #1 cypher_data_reg[127:96];
             end
             8'h28:
             begin
                 wb_dat_o<= #1 cypher_data_reg[95:64];
             end
			 8'h2C:
             begin
                 wb_dat_o<= #1 cypher_data_reg[63:32];
             end
             8'h30:
             begin
                 wb_dat_o<= #1 cypher_data_reg[31:0];
             end
           endcase
       end
       else
       begin
           wb_ack_o<=#1 0;
           control_reg[0]<= #1 1'b0;
       end

     end
end


endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Mixcolumns for a 16 bit word module implementation          ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  Mixcolum for a 16 bit word                                  ////
////                                                              ////
////  Generated automatically using SystemC to Verilog translator ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2004/08/30 16:23:58  jcastillo
// Indentation corrected
//
// Revision 1.2  2004/07/22 08:51:23  jcastillo
// Added timescale directive
//
// Revision 1.1.1.1  2004/07/05 09:46:23  jcastillo
// First import
//

`timescale 1ns / 10ps

module word_mixcolum(in,outx,outy);
input [31:0] in;
output [31:0] outx;
output [31:0] outy;

reg [31:0] outx;
reg [31:0] outy;

reg [7:0] a;
reg [7:0] b;
reg [7:0] c;
reg [7:0] d;

wire [7:0] x1;
wire [7:0] x2;
wire [7:0] x3;
wire [7:0] x4;
wire [7:0] y1;
wire [7:0] y2;
wire [7:0] y3;
wire [7:0] y4;


byte_mixcolum bm1 (.a(a), .b(b), .c(c), .d(d), .outx(x1), .outy(y1));
byte_mixcolum bm2 (.a(b), .b(c), .c(d), .d(a), .outx(x2), .outy(y2));
byte_mixcolum bm3 (.a(c), .b(d), .c(a), .d(b), .outx(x3), .outy(y3));
byte_mixcolum bm4 (.a(d), .b(a), .c(b), .d(c), .outx(x4), .outy(y4));


reg[31:0] in_var;
reg[31:0] outx_var,outy_var;

//split:
always @(  in)
begin
  
  in_var=in;
  a = (in_var[31:24]);
  b = (in_var[23:16]);
  c = (in_var[15:8]);
  d = (in_var[7:0]);
	
end

//mix:
always @(  x1 or   x2 or   x3 or   x4 or   y1 or   y2 or   y3 or   y4)
begin
  
  outx_var[31:24]=x1;
  outx_var[23:16]=x2;
  outx_var[15:8]=x3;
  outx_var[7:0]=x4;
  outy_var[31:24]=y1;
  outy_var[23:16]=y2;
  outy_var[15:8]=y3;
  outy_var[7:0]=y4;

  outx = (outx_var);
  outy = (outy_var);
	
end

endmodule
