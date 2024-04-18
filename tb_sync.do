if {[file exists work]} {
    file delete -force work
}
vlib work
vmap work work
vlog -work work +define+questasim +acc +fullpar testbench.v ../../src/*.v -l vlog.g
vsim -c -l vsim.log +define+questasim -voptargs=+acc -fsmdebug work.testbench

# 1. 在运行 DO 文件后直接进行 2ms 的仿真
run 2ms

# 2. 自动运行 all 子命令，以便将所有信号加入波形图中
add wave -r *
