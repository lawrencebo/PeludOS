#include "screen.h"
#include "ports.h"

#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80

// Screen device I/O ports
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

int get_offset(int col, int row) { return 2 * (row * MAX_COLS + col); }

void set_cursor_offset(int offset) {
  /* Similar to get_cursor_offset, but instead of reading we write data */
  offset /= 2;
  port_byte_out(REG_SCREEN_CTRL, 14);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
  port_byte_out(REG_SCREEN_CTRL, 15);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

void clear_screen() {
  int screen_size = MAX_COLS * MAX_ROWS;
  unsigned short *screen = (unsigned short *)VIDEO_ADDRESS;

  for (int i = 0; i < screen_size; i++) {
    screen[i] = WHITE_ON_BLACK << 8 | ' ';
  }
  set_cursor_offset(get_offset(0, 0));
}
