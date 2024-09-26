lappend search_path scripts design_data
set_host_options -max_cores 4
set TECH_FILE     "/data/intel/16/pdk224_r1.0.3HP1/apr/synopsys/tech/m11_1x_3xa_1xb_1xc_2yb_2ga_mim2_1gb__bumpp/7t108_tp0/p1222_icc2.tf"
set LIB_BASE_NOM     "/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/base_nom/ndm/lib224_b15_7t_108pp_base_nom.ndm"
set LIB_BASE_LP      "/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/base_lp/ndm/lib224_b15_7t_108pp_base_lp.ndm"
set LIB_SEQ_NOM     "/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/seq_nom/ndm/lib224_b15_7t_108pp_seq_nom.ndm"
set LIB_SEQ_LP      "/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/seq_lp/ndm/lib224_b15_7t_108pp_seq_lp.ndm"
set LIB_CLK_NOM     "/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/clk_nom/ndm/lib224_b15_7t_108pp_clk_nom.ndm"
set LIB_CLK_LP      "/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/clk_lp/ndm/lib224_b15_7t_108pp_clk_lp.ndm"
#######################################################################
## Physical Library Settings
#######################################################################
create_lib  -technology $TECH_FILE  -ref_libs { \
/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/base_nom/ndm/lib224_b15_7t_108pp_base_nom.ndm \
/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/base_lp/ndm/lib224_b15_7t_108pp_base_lp.ndm \
/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/seq_nom/ndm/lib224_b15_7t_108pp_seq_nom.ndm \
/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/seq_lp/ndm/lib224_b15_7t_108pp_seq_lp.ndm \
/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/clk_nom/ndm/lib224_b15_7t_108pp_clk_nom.ndm \
/data/intel/16/dig_libs/lib224_b15_7t_108pp_pdk103_r4v1p0/clk_lp/ndm/lib224_b15_7t_108pp_clk_lp.ndm \

 }  loop.dlib
open_lib loop.dlib
report_ref_libs
read_parasitic_tech -tlu /data/intel/16/pdk224_r1.0.3HP1/extraction/starrc/techfiles/m11_1x_3xa_1xb_1xc_2yb_2ga_mim2_1gb__bumpp/pcff.tlup -name pcff
read_parasitic_tech -tlu /data/intel/16/pdk224_r1.0.3HP1/extraction/starrc/techfiles/m11_1x_3xa_1xb_1xc_2yb_2ga_mim2_1gb__bumpp/pcss.tlup -name pcss

save_lib
analyze -format verilog [ glob ./Verilog_Synth/*.v ]
 
elaborate Loop
set_top_module Loop
#start_gui
save_block -as loop/elaborate

# mcmm_setup: 
# Remove all MCMM related info
remove_corners   -all
remove_modes     -all
remove_scenarios -all
# Create Corners
create_corner Fast
create_corner Slow
#
## Set parasitics parameters
set_parasitics_parameters -early_spec pcff -late_spec  pcff -corners {Fast}
set_parasitics_parameters -early_spec pcss -late_spec  pcss -corners {Slow}
#
## Create Mode
create_mode  FUNC
current_mode FUNC
#
## Create Scenarios
create_scenario -mode FUNC -corner Fast    -name FUNC_Fast
create_scenario -mode FUNC -corner Slow    -name FUNC_Slow
#

#sourse ConFiles/con431.con
current_scenario FUNC_Fast 
source  loop.sdc
current_scenario FUNC_Slow 
source  loop.sdc

set_auto_floorplan_constraints -core_utilization 0.7 -side_ratio {1 1} -core_offset 2
compile_fusion -to logic_opto
#create_placement
#legalize_placement
##Power

save_block -as loop/logic_opto



#up to here
compile_fusion -to final_opto

save_block -as riscv/final_opto

set_attribute [get_layers {m1 m3 m5 m7 }]   routing_direction vertical
set_attribute [get_layers {m2 m4 m6 m8 }] routing_direction horizontal

source create_pg_network.tcl
clock_opt
route_opt
save_block -as loop/route_opt
