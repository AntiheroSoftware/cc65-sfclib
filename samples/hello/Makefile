include ../Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none hello.asm
	$(CC65_BIN)/ld65 -o hello.sfc --cfg-path $(CFG_PATH) -C snes-lorom32.cfg hello.o $(SFCLIB_PATH)/sfc.lib

clean:
	rm -rf hello.sfc
