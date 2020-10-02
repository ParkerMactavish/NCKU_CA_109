.data
pChr: .string "StringInArg"
str1: .string "%s\nnormalString\nCharInArg: %c\nPercentSign: %%\nNot supporting: %e%e%r%d\nHex0: %x    %X\nHex1: %x    %X\nHex2: %x    %X\nOct: %o\nBin: %b"

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

    la   t0, str1           # "%s\nnormalString\nCharInArg%c\nNot supporting: %e%e%r%d\nHex0: %x    %X\nHex1: %x    %X\nHex2: %x    %X\nOct: %o\nBin: %b"
    addi sp, sp, -44
    sw   t0, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)
    sw   s2, 16(sp)
    sw   s3, 20(sp)
    sw   s3, 24(sp)
    sw   s4, 28(sp)
    sw   s4, 32(sp)
    sw   s5, 36(sp)
    sw   s6, 40(sp)
    jal  self_print
    addi sp, sp, 44
    addi a0, zero, 0        # return 0
    addi a7, zero, 93
    ecall

self_print:
    lw   t0, 0(sp)          # const char* format
    addi t1, sp, 4          # va_list ap; va_start(ap, format);
    addi sp, sp, -40        # int shiftAmt;
                            # int capFlag;
                            # char digits[32];
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
    bne  t2, t3, case_c_end # case 'c'
    lw   a0, 0(t1)
    addi t1, t1, 4          # (char)va_arg(ap, int)
    addi a7, zero, 11
    ecall                   # putchar
    jal  zero, while_begin
    case_c_end:

    addi t3, zero, 120
    bne  t2, t3, case_x_end # case 'x'
    addi t2, zero, 0        # capFlag = 0
    sw   t2, 32(sp)         # store capFlag
    jal  zero, case_xX_begin
    case_x_end:
    addi t3, zero, 88
    bne  t2, t3, case_xX_end # case 'X'
    addi t2, zero, 1        # capFlag = 0
    sw   t2, 32(sp)         # store capFlag
    case_xX_begin:
    addi t3, zero, 4        # shiftAmt = 4
    sw   t3, 36(sp)         # store shiftAmt
    addi t4, zero, 15       # remain = 15
    jal  zero, switch_end
    case_xX_end:

    addi t3, zero, 111
    bne  t2, t3, case_o_end # case 'o'
    addi t3, zero, 3        # shfitAmt = 3
    sw   t3, 36(sp)         # store shiftAmt
    addi t4, zero, 7        # remain = 7
    jal  zero, switch_end
    case_o_end:

    addi t3, zero, 98
    bne  t2, t3, case_b_end # case 'b'
    addi t3, zero, 1        # shiftAmt = 1
    sw   t3, 36(sp)         # store shiftAmt
    addi t4, zero, 1        # remain = 7
    jal  zero, switch_end
    case_b_end:
    
    addi t3, zero, 37
    bne  t2, t3, case_%_end # case '%'
    addi a0, zero, 37
    addi a7, zero, 11
    ecall                   # putchar('%')
    jal  zero, while_begin
    case_%_end:

    addi a0, t2, 0
    addi a7, zero, 11
    ecall                   # putchar(chr)
    jal  zero, while_begin

    switch_end:
    lw   t5, 0(t1)          
    addi t1, t1, 4          # value = va_arg(ap, unsigned int); 
    addi t6, zero, 0        # digitIdx = 0
    parse:
    and  t2, t5, t4         # digit = (char)(value & remain);
    srl  t5, t5, t3         # value >> = shiftAmt;
    addi t2, t2, -10
    blt  t2, zero, not_Hex  # if(digit > 9)
    lw   t3, 32(sp)         # load capFlag
    slli t3, t3, 5          # 0x20 if capFlag == 1
    xor  t3, t3, zero       # 0x20 if capFlag == 0
    addi t3, t3, 7          # (capFlag)?0x7:0x27
    add  t2, t2, t3         # digit += (capFlag)?0x7:0x27;
    lw   t3, 36(sp)         # load shiftAmt
    not_Hex:
    addi t2, t2, 58         # digit + '0' + 10@L:112
    add  t6, t6, sp         # &digits[digitIdx]
    sw   t2, 0(t6)          # digits[digitIdx] = digit + '0';
    sub  t6, t6, sp         # restore digitIdx
    addi t6, t6, 1          # digitIdx ++
    ble  t5, zero, dump     
    addi t2, zero, 32
    blt  t6, t2, parse      # while(value && digitIdx < sizeof(digits));
    dump:
    addi t6, t6, -1         # -- digitIdx
    add  t6, t6, sp         # &digits[--digitIdx]
    lb   a0, 0(t6)
    addi a7, zero, 11
    ecall                   # putchar(digits[--digitIdx]);
    sub  t6, t6, sp         # restore digitIdx
    bgt  t6, zero, dump     # while(digitIdx)
    jal  zero, while_begin

    else:                   # else
    addi a0, t2, 0
    addi a7, zero, 11
    ecall                   # putchar(chr);
    jal  zero, while_begin
    while_end:
    
    jalr zero, ra, 0