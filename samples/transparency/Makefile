include ../Makefile.inc

.PHONY: resource

all: resource
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) transparency.asm
	$(CC65_BIN)/ld65 -vm -m transparency.map -o transparency.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom64.cfg transparency.o $(SFC_LIB_PATH)/sfc.lib

resource:
	../../../SuperFamiconv/bin/superfamiconv -i resource/raw/background.png -vvvv -m resource/background.map -t resource/background.pic -p resource/background.clr
	../../../SuperFamiconv/bin/superfamiconv -S -R -i resource/raw/main-sprite.png -p resource/main-sprite.clr -t resource/main-sprite.pic --no-discard --tile-width 8 --tile-height 8
	../../../SuperFamiconv/bin/superfamiconv -S -R -i resource/raw/main-shadow-sprite.png -p resource/main-shadow-sprite.clr -t resource/main-shadow-sprite.pic --no-discard --tile-width 8 --tile-height 8
	../../../SuperFamiconv/bin/superfamiconv -S -R -i resource/raw/main-shadow-sprite-inverted.png -p resource/main-shadow-sprite-inverted.clr -t resource/main-shadow-sprite-inverted.pic --no-discard --tile-width 8 --tile-height 8

clean:
	rm -rf transparency.sfc
