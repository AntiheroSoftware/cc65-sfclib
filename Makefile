all: sfclib samples

.PHONY: sfclib samples

sfclib:
	ca65 -t none -I include src/crt0.asm
	ca65 -t none -I include src/init.asm
	ca65 -t none -I include src/string.asm
	ca65 -t none -I include src/debug.asm
	ca65 -t none -I include src/pad.asm
	ca65 -t none -I include src/event.asm
	ca65 -t none -I include src/events/fadeIn.asm
	ca65 -t none -I include src/events/fadeOut.asm
	ca65 -t none -I include src/sprite.asm
	ca65 -t none -I include src/waitvblank.asm
	ar65 a bin/sfc.lib src/crt0.o src/init.o src/string.o src/debug.o src/pad.o src/event.o src/events/fadeIn.o src/events/fadeOut.o src/sprite.o src/waitvblank.o

samples:
	@$(MAKE) -C samples
