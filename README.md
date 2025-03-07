IMPLEMENTATION README
=====================

This readme describes all the features we implemented in this project

CPU Functionnalies
---------------------

 * rv32i ISA (every instruction)
 * ZICSR Extension (6 registers) (csrrw, csrrs, ..., mret)

Changing the resolution
--------------------

To change the resolution, both the VIC and the VRAM size must be set correctly
in the vhdl source. The expected resolution must also be change in programs

### Useful files
- `vhd/hdmi/HDMI_AXI_Slave.vhd` : Set VRAM size
- `vhd/hdmi/HDMI_pkg.vhd` : Choose default VIC
- `vhd/hdmi/VIC_Interpreter` : VIC list

### Tested VICs : 
- 1080p30 
- 720p60 


Unknown opcodes
----------------

The behavior when the IR is unknown or invalid is 
defined by the `ERROR_TARGET_STATE` constant in `vhd/CPU_PC.vhd`.

* `S_Init` : Reset the hardware
* `S_Error` : Stop execution and loop forever

CURRENT STATE : `S_Init`


Compiling a C program
-----------------------

Because  `ld` does not always place `main` at `0x1000`, a library to initialize the program is needed.

### With bootstrap.s

When compiling, in the `ld` command, include `bootstrap.s.o` as the first object to link.
A small assembly function will setup the stack pointer at the end of RAM then call `main`
with no arguments.

```bash
ld -o program.elf bootstrap.o <librairies...> program.o $(LDFLAGS)
```

A function `void WAIT(void)` is also made available to create an infinite loop.
Interrupts are not activated.

### With libfemto

Add libfemto to `config/compile_RISCV.mk` (does not appear to work with our toolchain)


Errors
-------

### Cell has undefined content and is considered a black box
```
ERROR: [DRC INBB-3] Black Box Instances: Cell 'C_PS_Link_inst' of type 'PS_Link' has undefined contents and is considered a black box.  The contents of this cell must be defined for opt_design to complete successfully.
```
Solution: `make clean`

### Erreurs de linker 
```
ld: undefined reference to __mulsi3, __muldi3, etc...
```
Solution 1 : use `libfemto` 
Solution 2 : implement these functions (see canonical GCC implementations)
 
 ```
 ld: cant link double-float modules with soft-float modules
 ld: failed to merge target specific data of file .../libgcc.a(div.o/multi3.o)
 ```
 Solution : ??? (arises when trying libfemto with our toolchain)


Programs
----------

Remember to `rm -r .CEPcache/mem` before recompiling (especially C) because the makefiles are
not perfect

### droite

Graphical tests, draws primitives with `graphics.s`.
Can draw rectangles, circles and shallow slope segments.
It is important to choose the right resolution in `graphics.s`

#### Compilation
```make
make fpga PRG=droite
```

#### Files
* `program/droite.s`
* `asm/graphics.s`
* `asm/util.s`


### ctest

Handwritten version  version of space invaders, does not use `libfemto`.
Choose the right resolution in `platform.h`

* BTN0/BTN1 : movement 
* BTN2 : shoot
* BTN3 : reset (hardware)

#### Compilation
```make
make fpga PROG=ctest
```

#### Files
* `asm/bootstrap.s`
* `c/ctest.c`
* `c/graphics.c c/graphics.h`
* `c/platform.h`
* `c/gfx_data.c`
* `c/gameover.c`
* `c/sprites.c`


### invader

The standard space invaders with libfemto, does not compile with our
toolchain.

#### Compilation
```make
make fpga PROG=invader
```

### compteur

Minimal test: infinitely incrementing LED binary counter.
Check that `ERROR_TARGET_STATE` is set to `S_Init`

#### Compilation
```make
make fpga PROG=invader
```

Execution times
-----------------

The number of execution cycles is counted starting with the `Decode` state common to all
instructions.

| Instruction type | Cycle count  | States                                      |
|------------------|--------------|---------------------------------------------|
| Imm Arithmetic   | 3 cycles     | Decode, ArithI, Fetch                       |
| Arithmetic       | 3 cycles     | Decode, Arith, Fetch                        |
| LUI              | 3 cycles     | Decode, Lui, Fetch                          |
| AUIPC            | 4 cycles     | Decode, Auipc, Prefetch, Fetch              |
| BXX / JALR       | 4 cycles     | Decode, Jump, Prefetch, Fetch               |
| JAL              | 3 cycles     | Decode, Prefetch, Fetch                     |
| Loads            | 5 cycles     | Decode, Setup, Read, Write, Fetch           |
| Stores           | 5 cycles     | Decode, Setup, Write, Prefetch, Fetch       |
| CSR              | 4 cycles     | Decode, CSR, Prefetch, Fetch                |


README ORIGINAL
===============

Récupérer le projet
---------------------
Faire un clone pour récupérer le projet.

`git clone git@gitlab-student.centralesupelec.fr:comparch/processeur.git`

Les fichiers du TP se trouvent normalement dans le répertoire `processeur` : `cd processeur`

Makefiles
---------


### Simuler

Test de l'instruction lui :

`cd implem && make simulation PROG=lui `

### Synthétiser

Test des leds sur carte : 

`cd implem && make fpga PROG=test_led_x31`

Space Invader sur carte :

`cd implem && make fpga PROG=invader LIB=libfemto`

### Autres

`cd implem && make help`


Installation sur votre propre ordinateur
----------------------------------------

## Dépendances

Nous fournissons un [script d'installation](https://gitlab-student.centralesupelec.fr/comparch/processeur/-/blob/master/install.sh) automatique pour Debian qui installe Vivado, la chaîne de compilation RISC-V et les dépendances. Si vous voulez installer manuellement, il vous faudra :
* *Vivado* -> La version minimale *19.1 WebPAck Edition* est requise pour faire fonctionner le contrôleur HDMI ([Téléchargement de Vivado](https://www.xilinx.com/support/download.html))
* *Toolchain gcc-riscv* -> Le plus simple est d'installer le paquet adéquat (par exemple, sous Debian `sudo apt install gcc-riscv-unknown-elf`). Elle peut aussi être compilée et installée à l'aide du [dépôt Outils](https://gricad-gitlab.univ-grenoble-alpes.fr/riscv-ens/outils)

## Environnement

Pour pouvoir utiliser les Makefiles du projet afin de simuler/synthetiser les modèles matériels VHDL et de compiler les programes de test et applications, il faut faire connaître à son environnement de travail les chemins vers les outils utilisés :

* Si vous avez installé la chaîne de compilation en clonant le dépôt outil (cette étape n'est pas nécessaire si vous avez installé la chaîne de compilation via un paquet), ajout du chemin vers la chaîne de compilation dans le PATH:

`export PATH=${PATH}:/opt/riscv-cep-tools/bin`

Remplacer */opt/riscv-cep-tools* par le chemin où votre chaîne
de compilation RISC-V est installée sur votre machine

* Ajout des chemins vers les outils Vivado: 

`source /opt/Xilinx/Vivado/2019.1/settings64.sh` 

Remplacer éventuellement */opt/* par le chemin où Vivado est installé sur votre machine
