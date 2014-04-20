include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) color.asm
	$(CC65_BIN)/ld65 -o color.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg color.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf color.sfc
