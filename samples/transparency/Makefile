include ../Makefile.inc

.PHONY: resource

all: resource
	ca65 -t none -I $(SFC_INC_PATH) transparency.asm
	ld65 -vm -m transparency.map -o transparency.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom64.cfg transparency.o $(SFC_LIB_PATH)/sfc.lib

resource:
	superfamiconv -i resource/raw/background.png -vvvv -m resource/background.map -t resource/background.pic -p resource/background.clr
	superfamiconv --color-zero 00000000 -i resource/raw/background-checker.png -vvvv -m resource/background-checker.map -t resource/background-checker.pic -p resource/background-checker.clr
	superfamiconv -S -R -i resource/raw/main-sprite.png -p resource/main-sprite.clr -t resource/main-sprite.pic --no-discard --tile-width 8 --tile-height 8
	superfamiconv -S -R -i resource/raw/main-shadow-sprite.png -p resource/main-shadow-sprite.clr -t resource/main-shadow-sprite.pic --no-discard --tile-width 8 --tile-height 8
	superfamiconv -S -R -i resource/raw/main-shadow-sprite-inverted.png -p resource/main-shadow-sprite-inverted.clr -t resource/main-shadow-sprite-inverted.pic --no-discard --tile-width 8 --tile-height 8
	superfamiconv -S -R -i resource/raw/black.png -p resource/black.clr -t resource/black.pic --no-discard --tile-width 8 --tile-height 8
	superfamiconv -S -R -i resource/raw/black-shadow.png -p resource/black-shadow.clr -t resource/black-shadow.pic --no-discard --tile-width 8 --tile-height 8

clean:
	rm -rf transparency.sfc
