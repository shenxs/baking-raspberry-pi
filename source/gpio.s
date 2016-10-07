.globl GetGpioAddress

GetGpioAddress:
    ldr     r0,=0x20200000
    mov     pc,lr

.globl SetGpioFunction
SetGpioFunction:
    cmp     r0,#53      //r0 应该小于等于53,如果不是则跳过下一条指令直接movhi
    cmpls   r1,#7       //r1 小于等于7
    movhi   pc,lr       //如果上一次的比较结果是大于则mov
    push    {lr}        //下面有bl指令会改写lr,所以先保存一下
    mov     r2,r0       //理论上,函数会改变r0-3,好在我们知道GetGpioAddress不会,所以只保存r0
    bl      GetGpioAddress
//r0存这GPIO的地址
//r1是函数指令,r2是GPIO的pin number
    functionLoop$:
        cmp     r2,#9
        subhi   r2,#10
        addhi   r0,#4
        bhi     functionLoop$
//现在r2中存着r2除10的余数,r0现在存着pin的函数设定的控制器对的地址
    add     r2, r2,lsl #1       //r2=r2*2+r2 ,为什么不直接×3?,但是寄存器的位移操作比较快
    lsl     r1,r2               //r1左移r2
    str     r1,[r0]             //将函数指令存到函数地址中
    pop     {pc}                //作用等同于mov pc,lr,因为之前lr存在栈里,现在将他pop给pc

//这个函数会覆盖其他的不必要的function变成0

.globl SetGpio          //若r1是0就关闭,如果还是其他数字就打开,r0参数代表GPIO 的pin 数字
SetGpio:
    pinNum  .req r0     //给r0,r1设定别名
    pinVal  .req r1
    cmp     pinNum,#53
    movhi   pc,lr       //如果pin数字大于53函数就退出
    push    {lr}        //否则保存返回地址
    mov     r2,pinNum   //将r0腾出来,因为即将调用函数会覆盖r0
    .unreq  pinNum      //将pinNum别名取消
    pinNum  .req r2     //赋予r2别名
    bl      GetGpioAddress  //将r0设定为Gpio地址
    gpioaderess .req r0 //现在r0存着的是gpio的地址了
    //GPIO控制器有两组4字节 ,用来控制pin的开和关
    //前4字节控制前32个,后面的控制剩下的22个,所以需要将pin number除以32,以决定使用那一组bytes
    //÷32只要将寄存器右移5位就好了
    pinBank .req r3
    lsr     pinBank,pinNum,#5
    lsl     pinBank,#2
    add     gpioaderess,pinBank //如果是第一组的管脚的话那么pinBank是0,gpioaderess的地址还是初始的地址,但是如果pin管脚的编号在第二组的话,那么gpioadress的地址会加4
    .unreq  pinBank     //取消别名

    and     pinNum,#31      //确定要置一的管脚的号码
    setBit  .req r3
    mov     setBit,#1
    lsl     setBit,pinNum   //将1移动到想要的管脚
    .unreq  pinNum

    teq     pinVal,#0       //确定pinVal 和 0是否想等,test equal
    .unreq  pinVal          //取消别名
    streq   setBit,[gpioaderess,#40]    //如果相等将setBit存到gpioaddresss+40的地址中,将管脚关闭
    strne   setBit,[gpioaderess,#28]    //如果不相等那么将,setBit存到gpioAddress+28中,将管脚打开
    .unreq  setBit
    .unreq  gpioaderess
    pop     {pc}            //打完收工
