#!/bin/sh -f
xv_path="/tools/Xilinx/Vivado/2015.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 37719d53b4df4aa188d7bb80a0df1ea5 -m64 --debug typical --relax --mt 8 --include "../../../Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_v5_1/hdl/verilog" --include "../../../Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ltlib_v1_0/hdl/verilog" --include "../../../Mouse_Interface_2015.srcs/sources_1/ip/ila_0/xsdbs_v1_0/hdl/verilog" -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot processor_tb_behav xil_defaultlib.processor_tb xil_defaultlib.glbl -log elaborate.log
