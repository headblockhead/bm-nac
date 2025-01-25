BITS 64
  org 0x400000

elf_header:
  db 0x7f, "ELF", 2, 1, 1, 0 ; e_ident
  times 8 db 0
  dw  2                      ; e_type
  dw  0x3e                   ; e_machine
  dd  1                      ; e_version
  dq  _start                 ; e_entry
  dq  program_header - $$    ; e_phoff
  dq  0                      ; e_shoff
  dd  0                      ; e_flags
  dw  elf_header_size        ; e_ehsize
  dw  program_header_size    ; e_phentsize
  dw  1                      ; e_phnum
  dw  0                      ; e_shentsize
  dw  0                      ; e_shnum
  dw  0                      ; e_shstrndx
elf_header_size equ $ - elf_header

program_header:
  dd  1                      ; p_type
  dd  7                      ; p_flags 
  ; RWX flags make code writable during runtime, which is dangerous, but reduces need for any other sections, thereby saving space.
  dq  0                      ; p_offset
  dq  $$                     ; p_vaddr
  dq  $$                     ; p_paddr
  dq  program_size           ; p_filesz
  dq  program_size           ; p_memsz
  dq  0x1000                 ; p_align
program_header_size equ $ - program_header

_start:
  mov rax, 1
  mov rdi, 1
  mov rsi, welcome_message
  mov rdx, welcome_message_size
  syscall

  call print_board

  .loop:
  call get_move
  call print_board
  call check_gameover
  jmp .loop

get_move:
  ; Moves the cursor back to the start of the board, overwriting the previous drawing of the board.
  mov rax, 1
  mov rdi, 1
  mov rsi, previous_lines
  mov rdx, previous_lines_size
  syscall

  ; Deliberatly overflows past the current_player buffer to include the move_input_message.
  mov rax, 1
  mov rdi, 1
  mov rsi, current_player
  mov rdx, move_input_message_size + 1
  syscall

  ; Reads one byte from stdin into move_input.
  mov rax, 0
  mov rdi, 0
  mov rsi, move_input
  mov rdx, 1
  syscall

  ; If the first character is a newline, it's invalid.
  cmp byte [move_input], 0xa
  je .invalid

  ; Loop through any remaining bytes from stdin until the newline byte is hit.
  .read_until_newline:
  mov rax, 0
  mov rdi, 0
  mov rsi, ignored_buffer
  mov rdx, 1
  syscall
  cmp byte [ignored_buffer], 0xa
  jne .read_until_newline

  ; Set al to the move_input
  mov al, byte [move_input]

  ; Check if the input is between ASCII '1' and '9'.
  cmp al, '1'
  jl .invalid
  cmp al, '9'
  jg .invalid

  ; Subtract ASCII '1' from our input to get the index of the board array.
  sub al, '1'

  ; If our target position isn't empty, ignore the input.
  cmp byte [board + rax], '_'
  jne .invalid

  ; Set cl to the current_player, then update the board.
  mov cl, byte [current_player]
  mov byte [board+rax], cl

  ; Swap 'X' and 'O' for the current_player.
  cmp cl, 'X'
  je .set_player_to_o
  mov byte [current_player], 'X'
  jmp .invalid
  .set_player_to_o:
  mov byte [current_player], 'O'

  .invalid:
  ret

print_board:
  mov r12b, 0 ; index

  .loop:
  call print_board_line
 
  mov r13b, 0
  call print_board_part
  mov r13b, 1
  call print_board_part
  mov r13b, 0
  call print_board_part
  add r12b, 3

  cmp r12b, 9
  jne .loop

  call print_board_line
  ret

print_board_line:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_line
  mov rdx, board_line_size
  syscall
  ret

print_board_part:
  .loop:

  cmp r13b, 0
  je .blank

  mov r11b, byte [board + r12]
  jmp .print

  .blank:
  mov r11b, byte ' '

  .print:
  mov byte [board_tile + 2], r11b

call print_board_bar
  call print_color

  mov rax, 1
  mov rdi, 1
  mov rsi, board_tile
  mov rdx, 5
  syscall

  call print_reset_color

  inc r12b

  cmp r12b, 3
  je .escape
  cmp r12b,  6
  je .escape
  cmp r12b,  9
  je .escape

  jmp .loop

  .escape:
  call print_board_bar
  call print_newline
  sub r12b, 3
  ret

print_board_bar:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_bar
  mov rdx, 1
  syscall
  ret

print_color:
  cmp byte [board + r12], 'X'
  je .red
  cmp byte [board + r12], 'O'
  je .blue

  call print_reset_color
  ret

  .blue:
  mov byte [color + 8], '4'
  call print_color_bytes
  ret

  .red:
  mov byte [color + 8], '1'
  call print_color_bytes
  ret

print_color_bytes:
  mov rax, 1
  mov rdi, 1
  mov rsi, color
  mov rdx, color_size
  syscall
  ret

print_reset_color:
  mov rax, 1
  mov rdi, 1
  mov rsi, reset
  mov rdx, reset_size
  syscall
  ret

check_gameover:
  mov bpl, byte [board + 0]
  mov r8b, byte [board + 1]
  mov r9b, byte [board + 2]
  mov r10b, byte [board + 3]
  mov r11b, byte [board + 4]
  mov r12b, byte [board + 5]
  mov r13b, byte [board + 6]
  mov r14b, byte [board + 7]
  mov r15b, byte [board + 8]

.row0:
  cmp bpl, '_'
  je .row1
  cmp bpl, r8b
  jne .row1
  mov al, bpl
  cmp r8b, r9b
  je gameover

.col0:
  cmp bpl, r10b
  jne .row1
  mov al, bpl
  cmp r10b, r13b
  je gameover

.diag0:
  cmp bpl, r11b
  jne .row1
  mov al, bpl
  cmp r11b, r15b
  je gameover

.row1:
  cmp r10b, '_'
  je .row2
  cmp r10b, r11b
  jne .row2
  mov al, r10b
  cmp r11b, r12b
  je gameover

.row2:
  cmp r13b, '_'
  je .col1
  cmp r13b, r14b
  jne .col1
  mov al, r13b
  cmp r14b, r15b
  je gameover

.col1:
  cmp r8b, '_'
  je .col2
  cmp r8b, r11b
  jne .col2
  mov al, r8b
  cmp r11b, r14b
  je gameover

.col2:
  cmp r9b, '_'
  je .draw
  cmp r9b, r12b
  jne .diag1
  mov al, r9b
  cmp r12b, r15b
  je gameover

.diag1:
  cmp r9b, r11b
  jne .draw
  mov al, r9b
  cmp r11b, r13b
  je gameover

.draw:
  mov r12, 0

  .draw_loop:
  cmp byte [board+r12], '_'
  je .return
  inc r12b
  cmp r12b, 9
  jne .draw_loop

  jmp gameover.result_draw

.return:
  ret

gameover:
  mov byte [current_player], al

  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_message
  mov rdx, gameover_message_size
  syscall

  ; Deliberatly over-read past the win_message buffer to include the current_player variable.
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_win_message
  mov rdx, gameover_win_message_size + 1
  syscall

  jmp .exit

.result_draw:
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_message
  mov rdx, gameover_message_size + gameover_draw_message_size
  syscall

.exit:
  call print_newline
  mov rax, 60
  mov rdi, 0 
  syscall

print_newline:
  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall
  ret

welcome_message: db "Welcome to Noughts and Crosses.",0xa,"To select a square, choose the square's number from left to right, top to bottom. (1-9)", 0xa, 0xa
welcome_message_size equ $ - welcome_message

gameover_message: db "Game over.", 0xa
gameover_message_size equ $ - gameover_message

gameover_draw_message: db "It's a draw!"
gameover_draw_message_size equ $ - gameover_draw_message

previous_lines: db 0x1b, '[', '14', 'F'
previous_lines_size equ $ - previous_lines

next_lines: db 0x1b, '[', '14', 'E'
next_lines_size equ $ - next_lines

board: db "__________"

board_line: db "-------------------", 0xa
board_line_size equ $ - board_line
board_render_working_buffer: db 0
board_bar: db "|"
board_tile: db "     "

color: db 0x1b, '[', '97', 'm', 0x1b, '[', '44', 'm'
color_size equ $ - color

reset: db 0x1b, '[', '0', 'm'
reset_size equ $ - reset

gameover_win_message: db "Won by: "
gameover_win_message_size equ $ - gameover_win_message
current_player: db 'X'
move_input_message: db "'s move:  ", 0x08
move_input_message_size equ $ - move_input_message

move_input: db 0
ignored_buffer: db 0
newline: db 0xa

program_size equ $ - $$
