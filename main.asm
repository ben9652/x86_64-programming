.section .text
    .globl main
    .extern ExitProcess
    .extern print_uint

main:
    # Prólogo para alinear stack según Windows x64 calling convention
    push    %rbp
    mov     %rsp, %rbp
    sub     $32, %rsp           # Shadow space requerido por Windows x64
    
    mov     $123918, %rcx
    call    print_uint

    # Salir del proceso correctamente
    mov     $0, %rcx            # Exit code 0
    call    ExitProcess
    
    # En caso de que ExitProcess falle (no debería llegar aquí)
    add     $32, %rsp
    pop     %rbp
    ret
