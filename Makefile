CROSS = i386-elf-
CC = $(CROSS)gcc
LD = $(CROSS)ld
GDB = $(CROSS)gdb
OC = $(CROSS)objcopy
AS = yasm

ASFLAGS = -g dwarf2 -I ./boot -f elf32
CFLAGS = -std=gnu11 -ffreestanding -nostdinc -g -I.
LDFLAGS = -nostdlib -melf_i386

BUILD_DIR = build

KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = ${KERNEL_ELF:.elf=.bin}
KERNEL_OFFSET = -Ttext=0x1000

BOOT_ELF = $(BUILD_DIR)/boot.elf
BOOT_BIN = ${BOOT_ELF:.elf=.bin}
BOOT_OFFSET = -Ttext=0x7c00

QEMU = qemu-system-i386
TARGET = $(BUILD_DIR)/os-image

VPATH = boot kernel drivers

# Automatically generate lists of sources using wildcards .
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# Convert the *.c filenames to *.o to give a list of object files to build
# OBJ = ${C_SOURCES:.c=.o}
OBJ = $(patsubst %.c, $(BUILD_DIR)/%.o, $(C_SOURCES))

# Defaul build target
all: $(BUILD_DIR) $(TARGET)

# Run bochs to simulate booting of our code .
run: all
	$(QEMU) -fda $(TARGET)

# Open the connection to qemu and load our kernel-object file with symbols
debug: all
	$(QEMU) -s -fda $(TARGET) &
	$(GDB) \
		-ex "target remote localhost:1234" \
		-ex "add-symbol-file $(BOOT_ELF)" \
		-ex "add-symbol-file $(KERNEL_ELF)" \

# Output dirs
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	mkdir -p $(sort $(dir $(OBJ)))

# This is the actual disk image that the computer loads
# which is the combination of our compiled bootsector and kernel
$(TARGET): $(BOOT_BIN) $(KERNEL_BIN)
	cat $^ > $@
	@chmod +x $@

# Builds the bootloader elf
$(BOOT_ELF): $(BUILD_DIR)/boot.o
	$(LD) $(LDFLAGS) $(BOOT_OFFSET) -o $@ $^

# This builds the binary of our kernel from two object files :
# - the kernel_entry , which jumps to k_main() in our kernel
# - the compiled C kernel
$(KERNEL_ELF): $(BUILD_DIR)/kernel_entry.o ${OBJ}
	$(LD) $(LDFLAGS) $(KERNEL_OFFSET) -o $@ $^

# Compile commands database
compile_commands.json: Makefile
	make -Bnwk | compiledb

# Generic rule for compiling C code to an object file
# For simplicity , we C files depend on all header files .
$(BUILD_DIR)/%.o: %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble the kernel_entry
$(BUILD_DIR)/%.o: %.asm
	$(AS) $< $(ASFLAGS) -o $@

# Assemble the boot sector
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(OC) -O binary $< $@

clean:
	rm -rf $(BUILD_DIR)
