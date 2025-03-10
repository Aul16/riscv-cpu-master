
# Program to compile & run
PROG ?= addi

# Par défault on n'embarque pas de libraries (cas des autotests et mutants)
# On peut embarquer libfemto pour un programme donné en passant LIB=libfemto en ligne de commande (cas des programmes comme riscv_invader)
LIB ?= #libfemto

# Main rule
all: mem_files

#regles pour creer les repertoires utiles
include config/directory.mk

# Log level
VERB := 0
LOG_FILE := $(abspath log)
quiet-command = $(if $(filter 1, $(VERB)),$(1), $(if $(2),@echo $(2) && ($(1)) >> $(LOG_FILE), @$(1)))

VERBOSE :=-intstyle xflow # mettre xflow ou silent

## RISCV Toolchain
TOOLCHAIN_DIR ?= /usr/bin
PREFIX        ?= riscv32-unknown-elf-
AS      := $(TOOLCHAIN_DIR)/$(PREFIX)as
CC      := $(TOOLCHAIN_DIR)/$(PREFIX)gcc
LD      := $(TOOLCHAIN_DIR)/$(PREFIX)ld
OBJDUMP := $(TOOLCHAIN_DIR)/$(PREFIX)objdump

## Flags
ASFLAGS       := -march=rv32izicsr -mabi=ilp32 -Ienv/common/rv32

CFLAGS        := -O3 -march=rv32i -mabi=ilp32 -mcmodel=medany -ffunction-sections -fdata-sections -g -I./logiciel/kernel/env/common 
CFLAGS_FEMTO  := -I$(FEMTO_DIR)/libfemto/include -I$(FEMTO_DIR)/env/common -I$(FEMTO_DIR)/env/common/rv32 -DENV_FPGA=1

LDFLAGS       :=
LDFLAGS_FEMTO := -nodefaultlibs -nostartfiles -nostdlib -nostdinc -static -Wl,--nmagic -Wl,--gc-sections -march=rv32i -mabi=ilp32
LDFLAGS_ASM   := -b elf32-littleriscv

ODFLAGS := --section=.text
ODFLAGS += --section=.data
ODFLAGS += --section=.rodata
ODFLAGS += --section=.sdata
ODFLAGS += --section=.bss
ODFLAGS += --section=.irq_vec
ODFLAGS += --disassembler-options no-aliases,numeric
ODFLAGS += -s -z
ODFLAGS += --insn-width=4

# Linker scripts
LDS_FEMTO := $(FEMTO_DIR)/env/cep_riscv/default.lds
LDS_ASM   := config/link.ld

# Sources de libfemto
FEMTO_OBJ_DIR := $(FEMTO_DIR)/build/obj/rv32i/env/cep_riscv
FEMTO_LIB_DIR := $(FEMTO_DIR)/build/lib/rv32i
femtolibs := $(FEMTO_OBJ_DIR)/crt.o $(FEMTO_OBJ_DIR)/setup.o $(FEMTO_LIB_DIR)/libfemto.a

# Selection des flags, outils et linker script on fonction de si on utilise libfemto ou non
ifeq ($(LIB),libfemto)
  libs    := $(femtolibs)
  CFLAGS  += $(CFLAGS_FEMTO)
  LDFLAGS += $(LDFLAGS_FEMTO) -T $(LDS_FEMTO)
  LD      := $(CC) # avec libfemto on link avec le frontend gcc et non directement avec ld
else
  libs    :=
  LDFLAGS += $(LDFLAGS_ASM) -T $(LDS_ASM)
endif




OBTOMEM := bin/objtomem.awk

# Pas de fichier .s à la racine
ifneq ($(wildcard *.s),)
  $(error Merci de ranger vos .s dans le répertoire '$(SRC_DIR)/')
endif

# Fichier PROG.s bien présent dans program/
#SRC :=
#SRC += $(wildcard $(SRC_DIR)/*.s)
#SRC += $(wildcard $(SRC_DIR)/*.c)
#SRC += $(wildcard $(SRC_DIR)/*.elf)
#SRC += $(wildcard $(SRC_DIR)/*/*.s)
#SRC += $(wildcard $(SRC_DIR)/*/*.c)


#ifeq ($(filter $(PROG), $(basename $(notdir $(SRC) ) ) ),)
#  $(error $(PROG) est introuvable dans le répertoire '$(SRC_DIR)/' ou un de ses sous-répertoires directs)
#endif
SRC_SUBDIRS := $(subst $(space),:,$(shell find $(SRC_DIR) -type d))
SRC_SUBDIRS += $(subst $(space),:,$(shell find $(APP_DIR) -type d))
vpath %.s $(SRC_SUBDIRS)
vpath %.c $(SRC_SUBDIRS)

PROG_mem := $(MEM_DIR)/$(notdir $(basename $(PROG))).mem

# Rules
mem_files: $(MEM_DIR)/prog.mem

# Select mem file
$(MEM_DIR)/prog.mem: $(PROG_mem)
	@echo "Selecting mem file $(PROG_mem)"
	@cp $< $@


.PRECIOUS: $(MEM_DIR)/%.elf

.PHONY: clean clean_femto realclean $(MEM_DIR)/prog.mem

$(femtolibs):
ifeq ($(LIB),libfemto)
	bin/rebuild_femto.sh ENV=ENV_FPGA
endif

$(MEM_DIR)/%.o: %.c |$(MEM_DIR)
	$(call quiet-command,\
	$(CC) $(CFLAGS) -c $< -o $@ , "  CC $(CC)  $(CFLAGS) -c -o $@  $<")

$(MEM_DIR)/%.o: %.s |$(MEM_DIR)
	$(call quiet-command,\
	$(AS) $(ASFLAGS) -o $@ $<, "  AS $(AS) $(ASFLAGS) -o $@     $<")

$(MEM_DIR)/%.elf: $(MEM_DIR)/%.o $(femtolibs) asm/*.s
	$(call quiet-command,\
	$(LD) $(LDFLAGS) $(libs) $< -o $@ , "  LD $(LD)    $(LDFLAGS) -o $@ $(libs) $<")

$(MEM_DIR)/%.mem: $(MEM_DIR)/%.elf |$(MEM_DIR)
	$(call quiet-command, $(OBJDUMP) $(ODFLAGS) $<)
	$(call quiet-command, $(OBJDUMP) $(ODFLAGS) $< | awk -f $(OBTOMEM) > $@ ,)

#$(MEM_DIR)/%.mem: $(SRC_DIR)/$(PROG).elf | $(MEM_DIR)
#	$(call quiet-command, $(OBJDUMP) $(ODFLAGS) $< | awk -f $(OBTOMEM) > $@ ,)


$(TMP_DIR)/prog: force |$(TMP_DIR)
	@if [ ! -e $@ ] || [ $(PROG) != `cat $@` ] ; then echo "$(PROG)" > $@  ;fi



$(MEM_DIR)/%.c.o: c/%.c |$(MEM_DIR)
	$(call quiet-command,\
	$(CC) $(CFLAGS) -c $< -o $@ , "  CC $(CC)  $(CFLAGS) -c -o $@  $<")
$(MEM_DIR)/%.s.o: asm/%.s |$(MEM_DIR)
	$(call quiet-command,\
	$(AS) $(ASFLAGS) -o $@ $<, "  AS $(AS) $(ASFLAGS) -o $@     $<")

# command with explicid binary deps
$(MEM_DIR)/ctest.elf: $(MEM_DIR)/ctest.c.o $(MEM_DIR)/graphics.c.o $(MEM_DIR)/bootstrap.s.o
	$(LD) $(LDFLAGS) $(MEM_DIR)/bootstrap.s.o $(MEM_DIR)/ctest.c.o $(MEM_DIR)/graphics.c.o  -o $(MEM_DIR)/ctest.elf

$(MEM_DIR)/invader.elf: $(MEM_DIR)/invader.o  $(MEM_DIR)/bootstrap.s.o
	$(LD) $(LDFLAGS) $(MEM_DIR)/bootstrap.s.o $(MEM_DIR)/invader.o -o $(MEM_DIR)/invader.elf



## Cleaning
TOCLEAN  := $(TMP_DIR) log

clean:
	@echo "Removing $(TMP_DIR) & log"
	@rm -rf $(TOCLEAN)

clean_femto:
	@echo "Removing libfemto : $(FEMTO_DIR)/build"
	@rm -rf  $(FEMTO_DIR)/build

realclean: clean clean_femto

