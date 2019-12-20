# Tesla GPU架构分析 #
# 目录
+ GPU简介
+ Fermi架构
+ Kepler 架构
+ Pascal 架构
## GPU简介 ##
图形处理单元GPU英文全称Graphic Processing Unit，GPU是相对于CPU的一个概念，NVIDIA公司在1999年发布GeForce256图形处理芯片时首先提出GPU的概念。GPU使显卡减少了对CPU的依赖，并进行部分原本CPU的工作(主要是并行计算部分)。GPU具有强大的浮点数编程和计算能力，在计算吞吐量和内存带宽上，现代的GPU远远超过CPU。
### GPU组成 
GPU从大的方面来讲，就是由显存和计算单元组成：
显存（Global Memory）：显存是在GPU板卡上的DRAM，类似于CPU的内存，就是那堆DDR啊，GDDR5啊之类的。特点是容量大（可达16GB），速度慢，CPU和GPU都可以访问。
计算单元（Streaming Multiprocessor）：执行计算的。每一个SM都有自己的控制单元（Control Unit），寄存器（Register），缓存（Cache），指令流水线（execution pipelines）。
### Streaming Multiprocessor (SM)
在GP100里，每一个SM有两个SM Processing Block（SMP），里边的绿色的就是CUDA Core，CUDA core也叫Streaming Processor（SP）。每一个SM有自己的指令缓存，L1缓存，共享内存。而每一个SMP有自己的Warp Scheduler、Register File等。要注意的是CUDA Core是Single Precision的，也就是计算float单精度的。双精度Double Precision是那个黄色的模块。所以一个SM里边由32个DP Unit，由64个CUDA Core，所以单精度双精度单元数量比是2:1。LD/ST 是load store unit，用来内存操作的。SFU是Special function unit，用来做cuda的intrinsic function的，类似于__cos()这种。
![1](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Tesla%20GPU%20%E6%9E%B6%E6%9E%84/image/1.png)

## Fermi架构
### Fermi是第一个完整的GPU计算架构。
+ 512个accelerator cores即所谓CUDA cores（包含ALU和FPU）
+ 16个SM，每个SM包含32个CUDA  core
+六个384位 GDDR5 DRAM，支持6GB global on-board memory
+ GigaThread engine（图左侧）将thread blocks分配给SM调度
+ 768KB L2 cache
+每个SM有16个load/store单元，允许每个clock cycle为16个thread（即所谓half-warp，+不过现在不提这个东西了）计算源地址和目的地址
+ Special function units（SFU）用来执行sin cosine 等
+每个SM两个warp scheduler两个instruction dispatch unit，当一个block被分配到一个SM中后，所有该block中的thread会被分到不同的warp中。
+ Fermi（compute capability 2.x）每个SM同时可处理48个warp共计1536个thread。
![2](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Tesla%20GPU%20%E6%9E%B6%E6%9E%84/image/2.png) 
### 每个SM由以下几部分组成：
+执行单元（CUDA cores）
+调度分配warp的单元
+ shared memory，register file，L1 cache

## Kepler 架构
### Kepler架构是英伟达于2012年推出的新的GPU架构，其与Fermi架构的最大区别是：SM单元的结构有所变化。Kepler相较于Fermi更快，效率更高，性能更好。
+ 15个SM
+ 6个64位memory controller
+ 192个单精度CUDA cores，64个双精度单元，32个SFU，32个load/store单元（LD/ST）
增加register file到64K
+每个Kepler的SM包含四个warp scheduler、八个instruction dispatchers，使得每个SM可以同时issue和执行四个warp。
+ Kepler K20X（compute capability 3.5）每个SM可以同时调度64个warp共计2048个thread。
![3](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Tesla%20GPU%20%E6%9E%B6%E6%9E%84/image/3.png)  
### Kepler架构的新特性
#### 动态并行
Kepler架构允许GPU动态并行，也就是可以在一个内核中启动一个新的内核，也就是嵌套内核。此举可以减少GPU与CPU的通信，减小工作负载。
![4](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Tesla%20GPU%20%E6%9E%B6%E6%9E%84/image/4.png)  
#### Hyper-Q技术
Hyper-Q技术是Kepler架构开始拥有的新技术，它可以在主机与GPU之间提供32个硬件工作队列，以减少任务在队列中阻塞的可能性。这种技术可以保证在GPU上可以有更多的并发执行，更大程度上提升GPU的整体性能。
## Pascal
### Pascal 是 NVIDIA 引入 GPU 计算后的第五代 GPU 架构。在NVIDIA GTC2016 上首次向公众公布了基于 Pascal 的两款 GPU：Tesla P100 和架构名尚不清楚的中端版 Pascal。其中，Tesla P100 采用顶级大核心 GP100。
### 以GP04为例
![5](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Tesla%20GPU%20%E6%9E%B6%E6%9E%84/image/5.png)
+ 内置 4 个 GPC（图形处理簇），共计 20 个 SM（流多处理器），以及 8 个内存控制器。
+ 每个SM 包括 128 CUDA core，没有 DPUnit。每个 CUDA core 支持 dp2a（双路 16 bit 整数乘累加指令）、dp4a（四路 8 bit 整数乘累加指令）。
+ 每个SM 还内置 96 KB 共享内存、48 KB L1 缓存、256 KB 寄存器、8 个纹理单元。
### Pascal 架构五大技术突破
#### 16 纳米鳍型场效应晶体管 (FinFET) 显著提升能效
Pascal GPU 内含 1500 亿个由先进的 16 纳米 FinFET 制造工艺打造的晶体管，是当今市场上极其巨大的 FinFET 芯片。它的设计能带来极其快速的性能和优异的能效，可承受对计算的需求近乎无限的工作负载。
#### 巨大的性能飞跃
Pascal 是当今市场上极为强大的 GPU 计算架构，能让普通计算机变身为性能强劲的超级计算机，包括可为 HPC 工作负载提供超过 5 万亿次的双精度浮点运算能力。在深度学习方面，与当代 GPU 架构相比，搭载 Pascal 架构的系统使神经网络的训练速度提高了 12 倍多（将训练时间从数周缩短为数小时），并且将深度学习推理吞吐量提升了 7 倍。
#### NVIDIA NVLINK 让应用程序能灵活扩展
Pascal 是率先集成了革新性的 NVIDIA NVLink™ 高速双向互联的架构。此技术能跨越多个 GPU 扩展应用程序，其互连带宽加速性能比当今的一流解决方案高 5 倍。
#### 适用于大数据工作负载的采用 HBM2 的 CoWoS 技术
Pascal 架构将处理器与数据封装到一起，实现了很高的计算效率。采用 HBM2 的 CoWoS®（晶圆基底芯片）技术采用创新型内存设计方法，可提供高于 NVIDIA Maxwell™ 架构 3 倍的显存带宽性能。
#### 新型人工智能 (AI) 算法
新的 16 位半精度浮点指令可提供超过 21 万亿次浮点运算的强大训练性能。Pascal 架构具备 47 万亿次运算/秒 (TOPS) 的性能和新的 8 位整数指令，使得人工智能算法可为深度学习推理提供实时响应能力。

