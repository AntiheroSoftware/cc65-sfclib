include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) joypad.asm
	$(CC65_BIN)/ld65 -m joypad.map -o joypad.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom32.cfg joypad.o $(SFC_LIB_PATH)/sfc.lib

clean:
	rm -rf joypad.sfc
