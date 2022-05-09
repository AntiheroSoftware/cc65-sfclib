include ../Makefile.inc

all:
	ca65 -g -t none -I $(SFC_INC_PATH) dual.asm
	ld65 -vm -m dual.map -o dual.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom128.cfg dual.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf dual.sfc
