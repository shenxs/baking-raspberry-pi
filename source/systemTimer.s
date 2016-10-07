.globl GetSystemTimerBase
GetSystemTimerBase:
    ldr     r0,=0x20003000      //时间计数器的基址
    mov     pc,lr               //函数返回

.globl GetTimeStamp
GetTimeStamp:                   //返回时间戳
    push    {lr}
    bl      GetSystemTimerBase  //先获取基址时间
    ldrd    r0,r1,[r0,#4]       //将时间戳放在r0,r1,r0为低32位
    pop     {pc}                //函数返回


.globl SystemWait               //r0中存放需要延迟的时间,μs
    delay   .req r2
    mov     delay,r0            //先保存一下r0
    push    {lr}
    bl      GetTimeStamp        //r0中为当前的时间戳
    start   .req r3
    mov     start,r0            //记录下干开始的时间戳

loop$:
    bl      GetTimeStamp
    elapsed .req r1             //用于记录已经过去的时间
    sub     elapsed,r0,start    //将现在的时间与开始时间相减保存在elapesed中
    cmp     elapsed,delay       //比较,过去的时间是否大于需要延迟的时间
    .unreq  elapsed
    bls     loop$               //如果比较出来结果是小于则循环

    .unreq  delay
    .unreq  start
    pop     {pc}                //收工返回




