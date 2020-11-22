CROSS = i386-elf-
CC = $(CROSS)gcc
LD = $(CROSS)ld
AS = nasm

TARGET = os-image

CFLAGS = -ffreestanding
LDFLAGS = -Ttext 0x1000

QEMU = qemu-system-i386
# SRC_DIR = src
# BUILD_DIR = build
# VPATH = src


# Automatically generate lists of sources using wildcards .
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# TODO : Make sources dep on all header files .
# Convert the *.c filenames to *.o to give a list of object files to build
OBJ = ${C_SOURCES:.c=.o}
# OBJ = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SOURCES))

# Defaul build target
all: $(TARGET)

# Run bochs to simulate booting of our code .
run: all
	$(QEMU) -fda $(TARGET)

# This is the actual disk image that the computer loads
# which is the combination of our compiled bootsector and kernel
$(TARGET): boot/boot_kernel.bin kernel.bin
	cat $^ > $(TARGET)

# This builds the binary of our kernel from two object files :
# - the kernel_entry , which jumps to k_main() in our kernel
# - the compiled C kernel
kernel.bin: kernel/kernel_entry.o ${OBJ}
	$(LD) -o $@ $(LDFLAGS) $^ --oformat binary

# Generic rule for compiling C code to an object file
# For simplicity , we C files depend on all header files .
%.o: %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble the kernel_entry .
%.o: %.asm
	$(AS) $< -f elf -o $@

%.bin: %.asm
	$(AS) $< -f bin -I ./boot -o $@

clean:
	rm -rf *.bin *.dis *.o $(TARGET)
	rm -rf kernel/*.o boot/*.bin drivers/*. o
