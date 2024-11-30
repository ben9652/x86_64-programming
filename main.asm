.section .text
    .globl main
    .extern ExitProcess
    .extern print_uint

main:
    mov     $123918, %rcx
    call    print_uint

    # Salgo del proceso
    mov     $0, %rcx
    call    ExitProcess
