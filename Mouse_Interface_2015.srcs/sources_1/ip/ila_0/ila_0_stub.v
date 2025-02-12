// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Sun Feb  9 18:15:31 2025
// Host        : tommyj-Vivobook-ASUSLaptop-X1505VA-X1505VA running 64-bit Ubuntu 24.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2015.2" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[0:0],probe2[0:0],probe3[1:0],probe4[3:0],probe5[7:0],probe6[7:0],probe7[0:0],probe8[3:0],probe9[3:0],probe10[7:0],probe11[7:0]" */;
  input clk;
  input [0:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input [1:0]probe3;
  input [3:0]probe4;
  input [7:0]probe5;
  input [7:0]probe6;
  input [0:0]probe7;
  input [3:0]probe8;
  input [3:0]probe9;
  input [7:0]probe10;
  input [7:0]probe11;
endmodule
