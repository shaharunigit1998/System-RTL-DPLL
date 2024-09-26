# remove any constraints that were applied from previous runs:
remove_sdc -design

# Set the physical library:
#set lib_name saed32hvt_ss0p75v125c

#set_current_design TOP

# Create clock object and set uncertainty
create_clock -period 10 [get_ports clk]
set_clock_uncertainty -setup 0.2 [get_clocks clk]

set_case_analysis 0 [get_ports inv_dir]

# Set constraints on input ports
#suppress_message UID-401
#suppress_message DCT-306

set_input_delay 0 -max -clock clk  [all_inputs]
set_input_delay -max 1 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
#set_input_delay -max 1.35 -clock clk_i [get_ports Neg_Flag]

#set_driving_cell -max -library $lib_name -lib_cell SDFFARX2_HVT [remove_from_collection [all_inputs] [get_ports clk_i]]

#Set constraints on output ports:
#set_output_delay 0.2 -max -clock clk_i [all_outputs] 	 

#set_load -max [expr [load_of $lib_name/AND2X1_HVT/A1] * 15] [all_outputs]

#set_clock_transition -max 5 [get_clocks clk]

