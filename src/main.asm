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

  mov byte [board + 3], 'X'

  call print_board
  call gameover

print_board:
  mov rax, 1
  mov rdi, 1
  mov rsi, board
  mov rdx, 9
  syscall
  ret

gameover:
  mov rax, 1
  mov rdi, 1
  mov rsi, gameover_message
  mov rdx, 11
  syscall
  mov rax, 60
  xor rdi, rdi
  syscall

text_section_size  equ  $ - text_section

data_section:

welcome_message: db "Welcome to Noughts and Crosses.", 0xa
welcome_message_size equ $ - welcome_message
gameover_message: db "Game over.", 0xa
board: times 9 db ' '

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
