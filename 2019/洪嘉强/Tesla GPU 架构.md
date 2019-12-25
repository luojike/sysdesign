Tesla GPU 架构
===

一、GPU架构
---

NVIDIA 的 GPU 计算产品被称作 Tesla，这是从第一代针对 GPU 计算的 G80（Tesla 8，当时的 GPU 微架构也叫 Tesla）开始，NVIDIA 将传统微架构意义上的内核称作 streaming multiprocessor，简称 SM 或 SMX，SM 对来自并行运行的众多线程的指令进行创建、管理、调度和执行，而“内核”这个称呼则被 NVIDIA 用作 SIMD 中单个处理单元。<br>

二、GPU整体结构
---

>Streaming Multiprocessor(SM) 
>>A set of CUDA cores (SP)<br>
>>其他资源<br>
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

四、Pascal GPU
---

Pascal 是 NVIDIA 引入 GPU 计算后的第五代 GPU 架构。在NVIDIA GTC2016 上首次向公众公布了基于 Pascal 的两款 GPU：Tesla P100 和架构名尚不清楚的中端版 Pascal。其中，Tesla P100 采用顶级大核心 GP100 <br>

五、GP100 GPU 参数
---

6 个图形处理簇（GPC）

    每个 GPC 包含 10 个 SM，共 60 个 SM
        64 个单精 CUDA Cores/32 个双精 CUDA Cores
        4 个纹理单元
        2 个分块区，每个含有 1 个 Warp 调度器，2 个指令分发器

30 个纹理处理簇（TPC）

    分布在 2 个 SM 内

240 纹理单元
3840 单精度 CUDA Cores/1920 双精度 CUDA Cores
8 个 512 位内存控制器（共 4096 位）

    每个内存控制器搭配 512KB L2 Cache，共 4096KB L2 Cache
    每个 HBM2 DRAM 堆栈由一对内存控制器控制


六、GP100 GPU 参数
---

GP100 的 SM 包括 64 个单精度 CUDA 核心。而 Maxwell 和 Kepler 的 SM 分别有 128 和 192 个单精度 CUDA 核心。虽然 GP100 SM 只有 Maxwell SM 中 CUDA 核心数的一半，但总的 SM 数目增加了，每个 SM 保持与上一代相同的寄存器组，则总的寄存器数目增加了。这意味着 GP100 上的线程可以使用更多寄存器，也意味着 GP100 相比旧的架构支持更多线程、warp 和线程块数目。与此同时，GP100 总共享内存量也随 SM 数目增加而增加了，带宽显著提升不至两倍。<br>

七、GP100 架构特性
---

高性能低功耗

    支持单精度、双精度、半精度，适合 HPC 和 Deep Learning
    支持 FMA
    工艺 16 纳米 FinFET，300w
    顶级大核心 P100
        5.3 TFLOPS 的双精度浮点 (FP64) 性能
        10.6 TFLOPS 的单精度 (FP32) 性能
        21.2 TFLOPS 的半精度 (FP16) 性能 

HBM2 高速 GPU 内存架构

    HBM2 内存是堆栈式内存并且与 GPU 处于同一个物理封装内
    高带宽：720GB/s
    高容量：16GB

Pascal 流式多处理器

    SM 核心数减少，核心利用率提高
        每个 SM 的寄存器和 warp 数\线程数不变
        每个 SM 的shared memory 为 64KB

NVLink 高速互联技

    P100
        每个GPU支持 4 个 Nvlink 链路
        每个链路单向 20GB/s，双向 40GB/s

简化编程

    统一内存
        CPU 和 GPU 内存提供无缝统一的单一虚拟地址空间
        编程和内存模型简单
    计算抢占
        可防止长期运行的应用程序独占系统 (防止其它应用程序运行)
        程序员无再需要修改其长期运行的应用程序即可使其很好地兼容其它 GPU 应用程序

目前市场上的NVIDIA显卡都是基于Tesla架构的，分为G80、G92、GT200三个系列。Tesla体系架构是一块具有可扩展处器数量的处理器阵列。每个GT200 GPU包含240个流处理器（streaming processor,SP），每8个流处理器又组成了一个流多处理器(streaming multiprocessor,SM)，因此共有30个流多处理器。GPU在工作时，工作负载由PCI-E总线从CPU传入GPU显存，按照体系架构的层次自顶向下分发。PCI-E 2.0规范中，每个通道上下行的数据传输速度达到了5.0Gbit/s，这样PCI-E2.0×16插槽能够为上下行数据各提供了5.0*16Gbit/s=10GB/s的带宽，故有效带宽为8GB/s,而PCI-E 3.0规范的上下行数据带宽各为20GB/s。但是由于PCI-E数据封包的影响，实际可用的带宽大约在5-6GB/s（PCI-E 2.0 ×16）。 Normal 0 7.8 磅 0 2 false false false EN-US ZH-CN X-NONE
在GT200架构中，每3个SM组成一个TPC（Thread Processing Cluster，线程处理器集群），而在G80架构中，是两个SM组成一个TPC，G80里面有8个TPC，因为G80有128(2*8*8)个流处理器，而GT200中TPC增加到了10(3*10*8)个，其中，每个TPC内部还有一个纹理流水线。<br>
大多数时候，称呼streaming processor为流处理器，其实并不太正确，因为如果称streaming processor为流处理器的话，自然是隐式的与CPU相对，但是CPU有独立的一套输入输出机构，而streaming processor并没有，不能在GPU编程中使用printf就是一个例证。将SM与CPU的核相比更加合适。和现在的CPU的核一样，SM也拥有完整前端。<br>
GT200和G80的每个SM包含8个流处理器。流处理器也有其他的名称，如线程处理器，“核”等，而最新的Fermi架构中，给了它一个新的名称:CUDA Core。 SP并不是独立的处理器核，它有独立的寄存器和程序计数器(PC)，但没有取指和调度单元来构成完整的前端（由SM提供）。因此，SP更加类似于当代的多线程CPU中的一条流水线。SM每发射一条指令，8个SP将各执行4遍。因此由32个线程组成的线程束（warp）是Tesla架构的最小执行单位。由于GPU中SP的频率略高于SM中其他单元的两倍，因此每两个SP周期SP才能对片内存储器进行一次访问，所以一个warp中的32个线程又可以分为两个half-warp，这也是为什么取数会成为运算的瓶颈原因。Warp的大小对操作延迟和访存延迟会产生影响，取Warp大小为32是NVIDIA综合权衡的结果。<br>
SM最主要的执行资源是8个32bit ALU和MAD（multiply-add units，乘加器）。它们能够对符合IEEE标准的单精度浮点数（对应float型）和32-bit整数（对应int型，或者unsigned int型）进行运算。每次运算需要4个时钟周期（SP周期，并非核心周期）。因为使用了四级流水线，因此在每个时钟周期，ALU或MAD都能取出一个warp 的32个线程中的8个操作数，在随后的3个时钟周期内进行运算并写回结果。<br>
每个SM中，还有一个共享存储器(Shared memory),共享存储器用于通用并行计算时的共享数据和块内线程通信，但是由于它采用的是片上存储器，其速度极快，因此也被用于优化程序性能。<br>
每个SM 通过使用两个特殊函数(Special Function Unit,SFU)单元进行超越函数和属性插值函数（根据顶点属性来对像素进行插值）计算。SFU用来执行超越函数、插值以及其他特殊运算。SFU执行的指令大多数有16个时钟周期的延迟，而一些由多个指令构成的复杂运算，如平方根或者指数运算则需要32甚至更多的时钟周期。SFU中用于插值的部分拥有若干个32-bit浮点乘法单元，可以用来进行独立于浮点处理单元(Float Processing Unit,FPU)的乘法运算。SFU实际上有两个执行单元，每个执行单元为SM中8条流水线中的4条服务。向SFU发射的乘法指令也只需要4个时钟周期。<br>
在GT200中，每个SM还有一个双精度单元，用于双精度计算，但是其计算能力不到单精度的1/8。<br>
控制流指令（CMP,比较指令）是由分支单元执行的。GPU没有分支预测机制，因此在分支得到机会执行之前，它将被挂起，直到所有的分支路径都执行完成，这会极大的降低性能。<br>
