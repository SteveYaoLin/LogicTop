set PRJ=tb_LogicTop
set ALL_DEFINE=+define+questasim
set ADD_SRC=./%PRJ%.v ../../src/*.v
set OTHERCMD_SIM=-do "run 1ms"


RD  /S/Q work
DEL /F /S/Q wlft* vsim* *.log *.out


vlib work
vlog -work work %ALL_DEFINE% %ADD_SRC% -l vlog.log

vsim -l vsim.log %ALL_DEFINE% -voptargs=+acc -fsmdebug -do "log /* -r" -do wave.do %OTHERCMD_SIM% work.%PRJ%

pause
