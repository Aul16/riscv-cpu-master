# RISC-V CPU Implementation

A complete RISC-V CPU implementation with HDMI output support, capable of running Space Invaders and other graphical applications.

## Project Overview

This project implements a RISC-V CPU with the following features:

- Complete RV32I ISA implementation (all instructions)
- ZICSR Extension support (6 registers)
- HDMI output with configurable resolution
- C program support with bootstrap and libfemto options
- Multiple demo applications including Space Invaders

## Getting Started

### Prerequisites

- **Vivado** - Version 19.1 WebPAck Edition or newer is required for the HDMI controller
  - [Download Vivado](https://www.xilinx.com/support/download.html)
- **RISC-V GCC Toolchain** - For compiling programs for the CPU
  - Install via package manager: `sudo apt install gcc-riscv-unknown-elf` (Debian/Ubuntu)
  - Or build from source using the [RISC-V Tools repository](https://gricad-gitlab.univ-grenoble-alpes.fr/riscv-ens/outils)

### Installation

1. Clone the repository:

   ```bash
   git clone git@gitlab-student.centralesupelec.fr:comparch/processeur.git
   cd processeur
   ```

2. For automatic installation on Debian-based systems, use the provided script:

   ```bash
   ./install.sh
   ```

3. Set up your environment:

   ```bash
   # Add RISC-V toolchain to PATH (if installed from source)
   export PATH=${PATH}:/opt/riscv-cep-tools/bin

   # Set up Vivado environment
   source /opt/Xilinx/Vivado/2019.1/settings64.sh
   ```

   Adjust paths according to your installation locations.

## Usage

### Simulation

To simulate an instruction (e.g., LUI):

```bash
cd implem && make simulation PROG=lui
```

### FPGA Synthesis

To run the LED test on FPGA:

```bash
cd implem && make fpga PROG=test_led_x31
```

To run Space Invaders on FPGA:

```bash
cd implem && make fpga PROG=invader LIB=libfemto
```

### Available Programs

#### droite

Graphical test that draws primitives (rectangles, circles, and segments).

```bash
make fpga PROG=droite
```

Files: `program/droite.s`, `asm/graphics.s`, `asm/util.s`

#### ctest (Space Invaders)

Handwritten version of Space Invaders that doesn't use libfemto.

- BTN0/BTN1: Movement
- BTN2: Shoot
- BTN3: Hardware reset

```bash
make fpga PROG=ctest
```

Files: `asm/bootstrap.s`, `c/ctest.c`, `c/graphics.c`, `c/graphics.h`, `c/platform.h`, `c/gfx_data.c`, `c/gameover.c`, `c/sprites.c`

#### invader

Standard Space Invaders with libfemto.

```bash
make fpga PROG=invader
```

#### compteur

Minimal test with an infinitely incrementing LED binary counter.

```bash
make fpga PROG=compteur
```

### Other Commands

For more available commands:

```bash
cd implem && make help
```

## CPU Implementation Details

### Instruction Execution Times

| Instruction type | Cycle count | States                                |
| ---------------- | ----------- | ------------------------------------- |
| Imm Arithmetic   | 3 cycles    | Decode, ArithI, Fetch                 |
| Arithmetic       | 3 cycles    | Decode, Arith, Fetch                  |
| LUI              | 3 cycles    | Decode, Lui, Fetch                    |
| AUIPC            | 4 cycles    | Decode, Auipc, Prefetch, Fetch        |
| BXX / JALR       | 4 cycles    | Decode, Jump, Prefetch, Fetch         |
| JAL              | 3 cycles    | Decode, Prefetch, Fetch               |
| Loads            | 5 cycles    | Decode, Setup, Read, Write, Fetch     |
| Stores           | 5 cycles    | Decode, Setup, Write, Prefetch, Fetch |
| CSR              | 4 cycles    | Decode, CSR, Prefetch, Fetch          |

### Unknown Opcode Behavior

The behavior when encountering an unknown or invalid instruction is defined by the `ERROR_TARGET_STATE` constant in `vhd/CPU_PC.vhd`:

- `S_Init`: Reset the hardware (current setting)
- `S_Error`: Stop execution and loop forever

## Changing Display Resolution

To change the display resolution, you need to modify both the VIC and VRAM size:

1. Set VRAM size in `vhd/hdmi/HDMI_AXI_Slave.vhd`
2. Choose default VIC in `vhd/hdmi/HDMI_pkg.vhd`
3. VIC list is available in `vhd/hdmi/VIC_Interpreter`

Tested resolutions:

- 1080p30
- 720p60

## Compiling C Programs

### Using bootstrap.s

Include `bootstrap.s.o` as the first object to link:

```bash
ld -o program.elf bootstrap.o <libraries...> program.o $(LDFLAGS)
```

This sets up the stack pointer at the end of RAM and calls `main` with no arguments.

A `void WAIT(void)` function is available to create an infinite loop. Interrupts are not activated.

### Using libfemto

libfemto is a lightweight bare-metal C library for embedded RISC-V development that provides:

- Reduced set of POSIX.1-2017 / IEEE 1003.1-2017 standard functions
- Simple hardware configuration mechanism
- RISC-V machine mode functions and macros
- Console and power device drivers

## Troubleshooting

### Cell has undefined content and is considered a black box

```
ERROR: [DRC INBB-3] Black Box Instances: Cell 'C_PS_Link_inst' of type 'PS_Link' has undefined contents and is considered a black box.
```

Solution: Run `make clean`

### Linker errors

```
ld: undefined reference to __mulsi3, __muldi3, etc...
```

Solutions:

1. Use `libfemto`
2. Implement these functions (see canonical GCC implementations)

```
ld: cant link double-float modules with soft-float modules
ld: failed to merge target specific data of file .../libgcc.a(div.o/multi3.o)
```

This issue arises when trying to use libfemto with the provided toolchain.

### Program Compilation Issues

Remember to `rm -r .CEPcache/mem` before recompiling (especially C programs) as the makefiles are not perfect.

## Project Structure

- `/implem` - Main implementation directory
  - `/asm` - Assembly code and utilities
  - `/c` - C code for applications
  - `/vhd` - VHDL implementation of the CPU
  - `/program` - Test programs
  - `/logiciel` - Software libraries and kernel
    - `/kernel` - Boot code and libfemto
    - `/apps` - Applications for FPGA/QEMU
  - `/config` - Build configuration files

## License

This project is provided for educational purposes.
