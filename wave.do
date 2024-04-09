if {[file exists work]} {
   # vdel -lib work
    
    file delete -force work
}
vlib work

vmap work work

vlog -work work +define+questasim tb_LogicTop.v ../../src/*.v -l vlog.g

vsim -l vsim.log +define+questasim -voptargs=+acc -fsmdebug work.tb_LogicTop  
#vsim -l vsim.log +define+questasim -voptargs=+acc -fsmdebug work.tb_LogicTop  

run 1ms