#cd ../sim/presim
###1 建立库(物理目录)
#vlib work
###2 映射库到物理目录
#vmap work work
###3 编译源代码（源代码+仿真tb）
#vlog -work work ../../src/mangen/*.v -cover bescfx
#vlog -sv  -work work ../../tb/top_tb.sv -cover bescfx
###4 启动仿真器
##evoke the simulation
#vsim -novopt work.top_tb
###5添加需要观测的变量
#add wave *
###6 执行仿真
#run 1.5ms

vlib work

vmap work work

vlog -work work +define+questasim tb_LogicTop.v ../../src/*.v -l vlog.g

vsim -l vsim.log +define+questasim -voptargs=+acc -fsmdebug work.tb_LogicTop  

run 1ms