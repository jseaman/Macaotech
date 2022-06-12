CC65LIB=../cc65/lib
NESLIB=../lib/nes
OUTPUT=./bin

CC = cc65
ASM = ca65
LINKER = ld65

LIBS=$(NESLIB)/crt0.o $(CC65LIB)/nes.lib $(NESLIB)/neslib2.lib
CFG=-C $(NESLIB)/neslib2.cfg
HOR_MIRROR=-DNES_MIRRORING=0
VER_MIRROR=-DNES_MIRRORING=1
PARAMS=-DNES_CHR_BANKS=1 -DNES_PRG_BANKS=2 -DNES_MAPPER=0
REQ_BINARIES=apu.o bcd.o vrambuf.o
CHR_SET=chr_generic.o
CHR_SET2=chr_generic2.o
CHR_SET3=chr_generic3.o
CHR_DEMO=chr_demo.o
CHR_VACHE=chr_vache.o
CHR_VACHE_TEST=chr_vache_test.o

hello: hello.o $(REQ_BINARIES) $(CHR_SET)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"

attribute_table: attribute_table.o $(REQ_BINARIES) $(CHR_SET)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"

palette: palette.o $(REQ_BINARIES) $(CHR_SET)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"

fuera: fuera.o $(REQ_BINARIES) $(CHR_SET)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"

et: et.o $(REQ_BINARIES) $(CHR_SET2)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET2) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"

goomba: goomba.o $(REQ_BINARIES) $(CHR_SET3)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET3) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"

goomba_meta: goomba_meta.o $(REQ_BINARIES) $(CHR_SET3)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET3) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

input: input.o $(REQ_BINARIES) $(CHR_DEMO)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_DEMO) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

bs_vs_math: bs_vs_math.o $(REQ_BINARIES) $(CHR_VACHE)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_VACHE) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

scrolling: scrolling.o $(REQ_BINARIES) $(CHR_DEMO)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_DEMO) $(LIBS) $(CFG) $(VER_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

splitscroll: splitscroll.o $(REQ_BINARIES) $(CHR_DEMO)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_DEMO) $(LIBS) $(CFG) $(VER_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

irq: irq.o $(REQ_BINARIES) $(CHR_VACHE_TEST)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_VACHE_TEST) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

lightgun: lightgun.o $(REQ_BINARIES) $(CHR_SET3)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET3) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

thx: thx.o $(REQ_BINARIES) $(CHR_SET3)
	@echo "-------------------------------"
	@echo "Linking"
	$(LINKER) $@.o $(REQ_BINARIES) $(CHR_SET3) $(LIBS) $(CFG) $(HOR_MIRROR) $(PARAMS) -o $(OUTPUT)/$@.nes
	@echo "-------------------------------"	

%.o: %.s 
	@echo "-------------------------------"
	@echo "Assembling " $< 
	$(ASM) $< 

%.s: %.c 
	@echo "-------------------------------"
	@echo "Compiling " $< 
	cc65 -tnes $<

