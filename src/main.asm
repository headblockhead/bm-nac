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
  mov r12, 0 ; index

  .loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_line
  mov rdx, board_line_size
  syscall

  call print_board_spaces
  sub r12, 3
  call print_board_letters
  sub r12, 3
  call print_board_spaces

  cmp r12, 9
  jne .loop

  mov rax, 1
  mov rdi, 1
  mov rsi, board_line
  mov rdx, board_line_size
  syscall

  ret

print_board_letters:
  .loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_bar
  mov rdx, 1
  syscall
  
  cmp byte [board + r12], 'X'
  je .red
  cmp byte [board + r12], 'O'
  je .blue

  .black:
  mov rax, 1
  mov rdi, 1
  mov rsi, reset
  mov rdx, reset_size
  syscall
  jmp .continue

  .blue:
  mov rax, 1
  mov rdi, 1
  mov rsi, blue
  mov rdx, blue_size
  syscall
  jmp .continue

  .red:
  mov rax, 1
  mov rdi, 1
  mov rsi, red
  mov rdx, red_size
  syscall

  .continue:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_space
  mov rdx, 2
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, board
  add rsi, r12
  mov rdx, 1
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, board_space
  mov rdx, 2
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, reset
  mov rdx, reset_size
  syscall

  inc r12

  cmp r12, 3
  je .escape
  cmp r12, 6
  je .escape
  cmp r12, 9
  je .escape

  jmp .loop

  .escape:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_bar
  mov rdx, 1
  syscall
  call print_newline
  ret


print_board_spaces:
  .loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_bar
  mov rdx, 1
  syscall
  
  cmp byte [board + r12], 'X'
  je .red
  cmp byte [board + r12], 'O'
  je .blue

  .black:
  mov rax, 1
  mov rdi, 1
  mov rsi, reset
  mov rdx, reset_size
  syscall
  jmp .continue

  .blue:
  mov rax, 1
  mov rdi, 1
  mov rsi, blue
  mov rdx, blue_size
  syscall
  jmp .continue

  .red:
  mov rax, 1
  mov rdi, 1
  mov rsi, red
  mov rdx, red_size
  syscall

  .continue:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_space
  mov rdx, 5
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, reset
  mov rdx, reset_size
  syscall

  inc r12

  cmp r12, 3
  je .escape
  cmp r12, 6
  je .escape
  cmp r12, 9
  je .escape

  jmp .loop

  .escape:
  mov rax, 1
  mov rdi, 1
  mov rsi, board_bar
  mov rdx, 1
  syscall
  call print_newline
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

gameover_row0_check:
  cmp bpl, '_'
  je gameover_row1_check
  cmp bpl, r8b
  jne gameover_row1_check
  mov al, bpl
  cmp r8b, r9b
  je gameover

gameover_row1_check:
  cmp r10b, '_'
  je gameover_row2_check
  cmp r10b, r11b
  jne gameover_row2_check
  mov al, r10b
  cmp r11b, r12b
  je gameover

gameover_row2_check:
  cmp r13b, '_'
  je gameover_col0_check
  cmp r13b, r14b
  jne gameover_col0_check
  mov al, r13b
  cmp r14b, r15b
  je gameover

gameover_col0_check:
  cmp bpl, '_'
  je gameover_col1_check
  cmp bpl, r10b
  jne gameover_col1_check
  mov al, bpl
  cmp r10b, r13b
  je gameover

gameover_col1_check:
  cmp r8b, '_'
  je gameover_col2_check
  cmp r8b, r11b
  jne gameover_col2_check
  mov al, r8b
  cmp r11b, r14b
  je gameover

gameover_col2_check:
  cmp r9b, '_'
  je gameover_diag0_check
  cmp r9b, r12b
  jne gameover_diag0_check
  mov al, r9b
  cmp r12b, r15b
  je gameover

gameover_diag0_check:
  cmp bpl, '_'
  je gameover_diag1_check
  cmp bpl, r11b
  jne gameover_diag1_check
  mov al, bpl
  cmp r11b, r15b
  je gameover

gameover_diag1_check:
  cmp r9b, '_'
  je gameover_return
  cmp r9b, r11b
  jne gameover_return
  mov al, r9b
  cmp r11b, r13b
  je gameover

gameover_return:

  mov rax, 0
  .loop:
  cmp byte [board + rax], '_'
  je .return
  inc rax
  cmp rax, 9
  jne .loop
  mov al, 0
  jmp gameover
  .return:
  ret

gameover:
  cmp al, 0
  je gameover_draw

  mov byte [current_player], al
  jmp gameover_print

gameover_initial_message:
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_message
  mov rdx, gameover_message_size
  syscall
  ret

gameover_draw:
  call gameover_initial_message
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_draw_message
  mov rdx, gameover_draw_message_size
  syscall
  jmp gameover_exit

gameover_print:
  call gameover_initial_message
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_win_message
  mov rdx, gameover_win_message_size + 1
  syscall

gameover_exit:
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
board_space: db "     "

blue: db 0x1b, '[', '97', 'm', 0x1b, '[', '44', 'm'
  blue_size equ $ - blue

red: db 0x1b, '[', '97', 'm', 0x1b, '[', '41', 'm'
  red_size equ $ - red

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
