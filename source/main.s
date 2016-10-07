.section .init
.globl _start
_start:
    b       main        //跳转到main

.section .text
main:
    mov     sp,#0x8000

    pinNum  .req r0
    pinFunc .req r1
    mov     pinNum,#16
    mov     pinNum,#1
    bl      SetGpioFunction  //打开enable ok  LED
    .unreq  pinNum
    .unreq  pinFunc

    pinNum  .req r0
    pinVal  .req r1
    mov     pinNum,#16
    mov     pinVal,#0
    bl      SetGpio         //打开 ok LED
    .unreq  pinNum
    .unreq  pinVal

    loop$:
        b loop$
