proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  debug::add_scope template.lib 1
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.cache/wt [current_project]
  set_property parent.project_path /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.xpr [current_project]
  set_property ip_repo_paths /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.cache/ip [current_project]
  set_property ip_output_repo /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.cache/ip [current_project]
  add_files -quiet /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.runs/synth_1/top.dcp
  add_files -quiet /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.runs/ila_0_synth_1/ila_0.dcp
  set_property netlist_only true [get_files /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.runs/ila_0_synth_1/ila_0.dcp]
  read_xdc -mode out_of_context -ref ila_0 /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_0_ooc.xdc
  set_property processing_order EARLY [get_files /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_0_ooc.xdc]
  read_xdc -ref ila_0 /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_v5_1/constraints/ila.xdc
  set_property processing_order EARLY [get_files /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/sources_1/ip/ila_0/ila_v5_1/constraints/ila.xdc]
  read_xdc /home/tommyj/AMD_FPGA/Mouse_Interface_2015/Mouse_Interface_2015.srcs/constrs_1/imports/new/MouseXDC.xdc
  link_design -top top -part xc7a35tcpg236-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force top_opt.dcp
  catch {report_drc -file top_drc_opted.rpt}
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file top.hwdef}
  place_design 
  write_checkpoint -force top_placed.dcp
  catch { report_io -file top_io_placed.rpt }
  catch { report_utilization -file top_utilization_placed.rpt -pb top_utilization_placed.pb }
  catch { report_control_sets -verbose -file top_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force top_routed.dcp
  catch { report_drc -file top_drc_routed.rpt -pb top_drc_routed.pb }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file top_timing_summary_routed.rpt -rpx top_timing_summary_routed.rpx }
  catch { report_power -file top_power_routed.rpt -pb top_power_summary_routed.pb }
  catch { report_route_status -file top_route_status.rpt -pb top_route_status.pb }
  catch { report_clock_utilization -file top_clock_utilization_routed.rpt }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  write_bitstream -force top.bit 
  catch { write_sysdef -hwdef top.hwdef -bitfile top.bit -meminfo top.mmi -ltxfile debug_nets.ltx -file top.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

