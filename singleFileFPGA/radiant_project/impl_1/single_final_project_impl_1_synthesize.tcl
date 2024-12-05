if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/jphilion/Desktop/e155-final-project/singleFileFPGA/radiant_project"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- single_final_project_impl_1.vm single_final_project_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "single_final_project_impl_1_lattice.synproj" -logfile "single_final_project_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o single_final_project_impl_1_syn.udb single_final_project_impl_1.vm] [list C:/Users/jphilion/Desktop/e155-final-project/singleFileFPGA/radiant_project/impl_1/single_final_project_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
