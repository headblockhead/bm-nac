BITS 64
  org 0x400000

ehdr:           ; Elf64_Ehdr
  db 0x7f, "ELF", 2, 1, 1, 0 ; e_ident
  times 8 db 0
  dw  2         ; e_type
  dw  0x3e      ; e_machine
  dd  1         ; e_version
  dq  _start    ; e_entry
  dq  program_headers - $$ ; e_phoff
  dq  section_headers - $$ ; e_shoff
  dd  0         ; e_flags
  dw  ehdrsize  ; e_ehsize
  dw  program_header_size  ; e_phentsize
  dw  2         ; e_phnum
  dw  section_header_size  ; e_shentsize
  dw  4         ; e_shnum
  dw  3         ; e_shstrndx
ehdrsize  equ  $ - ehdr

program_headers:

text_program_header:           ; Elf64_Phdr
  dd  1         ; p_type
  dd  5         ; p_flags
  dq  text_section - $$         ; p_offset
  dq  text_section  ;p_vaddr
  dq  text_section  ;p_paddr
  dq  text_section_size  ; p_filesz
  dq  text_section_size  ; p_memsz
  dq  0x1000    ; p_align

program_header_size  equ  $ - program_headers

data_program_header:           ; Elf64_Phdr
  dd  1         ; p_type
  dd  7         ; p_flags
  dq  data_section - $$ ; p_offset
  dq  data_section ;p_vaddr
  dq  data_section ;p_paddr
  dq  data_section_size  ; p_filesz
  dq  data_section_size ; p_memsz
  dq  0x1000    ; p_align

text_section:

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
  mov rax, 1
  mov rdi, 1
  mov rsi, current_player
  mov rdx, move_input_message_size + 1
  syscall

  mov byte [move_input], 0
  mov rax, 0
  mov rdi, 0
  mov rsi, move_input ; set move_input to the index of our move
  mov rdx, 1
  syscall

  cmp byte [move_input], 0xa
  je getmove_invalid

  .loop:
  mov rax, 0
  mov rdi, 0
  mov rsi, ignored_buffer
  mov rdx, 1
  syscall
  cmp byte [ignored_buffer], 0xa
  jne .loop

  cmp byte [move_input], '1'
  jl getmove_invalid ; invalid input, ignore.
  cmp byte [move_input], '9'
  jg getmove_invalid ; invalid input, ignore.

  mov al, byte [move_input]
  sub al, '1'
  mov rdi, rax

  cmp byte [board + rdi], '_'
  jne getmove_invalid ; invalid input, ignore.

  cmp byte [current_player], 'X'
  je set_x
  cmp byte [current_player], 'O'
  je set_o

set_o:
  mov rsi, 'O'
  call set_board_at_index
  mov byte [current_player], 'X'
  ret

set_x:
  mov rsi, 'X'
  call set_board_at_index
  mov byte [current_player], 'O'
  ret

getmove_invalid:
  mov byte [move_input], 0
  ret

; expects rdi to be the index, and rsi to be the value
set_board_at_index:
  mov rax, rdi
  mov byte [board + rax], sil
  ret

print_board:
  mov r12, 0 ; index

  .loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, board
  add rsi, r12
  mov rdx, 3
  syscall
  add r12, 3
  call print_newline
  cmp r12, 9
  jne .loop

  call step_back_cursor

  ret

step_back_cursor:
  mov rax, 1
  mov rdi, 1
  mov rsi, previous_4_lines
  mov rdx, previous_4_lines_size
  syscall
  ret

step_forward_cursor:
  mov rax, 1
  mov rdi, 1
  mov rsi, next_4_lines
  mov rdx, next_4_lines_size
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

  mov rax, 0

  .loop:
  cmp byte [board + rax], '_'
  je gameover_row0_check
  inc rax
  cmp rax, 9
  jne .loop
  mov al, 0
  jmp gameover

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
  ret

gameover:
  cmp al, 0
  je gameover_draw

  mov byte [current_player], al
  jmp gameover_print

gameover_initial_message:
  call step_forward_cursor
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
  mov rax, 1
  mov rdi, 1
  mov rsi, current_player
  mov rdx, 1
  syscall
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_win_message
  mov rdx, gameover_win_message_size
  syscall

gameover_exit:
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

text_section_size  equ  $ - text_section

data_section:

welcome_message: db "Welcome to Noughts and Crosses.", 0xa, 0xa
welcome_message_size equ $ - welcome_message
gameover_message: db "Game over.", 0xa
gameover_message_size equ $ - gameover_message
gameover_win_message: db " wins!"
gameover_win_message_size equ $ - gameover_win_message
gameover_draw_message: db "It's a draw!"
gameover_draw_message_size equ $ - gameover_draw_message
previous_4_lines: db 0x1b, '[', '4', 'F'
previous_4_lines_size equ $ - previous_4_lines
next_4_lines: db 0x1b, '[', '4', 'E'
next_4_lines_size equ $ - next_4_lines
board: times 9 db '_'
current_player: db 'X'
move_input_message: db "'s move: "
move_input_message_size equ $ - move_input_message
move_input: db 0
ignored_buffer: db 0
newline: db 0xa

data_section_size  equ  $ - data_section

scnnm: ; section names
  db 0
shrtrtab_name_offset equ  $ - scnnm
  db ".shrtrtab", 0
text_name_offset equ  $ - scnnm
  db ".text", 0
data_name_offset equ  $ - scnnm
  db ".data", 0

sectnamesize  equ  $ - scnnm

section_headers: ; section headers
  ;sh_name
  dd 0
  ;sh_type
  dd 0
  ;sh_flags
  dq 0
  ;sh_addr
  dq 0
  ;sh_offset
  dq 0
  ;sh_size
  dq 0
  ;sh_link
  dd 0
  ;sh_info
  dd 0
  ;sh_addralign
  dq 0
  ;sh_entsize
  dq 0

section_header_size  equ  $ - section_headers

  ;sh_name
  dd text_name_offset
  ;sh_type
  dd 1
  ;sh_flags
  dq 6
  ;sh_addr
  dq text_section
  ;sh_offset
  dq text_section - $$
  ;sh_size
  dq text_section_size
  ;sh_link
  dd 0
  ;sh_info
  dd 0
  ;sh_addralign
  dq 0
  ;sh_entsize
  dq 0

  ;sh_name
  dd data_name_offset
  ;sh_type
  dd 1
  ;sh_flags
  dq 3
  ;sh_addr
  dq data_section
  ;sh_offset
  dq data_section - $$
  ;sh_size
  dq data_section_size
  ;sh_link
  dd 0
  ;sh_info
  dd 0
  ;sh_addralign
  dq 0
  ;sh_entsize
  dq 0

  ;sh_name
  dd shrtrtab_name_offset
  ;sh_type
  dd 3
  ;sh_flags
  dq 0
  ;sh_addr
  dq 0
  ;sh_offset
  dq scnnm - $$
  ;sh_size
  dq sectnamesize
  ;sh_link
  dd 0
  ;sh_info
  dd 0
  ;sh_addralign
  dq 0
  ;sh_entsize
  dq 0

filesize  equ  $ - $$
