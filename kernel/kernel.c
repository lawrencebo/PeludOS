#include <drivers/ports.h>
#include <drivers/screen.h>

#define VIDEO_MEMORY_START 0xb8000

void print(char *string) {
  clear_screen();
  // Create a pointer to a char, and point it to the first text cell of
  // video memory (i.e. the top-left of the screen)
  unsigned short *vga = (unsigned short *)VIDEO_MEMORY_START;
  for (int i = 0; string[i]; i++) {
    vga[i] = BLACK_ON_WHITE << 8 | string[i];
  }
}

void k_main() {
  // At the address pointed to by video_memory, store the character ’X’ // (i.e.
  // display ’X’ in the top-left of the screen).
  char *name = "Hello from PeludOS";
  print(name);
}
