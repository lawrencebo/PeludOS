CROSS = i386-elf-
CC = $(CROSS)gcc
LD = $(CROSS)ld
GDB = $(CROSS)gdb
AS = nasm

CFLAGS = -std=gnu11 -ffreestanding -nostdinc -g -I.
LDFLAGS = -Ttext 0x1000 -nostdlib

QEMU = qemu-system-i386
BUILD_DIR = build
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
debug: $(TARGET) $(BUILD_DIR)/kernel.elf
	$(QEMU) -s -fda $(TARGET) &
	$(GDB) -ex "target remote localhost:1234" -ex "symbol-file $(BUILD_DIR)/kernel.elf"

# Output dirs
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	mkdir -p $(sort $(dir $(OBJ)))

# This is the actual disk image that the computer loads
# which is the combination of our compiled bootsector and kernel
$(TARGET): $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $^ > $@
	@chmod +x $@

# This builds the binary of our kernel from two object files :
# - the kernel_entry , which jumps to k_main() in our kernel
# - the compiled C kernel
$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o ${OBJ}
	$(LD) -o $@ $(LDFLAGS) $^ --oformat binary

# Used for debugging purposes
$(BUILD_DIR)/kernel.elf: $(BUILD_DIR)/kernel_entry.o ${OBJ}
	$(LD) -o $@ $(LDFLAGS) $^

# Compile commands database
compile_commands.json: Makefile
	make -Bnwk | compiledb

# Generic rule for compiling C code to an object file
# For simplicity , we C files depend on all header files .
$(BUILD_DIR)/%.o: %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble the kernel_entry
$(BUILD_DIR)/%.o: %.asm
	$(AS) $< -f elf -o $@

# Assemble the boot sector
$(BUILD_DIR)/%.bin: %.asm
	$(AS) $< -f bin -I ./boot -o $@

clean:
	rm -rf $(BUILD_DIR)
