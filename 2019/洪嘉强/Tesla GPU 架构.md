Tesla GPU 架构
===

一、GPU架构
---

NVIDIA 的 GPU 计算产品被称作 Tesla，这是从第一代针对 GPU 计算的 G80（Tesla 8，当时的 GPU 微架构也叫 Tesla）开始，NVIDIA 将传统微架构意义上的内核称作 streaming multiprocessor，简称 SM 或 SMX，SM 对来自并行运行的众多线程的指令进行创建、管理、调度和执行，而“内核”这个称呼则被 NVIDIA 用作 SIMD 中单个处理单元。<br>

二、GPU整体结构
---

>Streaming Multiprocessor(SM) 
>>A set of CUDA cores (SP)
>>其他资源
>Global memory


三、SM 结构
---

控制单元

    Warp 调度器
    指令分发器

执行单元

    CUDA cores/SP
    special function units (SFU)
    load/store units (LD/ST)

Memory

    64K 32-bit registers
    Cache
        Texture/Constant memory
        L1 Cache
        Shared memory
