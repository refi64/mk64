-include config.mk

ifneq ($(HAS_CONFIG),1)
    $(error Run ./configure first)
endif

$(shell mkdir -p build/use)

LDFLAGS += -T app.ld
MCFLAGS += -S -Ibuild/use

.PHONY : all run clean

all : build/disk.img

clean :
	rm build/disk.img
	rm build/bmfs
	rm build/*.sys
	rm build/*.o
	rm build/use/*
	touch build/use/empty

run : build/disk.img
	$(QEMU) build/disk.img

build/disk.img : build/bmfs build/bmfs_mbr.sys build/pure64.sys build/kernel64.sys
	$< $@ initialize 128M $(filter %.sys,$^)

build/bmfs : BMFS/src/bmfs.c
	$(CC) -std=c99 -Wall -pedantic -o $@ $<

build/pure64.sys : Pure64/src/pure64.asm
	cd $(<D) && $(NASM) pure64.asm -o $(abspath build/pure64.sys)

build/bmfs_mbr.sys : Pure64/src/bootsectors/bmfs_mbr.asm
	$(NASM) Pure64/src/bootsectors/bmfs_mbr.asm -o build/bmfs_mbr.sys

build/kernel64.sys : build/main.o build/util.o build/io.o build/interrupt.o\
                     build/autil.o build/rt.o
	$(LD) $(LDFLAGS) -o $@ $^

build/%.o build/%.s build/use/% : mk64/%.myr
	$(MC) $(MCFLAGS) -o build/$*.o $<
	[ $* = main ] && touch build/use/main || mv build/$*.use build/use/$*

build/interrupt.o build/use/interrupt : build/use/io
build/io.o build/use/io               : build/use/util
build/main.o                          : build/use/io build/use/interrupt
build/util.o build/use/util           :

build/%.o : mk64/%.asm
	$(NASM) -f elf64 $< -o $@
