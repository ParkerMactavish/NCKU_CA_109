#include <stdio.h>
#include <stdarg.h>

void self_printf(
    const char* format,
    ...
){
    va_list ap;
    va_start(ap, format);
    char chr, *pChr, digit, digits[32];
    int value, shiftAmt = 0, remain, capFlag, digitIdx;
    int sg, exp, fraction;
    while(chr = *format ++) {
        if(chr == '%'){
            switch(chr = *format++){
                case 's':
                    for(pChr = va_arg(ap, char*);*pChr;pChr++)
                        putchar(*pChr);
                    break;
                case 'c':
                    putchar((char)va_arg(ap, int));
                    break;
                case 'x': 
                    capFlag = 0;
                case 'X':
                    capFlag = 1;
                    shiftAmt = 4;
                    remain = 15;
                    break;
                case 'o':
                    shiftAmt = 3;
                    remain = 7;
                    break;
                case 'b':
                    shiftAmt = 1;
                    remain = 1;
                    break;
                case '%':
                    putchar('%');
                    break;
                default:
                    putchar(chr);
            }
            if(shiftAmt){
                value = va_arg(ap, unsigned int);
                digitIdx = 0;
                do {
                    digit = (char)(value & remain);
                    value >>=shiftAmt;
                    if(digit > 9){
                        digit += (capFlag)?0x7:0x27;
                    }
                    digits[digitIdx++] = digit + '0';
                }while(value && digitIdx < sizeof(digits));
                do {putchar(digits[--digitIdx]);}while(digitIdx);
                shiftAmt = 0;
            }
            continue;
        }
        else{
            putchar(chr);
        }        
    }
}

int main(int argc, char* argv[]){
    char* pChr = "StringInArg";
    char chr = 'c';
    unsigned int    testHex0 = 0x102345,
                    testHex1 = 0x6789AB,
                    testHex2 = 0xCDEF,
                    testOct = 012345670,
                    testBin = 0b00111011000101001111010100001111;
    self_printf("%s\nnormalString\nCharInArg%c\n", pChr, chr);
    self_printf("Not supporting: %e%e%r%d\n");
    self_printf("Hex0: %x\t%X\n", testHex0, testHex0);
    self_printf("Hex1: %x\t%X\n", testHex1, testHex1);
    self_printf("Hex2: %x\t%X\n", testHex2, testHex2);
    self_printf("Oct: %o\n", testOct);
    return 0;
}