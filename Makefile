PRJ = tb_LogicTop
ALL_DEFINE = +define+questasim

ADD_SRC = ./$(PRJ).v \
					../../src/*.v
OTHERCMD_SIM = -do "run 1us"

include ../main.mk
