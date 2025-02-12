-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Sun Feb  9 18:15:31 2025
-- Host        : tommyj-Vivobook-ASUSLaptop-X1505VA-X1505VA running 64-bit Ubuntu 24.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_0_stub.vhdl
-- Design      : ila_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_0 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe3 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe7 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe8 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe9 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe10 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe11 : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end ila_0;

architecture stub of ila_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[0:0],probe1[0:0],probe2[0:0],probe3[1:0],probe4[3:0],probe5[7:0],probe6[7:0],probe7[0:0],probe8[3:0],probe9[3:0],probe10[7:0],probe11[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2015.2";
begin
end;
