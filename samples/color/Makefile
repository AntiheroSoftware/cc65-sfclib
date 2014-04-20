include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none color.asm
	$(CC65_BIN)/ld65 -o color.sfc --cfg-path $(CFG_PATH) -C snes-lorom32.cfg color.o $(SFCLIB_PATH)/sfc.lib

clean:
	rm -rf color.sfc
