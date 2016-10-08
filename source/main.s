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

.section .data              //要做一个sos的led灯的闪烁,所以需要数据,莫斯码的sos是...---...,滴滴滴答答答滴滴滴
.align 2                    //确保所存入的地址是2^2(即4)的倍数的地址
pattern:
.int    0b11111111101010100010001000101010  //将数字保存到输出,即原样保存
