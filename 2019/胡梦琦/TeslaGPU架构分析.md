# TeslaGPU架构分析
***
## **目录**
+ GPU架构
+ Fermi架构
+ Kepler架构
+ Volta架构  

---
  
## GPU架构

图形处理单元GPU英文全称Graphic Processing Unit，GPU是相对于CPU的一个概念，NVIDIA公司在1999年发布GeForce256图形处理芯片时首先提出GPU的概念。GPU使显卡减少了对CPU的依赖，并进行部分原本CPU的工作(主要是并行计算部分)。GPU具有强大的浮点数编程和计算能力，在计算吞吐量和内存带宽上，现代的GPU远远超过CPU。  
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.1.png)  
SM（Streaming Multiprocessors）是GPU架构中非常重要的部分，GPU硬件的并行性就是由SM决定的。  
以Fermi架构为例，其包含以下主要组成部分：  

* 	CUDA cores  
* 	Shared Memory/L1Cache  
* 	Register File  
* 	Load/Store Units  
* 	Special Function Units  
* 	Warp Scheduler  

GPU中每个SM都设计成支持数以百计的线程并行执行，并且每个GPU都包含了很多的SM，所以GPU支持成百上千的线程并行执行，当一个kernel启动后，thread会被分配到这些SM中执行。大量的thread可能会被分配到不同的SM，但是同一个block中的thread必然在同一个SM中并行执行。  
CUDA采用Single Instruction Multiple Thread（SIMT）的架构来管理和执行thread，这些thread以32个为单位组成一个单元，称作warps。warp中所有线程并行的执行相同的指令。每个thread拥有它自己的instruction address counter和状态寄存器，并且用该线程自己的数据执行指令。  
SIMT和SIMD（Single Instruction, Multiple Data）类似，SIMT应该算是SIMD的升级版，更灵活，但效率略低，SIMT是NVIDIA提出的GPU新概念。二者都通过将同样的指令广播给多个执行官单元来实现并行。一个主要的不同就是，SIMD要求所有的vector element在一个统一的同步组里同步的执行，而SIMT允许线程们在一个warp中独立的执行。SIMT有三个SIMD没有的主要特征：
  
1. 每个thread拥有自己的instruction address counter
2. 每个thread拥有自己的状态寄存器
3. 每个thread可以有自己独立的执行路径

一个block只会由一个SM调度，block一旦被分配好SM，该block就会一直驻留在该SM中，直到执行结束。一个SM可以同时拥有多个block。下图显示了软件硬件方面的术语：  
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.2.jpg)  
需要注意的是，大部分thread只是逻辑上并行，并不是所有的thread可以在物理上同时执行。这就导致，同一个block中的线程可能会有不同步调。  
并行thread之间的共享数据回导致竞态：多个线程请求同一个数据会导致未定义行为。CUDA提供了API来同步同一个block的thread以保证在进行下一步处理之前，所有thread都到达某个时间点。不过，我们是没有什么原子操作来保证block之间的同步的。  
同一个warp中的thread可以以任意顺序执行，active warps被SM资源限制。当一个warp空闲时，SM就可以调度驻留在该SM中另一个可用warp。在并发的warp之间切换是没什么消耗的，因为硬件资源早就被分配到所有thread和block，所以该新调度的warp的状态已经存储在SM中了。  
SM可以看做GPU的心脏，寄存器和共享内存是SM的稀缺资源。CUDA将这些资源分配给所有驻留在SM中的thread。因此，这些有限的资源就使每个SM中active warps有非常严格的限制，也就限制了并行能力。  
## Fermi架构
Fermi是第一个完整的GPU计算架构。
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.3.jpg) 

* 512个accelerator cores即所谓CUDA cores（包含ALU和FPU）
* 16个SM，每个SM包含32个CUDA  core
* 六个384位 GDDR5 DRAM，支持6GB global on-board memory
* GigaThread engine（图左侧）将thread blocks分配给SM调度
* 768KB L2 cache
* 每个SM有16个load/store单元，允许每个clock cycle为16个thread（即所谓half-warp，不过现在不提这个东西了）计算源地址和目的地址
* Special function units（SFU）用来执行sin cosine 等
* 每个SM两个warp scheduler两个instruction dispatch unit，当一个block被分配到一个SM中后，所有该block中的thread会被分到不同的warp中。
* Fermi（compute capability 2.x）每个SM同时可处理48个warp共计1536个thread。

每个SM由一下几部分组成：

* 执行单元（CUDA cores）
* 调度分配warp的单元
* shared memory，register file，L1 cache


## Kepler架构
#### Kepler架构概述

	Kepler GK110由71亿个晶体管组成，速度最快，是有史以来架构最复杂的微处理器，GK110新加了许多注
	重计算性能的创新功能。GK110提供超过每秒1万亿次双精度浮点计算的吞吐量，性能效率明显高于之前的
	Fermi架构。除大大提高的性能之外，Kepler架构在电源效率方面有3次巨大的飞跃，使Fermi的性能/功率
	比提高了3倍。
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.4.jpg) 

* 15个SM
* 6个64位memory controller
* 192个单精度CUDA cores，64个双精度单元，32个SFU，32个load/store单元（LD/ST）
* 增加register file到64K
* 每个Kepler的SM包含四个warp scheduler、八个instruction dispatchers，使得每个SM可以同时issue和执行四个warp。
* Kepler K20X（compute capability 3.5）每个SM可以同时调度64个warp共计2048个thread。

 
##### Dynamic Parallelism--动态并行化  
Dynamic Parallelism是Kepler的新特性，能够让 GPU 在无需 CPU 介入的情况下，通过专用加速硬件路径为自己创建新的线程，对结果同步，并控制这些线程的调度。有了这个特性，任何kernel内都可以启动其它的kernel了。这样直接实现了kernel的递归以及解决了kernel之间数据的依赖问题。  
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.6.jpg)

##### Hyper-Q
Hyper-Q是Kepler的另一个新特性，增加了CPU和GPU之间硬件上的联系，使CPU可以在GPU上同时运行更多的任务。这样就可以增加GPU的利用率减少CPU的闲置时间。Fermi依赖一个单独的硬件上的工作队列来从CPU传递任务给GPU，这样在某个任务阻塞时，会导致之后的任务无法得到处理，Hyper-Q解决了这个问题。相应的，Kepler为GPU和CPU提供了32个工作队列。  
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.7.png)

## Volta架构

* 6个GPCs
* 84个Volta SM
* 42个TPC（每个包括2个SM）
* 8个512位内存控制器（总共4096位）
* 每个SM 有64个 FP32核、64个INT32核、32个FP64核和8个新张量核。
* 每个SM也包括四个纹理单元。 
* 一个完整的GV100 GPU共有5376个FP32核、5376个INT32核，2688个FP64核、672个张量核和336个纹理单元。
* 每个内存控制器连接到768 KB的L2高速缓存，每个HBM2DRAM堆栈由一对内存控制器控制。
* 完整的GV100 GPU共6144KB L2高速缓存。  
![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.8.png)

##### Volta SM（流多线程处理器）  
Volta SM的架构是设计来提供更高的性能的，它的设计比过去的SM设计降低了指令和高速缓存的延迟，并且包括了新的功能来加速沈度学习的应用。
主要特征包括：

* 专为深度学习矩阵算法建造的新混合精度FP16 / FP32张量核
* 增强的L1数据缓存，达到更高的性能和更低的延迟
* 简单的解码和减少指令延迟的精简指令集
* 更高的频率和更高的功率效率。

类似于Pascal GP100，GV100 每个SM包含64个FP32核和32个FP64核。然而，GV100 SM采用一种新的划分方法，提高SM的利用率和整体性能。GP100 SM被划分成两个处理模块，每个有32个 FP32核，16个FP64核，一个指令缓冲器，一个warp调度，两个派发单元，和一个128 kb的登记文件。GV100 SM被划分成四个处理块，每组16个 FP32核、8个FP6416核，16个Int32核，2个为深度学习矩阵运算设计的新的混合精度张量核，新的10指令缓存，一个warp调度，一个派发单元，以及一个64 kb的登记文件。请注意，新的L0指令缓存，现在使用在每个分区内，来提供比以前的NVIDIA GPU的指令缓冲器更高的效率。  
尽管GV100 SM与Pascal GP100 SM具有相同数量的寄存器，整个GV100 GPU拥有更多的SM，从而整体上有更多的寄存器。总的来说，GV100支持多线程，变形，和与之前的GPU相比，具有了线程块。  
在整个GV100 GPU上，由于SM数增加，以及每个SM的共享内存的潜力增加到96KB，相比GP100的64 KB，全局共享内存也有所增加。  
Pascal GPU无法同时执行FP32和Int32指令，与它不同的Volta GV100 SM包括单独的FP32和INT32核，允许在全吞吐量上同时执行FP32和INT32的操作，但同时也增加了指令问题的吞吐量。相关的指令问题延迟也通过核心FMA的数学操作得到减少，Volta只需要四个时钟周期，而Pascal需要六个。  

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/2.9.png)  
##### 张量核  
Tesla P100相比前代 NVIDIA Maxwell、Kepler架构能够提供相当高训练神经网络的性能，但神经网络的复杂性和规模却持续增长。有数千层和数百万神经元的新网络甚至需要更高的性能和更快的训练时间。  
新的张量核是VoltaGV100架构的最重要的特征，来帮助提升训练大型神经网络的性能。Tesla V100的张量核提供高达120 Tensor TFLOPS 的训练和推理应用。
矩阵乘积（BLAS GEMM）操作是神经网络训练和推断的核心，通过它来进行网络连接层输入数据和权重的矩阵相乘。图6为 Tesla V100 GPU 的张量核显著提升了这些操作的性能，与Pascal型的GP100 GPU相比提升了9倍。
##### 增强的L1数据高速缓存和共享内存 
合并了新L1数据高速缓存和共享内存的VoltaSM子系统显著提高了性能，同时也简化了编程，以及减少了需要达到或接近峰值的应用性能的调试时间。
##### 独立线程调度
Volta的架构比之前的GPU编程要容易得多，使得用户能够在更加复杂和多样化的应用上有效的工作。Volta GV100 是第一个支持独立的线程调度的GPU，使一个程序内的并行线程之间的晶粒同步与合作成为可能。Volta的一个主要设计目标是减少需要程序在GPU上运行的功耗，使线程合作具有更大的灵活性，能够提高细粒度并行算法的效率。
