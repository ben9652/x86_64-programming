.section .rdata
    msg:
        .ascii "Hello World!\n"

.section .text
    .globl print_hello
    .extern GetStdHandle
    .extern WriteFile

print_hello:
    # Obtener el handle de la salida estándar
    # hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)
    mov     $-11, %rcx
    call    GetStdHandle
    mov     %rax, %rcx

    # Imprimir el mensaje
    # WriteFile(hStdOut, message, length(message), &bytes, 0);
    lea     msg(%rip), %rdx             # Guardo la dirección al mensaje como segundo parámetro.
                                        # Básicamente se hace un direccionamiento relativo de la dirección de la
                                        # cadena `msg` con el %rip (instruction pointer, equivalente a PC en ARM)
    mov     $14, %r8                    # Guardo la longitud del mensaje como tercer parámetro
    lea     written_chars(%rip), %r9    # Guardo la dirección a la variable 'bytes' como cuarto parámetro
    xor     %r10, %r10                  # NULL como quinto parámetro
    call    WriteFile

    ret

# Sección del programa que se utiliza para declarar variables no inicializadas o que están inicializadas en 0
.section .bss
    # .lcomm usada para reservar espacio sin inicializar, típicamente usada en secciones .bss
    .lcomm written_chars, 8     # Variable 'bytes'
    .lcomm IoStatusBlock, 8     # Espacio reservado para el estado de la operación de I/O

.section .text
    .globl print_uint

print_uint:
    # Guardo las direcciones de retorno
    mov     (%rsp), %rdi
    mov     8(%rsp), %rsi

    # En caso de que el número ingresado sea 0, poner el registro de conteo de dígitos (%r8) en 1
    cmp     $0, %rcx
    jnz     init_count_digits_loop
    mov     $1, %r8
    jmp     effective_print

init_count_digits_loop:
    # Asigno a %rax el parámetro recibido ya que aquí debe estar el contenido a dividir
    mov     %rcx, %rax

    # Guardo el número por el que quiero dividir en %rbx
    mov     $10, %rbx

    # Inicializo el contador de dígitos en 0
    mov     $0, %r8

count_digits_loop:
    cmp     $0, %rax
    jz      mem_alloc_for_chars_to_print

    # Guardo en %rdx el número 0 ya que la división se hace en el número concatenado %rdx:%rax
    mov     $0, %rdx

    # Divido entre 10 el número guardado en %rax y se guarda aquí mismo el cociente y el resto se guarda en %rdx
    div     %rbx
    inc     %r8
    jmp     count_digits_loop

mem_alloc_for_chars_to_print:
    # Reservo los bytes necesarios para imprimir el número
    mov     %rsp, %rbp
    
    # Guardo en %rax el dividendo contenido en %rcx
    mov     %rcx, %rax
    mov     $0, %r9

get_digits_loop:
    cmp     $0, %rax
    jz      effective_print

    # Guardo en %rdx el número 0 ya que la división se hace en el número concatenado %rdx:%rax
    mov     $0, %rdx

    # Divido entre 10 el número guardado en %rax y se guarda aquí mismo el cociente, y el resto se guarda en %rdx
    div     %rbx
    add     $0x30, %rdx
    dec     %r9
    movb    %dl, (%rsp, %r9)
    jmp     get_digits_loop

effective_print:
    # Guardo los bytes en la pila
    mov     %r9, %rax                   # Se prepara el contenido de %r9 para que sirva de dividendo
    cqo                                 # Concateno el contenido de %rax con el de %rdx, dando como resultado %rdx:%rax
    mov     $8, %r10                    # Asigno el divisor
    idiv    %r10                        # División signada del contenido de %rdx:%rax con el de %r10, poniendo el resultado en %rax y el resto en %rdx
    cmp     $0, %rdx                    # Analizo si el resto es 0
    jz      point_to_string_and_print   # Si el resto resulta en 0 realmente, se salta a esa etiqueta
    dec     %rax                        # El número de prueba por el que dividir se decrementa

point_to_string_and_print:
    lea     (%rsp,%rax,8), %rsp         # Asigno (%rsp + %rax)*8 a %rsp
    jz      printing
    add     $8, %rdx
    mov     %rsp, %r11
    add     %rdx, %r11

printing:
    # Obtener el handler de la salida estándar
    # hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)
    mov     $-11, %rcx                  # Asigno STD_OUTPUT_HANDLE en %rcx, ya que sirve como primer parámetro
    call    GetStdHandle                # Llamo a GetStdHandle
    mov     %rax, %rcx                  # Guardo el handler como primer parámetro

    mov     %r8, %r15                   # Guardo la cantidad de dígitos
    
    # NtWriteFile recibe los siguientes parámetros:
    #   HANDLE                  FileHandle,         %rcx
    #   HANDLE                  Event,              %rdx
    #   PIO_APC_ROUTINE         ApcRoutine,         %r8
    #   PVOID                   ApcContext,         %r9
    #   PIO_STATUS_BLOCK        IoStatusBlock,      (%rsp+0x28)
    #   PVOID                   Buffer,             (%rsp+0x30)
    #   ULONG                   Length,             (%rsp+0x38)
    #   PLARGE_INTEGER          ByteOffset,         (%rsp+0x40)
    #   PULONG                  Key,                (%rsp+0x48)
    xor     %rdx, %rdx
    xor     %r8, %r8
    xor     %r9, %r9
    lea     IoStatusBlock(%rip), %r10

    mov     $0, %r12
    mov     %r15d, %r14d

    # Preparo el stack para almacenar los parámetros restantes de la rutina NtWriteFile (moviendo el stack pointer los lugares necesarios para que entren los parámetros)
    sub     $0x58, %rsp

    mov     %r10, 0x28(%rsp)        # IoStatusBlock
    mov     %r11, 0x30(%rsp)        # Buffer
    mov     %r14d, 0x38(%rsp)       # Longuitud del buffer (ULONG Lenght)
    mov     %r12, 0x40(%rsp)        # ByteOffset = NULL (PLARGE_INTEGER ByteOffset)
    mov     %r12, 0x48(%rsp)        # Key = NULL (PULONG Key)

    # La rutina NtWriteFile requiere que el handler esté en el registro 10
    mov     %rcx, %r10

    # El registro A debe tener el valor 8 para llamar la syscall NtWriteFile
    mov     $0x08, %eax
    syscall

    # Me deshago de los parámetros usados para la rutina NtWriteFile (volviendo el stack pointer a donde estaba)
    add     $0x58, %rsp

    # Aquí me encargo de calcular si la cantidad de caracteres (número contenido en %r15) que se
    # ocuparon es múltiplo de 8 para desapilar correctamente los caracteres del número ingresado

    push    %rax                # Guardo el resultado de la impresión por pantalla
    mov     $0, %rdx            # Preparo como 0 la parte superior del dividendo
    mov     %r15, %rax          # Paso la cantidad de dígitos a la parte inferior del dividendo
    mov     $8, %r8             # El divisor es 8
    div     %r8                 # Divido la cantidad de dígitos (caracteres apilados en el stack) entre 8
    cmp     $0, %rdx            # Me fijo si el resto de esta operación es 0
    jz      is_multiple_of_8    # Si efectivamente es 0, que se salte nomas para is_multiple_8
    inc     %rax                # Si el número de la cantidad de dígitos no es divisible entre 8, que se incremente en 1

is_multiple_of_8:
    # Recupero el valor de retorno y regreso al stack pointer al punto original en el que estaba antes de apilar los caracteres
    mov     %rax, %r8           # Paso el número que servirá como offset del stack pointer al registro %r8
    pop     %rax                # Recupero el resultado de la impresión por pantalla
    lea     (%rsp,%r8,8), %rsp  # Asigno (%rsp + %r8)*8 a %rsp

    # Recupero los valores que tenía la pila antes de la ejecución de esta subrutina
    mov     %rdi, (%rsp)
    mov     %rsi, 8(%rsp)
    mov     $0, %r10
    mov     %r10, 16(%rsp)

    ret
