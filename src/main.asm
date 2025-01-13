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

  .loop:
  call get_move
  call print_board
  call check_gameover
  jmp .loop

get_move: 
  mov byte [move_input], 0
  mov rax, 0
  mov rdi, 0
  mov rsi, move_input ; set move_input to the index of our move
  mov rdx, 1
  syscall

  cmp byte [move_input], '0'
  jl get_move ; invalid input, ignore.
  cmp byte [move_input], '9'
  jg get_move ; invalid input, ignore.

  mov rax, 0
  mov rdi, 0
  mov rsi, 0 ; ignore input
  mov rdx, 1

  cmp byte [current_player], 'X'
  je set_x
  cmp byte [current_player], 'O'
  je set_o

set_o:
  mov al, byte [move_input]
  sub al, '0'
  mov rdi, rax
  mov rsi, 'O'
  call set_board_at_index
  mov byte [current_player], 'X'
  ret

set_x:
  mov al, byte [move_input]
  sub al, '0'
  mov rdi, rax
  mov rsi, 'X'
  call set_board_at_index
  mov byte [current_player], 'O'
  ret

; expects rdi to be the index, and rsi to be the value
set_board_at_index:
  mov rax, 0
  mov rax, rdi
  mov byte [board + rax], sil
  ret

print_board:
  mov rax, 1
  mov rdi, 1
  mov rsi, board
  mov rdx, 9
  syscall
  call print_newline
  ret

check_gameover:
  ; TODO
  ret

gameover:
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_message
  mov rdx, 11
  syscall
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

welcome_message: db "Welcome to Noughts and Crosses.", 0xa
welcome_message_size equ $ - welcome_message
gameover_message: db "Game over.", 0xa
board: times 9 db ' '
current_player: db 'X'
move_input: db 0
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
