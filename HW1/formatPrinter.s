.data
pChr: .string "StringInArg"
str1: .string "%s\nnormalString\nCharInArg%c\nNot supporting: %e%e%r%d\nHex0: %x    %X\nHex1: %x    %X\nHex2: %x    %X\nOct: %o\n"

.text
main:
    la   s0, pChr           # pChr = "StringInArg"
    addi s1, zero 99        # chr = 'c'
    lui  s2, 0x102
    addi s2, s2, 0x345      # testHex0 = 0x102345
    lui  s3, 0x679
    addi s3, s3, -0x655     # testHex1 = 0x6789AB
    lui  s4, 0xD
    addi s4, s4, -0x211     # testHex2 = 0xCDEF
    lui  s5, 0x29d
    addi s5, s5, -0x448     # testOct = 0o12345670
    lui  s6, 0x3b14f
    addi s6, s6, 0x50f      # testBin = 0b00111011000101001111010100001111 = 0x3b14f50f

    la   t0, str1           # "%s\nnormalString\nCharInArg%c\nNot supporting: %e%e%r%d\nHex0: %x    %X\nHex1: %x    %X\nHex2: %x    %X\nOct: %o\n"
    addi sp, sp, -32
    sw   t0, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)
    sw   s3, 16(sp)
    sw   s4, 20(sp)
    sw   s5, 24(sp)
    sw   s6, 28(sp)
    jal  self_print
    addi sp, sp, 32
    addi a0, zero, 0        # return 0
    addi a7, zero, 93
    ecall

self_print:
    lw   t0, 0(sp)          # const char* format
    addi t1, sp, 4          # va_list ap; va_start(ap, format);

    while_begin:
    lb   t2, 0(t0)          # chr = *format
    beq  t2, zero, while_end
    addi t0, t0, 1          # format++
    addi t3, zero, 37       # '%'
    bne  t2, t3, else       # if(chr == '%')
    lb   t2, 0(t0)          # chr = *format
    addi t0, t0, 1          # format ++

    addi t3, zero, 115
    bne  t2, t3, case_s_end # case 's'
    lw   t3, 0(t1)
    addi t1, t1, 4          # pChr = va_arg(ap, char*)
    lb   t4, 0(t3)          
    case_s:                 # for loop
    beq  t4, zero, else_end # *pChr != 0
    addi a0, t4, 0
    addi a7, zero, 11
    ecall                   # putchar(*pChr)
    addi t3, t3, 1
    lb   t4, 0(t3)
    jal  zero, case_s
    case_s_end:

    addi t3, zero, 99
    bne  t2, t3, case_c_end # case 's'
    lw   a0, 0(t1)
    addi t1, t1, 4          # (char)va_arg(ap, int)
    addi a7, zero, 11
    ecall                   # putchar
    case_c_end:

    jal  zero, else_end
    else:                   # else
    addi a0, t2, 0
    addi a7, zero, 11
    ecall                   # putchar(chr);
    else_end:               # end if(chr == '%')
    jal  zero, while_begin
    while_end:
    jalr zero, ra, 0