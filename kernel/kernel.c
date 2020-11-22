#include <stdint.h>

#define VIDEO_MEMORY_START 0xB8000

void print_string(char *string) {
  // Create a pointer to a char, and point it to the first text cell of
  // video memory (i.e. the top-left of the screen)
  uint16_t *video_memory = (uint16_t *)VIDEO_MEMORY_START;
  for (int i = 0; string[i]; i++) {
    *(video_memory + i) = 0xF000 | string[i];
  }
}

void k_main() {
  // At the address pointed to by video_memory, store the character ’X’ // (i.e.
  // display ’X’ in the top-left of the screen).
  char *name = "Hello Kernel with Make";
  print_string(name);
}
