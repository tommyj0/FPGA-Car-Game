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
ExecStep $xv_path/bin/xsim alu_tb_behav -key {Behavioral:sim_1:Functional:alu_tb} -tclbatch alu_tb.tcl -view /home/tommyj/AMD_FPGA/Mouse_Interface_2015/processor_tb_behav.wcfg -view /home/tommyj/AMD_FPGA/Mouse_Interface_2015/alu_tb_behav.wcfg -log simulate.log
