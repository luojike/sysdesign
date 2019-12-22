Tesla GPU架构分析
=============
目录
======
- GPU简介  
- Pascal GPU  
- Kepler GPU  
- Turing GPU


GPU简介
-
GPU（图形处理器），是一种专门在个人电脑、工作站、游戏机和一些移动设备（如平板电脑、智能手机等）上做图像和图形相关运算工作的微处理器。它是显卡的“心脏”，与CPU类似，只不过GPU是专为执行复杂的数学和几何计算而设计的。GPU计算能力非常强悍，举个例子：现在主流的i7处理器的浮点计算能力是主流的英伟达GPU处理器浮点计算能力的1/12。从实际来看，CPU芯片空间的5%是ALU，而GPU空间的40%是ALU。这也是导致GPU计算能力超强的原因。    
随着一代一代的显卡性能的更新，从硬件设计上或者命名方式上有很多的变化与更新，其中比较常见的有以下一些内容。  
- gpu架构：Tesla、Fermi、Kepler、Maxwell、Pascal  
- 芯片型号：GT200、GK210、GM104、GF104等  
- 显卡系列：GeForce、Quadro、Tesla  
- GeForce显卡型号：G/GS、GT、GTS、GTX  
gpu架构指的是硬件的设计方式，例如流处理器簇中有多少个core、是否有L1 or L2缓存、是否有双精度计算单元等等。每一代的架构是一种思想，如何去更好完成并行的思想，而芯片就是对上述思想的实现，芯片型号GT200中第二个字母代表是哪一代架构，有时会有100和200代的芯片，它们基本设计思路是跟这一代的架构一致，只是在细节上做了一些改变，例如GK210比GK110的寄存器就多一倍。  
Tesla的k型号卡为了高性能科学计算而设计，比较突出的优点是双精度浮点运算能力高并且支持ECC内存，需要注意的是Tesla系列没有显示输出接口，它专注于数据计算而不是图形显示。  

Pascal GPU
-
Pascal是NVIDIA引入GPU计算后的第五代 GPU 架构。在NVIDIA GTC2016上首次向公众公布了基于Pascal的两款GPU：Tesla P100和架构名尚不清楚的中端版Pascal。其中，Tesla P100采用顶级大核心GP100。  
- GP100 GPU参数  
6个图形处理簇（GPC）：每个GPC包含10个SM，共60个SM，64个单精CUDA Cores/32个双精CUDA Cores，4个纹理单元，2个分块区，每个含有1个 Warp调度器，2个指令分发器   
30个纹理处理簇（TPC）：分布在2个SM内  
240纹理单元   
3840单精度CUDA Cores/1920双精度CUDA Cores  
8个512位内存控制器（共4096位）：每个内存控制器搭配512KB L2 Cache，共4096KB L2 Cache，每个HBM2 DRAM堆栈由一对内存控制器控制  
- GP100架构特性  
高性能低功耗：支持单精度、双精度、半精度，适合HPC和Deep Learning；支持 FMA；工艺16纳米FinFET300w；顶级大核心 P100：5.3 TFLOPS的双精度浮点 (FP64) 性能，10.6 TFLOPS 的单精度 (FP32) 性能，21.2 TFLOPS的半精度(FP16)性能     
HBM2高速 GPU 内存架构：HBM2内存是堆栈式内存并且与GPU处于同一个物理封装内，高带宽：720GB/s；高容量：16GB   
Pascal 流式多处理器：SM 核心数减少，核心利用率提高，每个SM的寄存器和warp数\线程数不变，每个SM的shared memory为64KB   
NVLink高速互联技：P100：每个GPU支持4个Nvlink链路，每个链路单向20GB/s，双向40GB/s  
简化编程：统一内存，CPU和GPU内存提供无缝统一的单一虚拟地址空间，编程和内存模型简单  
计算抢占：可防止长期运行的应用程序独占系统 (防止其它应用程序运行)，程序员无再需要修改其长期运行的应用程序即可使其很好地兼容其它GPU应用程序    

Kepler GPU
-
Kepler GK110由71亿个晶体管组成，速度最快，是有史以来架构最复杂的微处理器，GK110新加了许多注重计算性能的创新功能。GK110提供超过每秒1万亿次双精度浮点计算的吞吐量，性能效率明显高于之前的Fermi架构。除大大提高的性能之外，Kepler架构在电源效率方面有3次巨大的飞跃，使Fermi的性能/功率比提高了3倍。  
完整Kepler GK110架构包括15个SMX单元和六个64位内存控制器。不同的产品将使用GK110不同的配置。例如，某些产品可能部署13或14个SMX。   
Kepler GK110 的以下新功能提高GPU的利用率，简化了并行程序设计，并有助于GPU在各种计算环境中部署：   
- Dynamic Parallelism   
能够让GPU在无需CPU介入的情况下，通过专用加速硬件路径为自己创建新的线程，对结果同步，并控制这些线程的调度。   
- Hyper-Q   
Hyper-Q允许多个CPU核同时在单一GPU上启动线程，从而大大提高了GPU的利用率并削减了CPU空闲时间。Hyper‐Q增加了主机和Kepler GK110 GPU之间的连接总数（工作队列），允许32个并发、硬件管理的连接（与Fermi相比，Fermi只允许单个连接）。Hyper-Q是一种灵活的解决方案，允许来自多个CUDA流、多个消息传递接口（MPI）进程，甚至是进程内多个线程的单独连接。  
- Grid Management Unit   
使Dynamic Parallelism能够使用先进、灵活的GRID管理和调度控制系统。新GK110 Grid Management Unit(GMU)管理按优先顺序在GPU上执行的Grid。GMU可以暂停新GRID和等待队列的调度，并能中止GRID，直到其能够执行时为止，为Dynamic Parallelism的运行提供了灵活性。GMU确保CPU和GPU产生的工作负载得到妥善的管理和调度。    
- 英伟达GPUDirect
英伟达GPUDirect能够使单个计算机内的GPU或位于网络内不同服务器内的GPU直接交换数据，无需进入CPU系统内存。GPUDirect中的RDMA功能允许第三方设备，例如SSD、NIC、和IB适配器，直接访问相同系统内多个GPU上的内存，大大降低MPI从GPU内存发送/接收信息的延迟。还降低了系统内存带宽的要求并释放其他CUDA任务使用的GPU DMA引擎。Kepler GK110还支持其他的GPUDirect功能，包括Peer-to-Peer和GPUDirect for Video。   

Turing GPU
-
NVIDIA Tesla T4 GPU是首个基于Turing的GPU，是针对超大规模数据中心的新兴精尖推理解决方案，可为图像分类与标记、视频分析、自然语言处理、自动语音识别以及智能搜索等各类应用提供通用推理加速。Tesla T4的广泛推理能力使其能够应用于企业解决方案和终端设备。    
NVIDIA Tesla T4 GPU具有2560个CUDA核心和320个Tensor核心，可提供高达130TOPS（万亿次运算/秒）的INT8运算和多达260 TOPS的INT4推理性能。与基于CPU的推理相比，由全新Turing Tensor核心驱动的Tesla T4可提供高达近40倍的推理性能。    
Turing GPU架构不仅配备Turing Tensor核心，还具备有助提高数据中心应用性能的其他特性。其中一些主要特性包括：
- 增强版视频引擎：与之前的Pascal和Volta GPU架构相比，Turing能够支持更多的视频解码格式，如HEVC 4:4:4（8/10/12 位）和VP9（10/12 位）。相比基于Pascal的同等Tesla GPU，Turing的增强版视频引擎能够大幅提升并发视频流的解码数量。    
- Turing 多进程服务：Turing GPU架构继承了Volta架构中首次采用的增强版多进程服务(MPS) 特性。相比基于Pascal的Tesla GPU，Tesla T4所采用的MPS能够针对小批量改进推理性能，减少启动延迟，提高服务质量，并能为更多并发客户端请求提供支持服务。    
- 更高的显存带宽和更大的显存容量：凭借16 GB的GPU显存和320 GB/秒的显存带宽，Tesla T4能够提供几乎两倍于其前代Tesla P4 GPU的显存带宽和显存容量。凭借Tesla T4，超大规模数据中心可以将虚拟桌面基础架构(VDI)应用程序的用户密度提高一倍。    
- GDDR6显存子系统：GDDR6是高带宽GDDR DRAM内存设计的又一次重大飞跃。凭借众多高速SerDes和RF技术带来的改进，Turing GPU中的GDDR6存储器接口电路已实现全面重新设计，在速度、能效和降噪方面均得到了提升。这一新型接口设计采用多个新电路并能提升信号训练效果，从而大幅降低由工艺、温度和电源电压引起的噪声和波动。       
- L2缓存和ROP：除配备新的GDDR6显存子系统以外，Turing GPU还已添加更大容量且更快速的L2  缓存。TU102 GPU附带6 MB L2缓存，相比TITAN Xp中使用的上一代GP102 GPU所提供的3 MB L2 缓存，其已高出一倍。TU102还可提供远高于GP102的L2缓存带宽。与上一代NVIDIA GPU类似，Turing中的每个ROP分区均包含8个ROP单元，且每个单元能够处理一个单色样本。一个完整的TU102芯片包含12个ROP分区，共计96个ROP单元。     
- Turing显存压缩：NVIDIA GPU使用几种无损显存压缩技术，旨在将数据写入帧缓存时降低显存带宽需求。GPU的压缩引擎采用各类不同算法，能够根据数据特点确定最有效的压缩方式。这有助减少写入显存及从显存传输至L2缓存的数据量，并能降低客户端（如纹理单元）和帧缓存之间传输的数据量。Turing已对Pascal的精尖显存压缩算法作出深入改进，不仅能增加GDDR6的原始数据传输速率，还可进一步提高有效带宽。
- 视频和显示引擎：Turing GPU具有专为新一波显示器设计的全新显示引擎，可支持更高分辨率、更快刷新率以及HDR。Turing支持DisplayPort 1.4a，可在60Hz刷新率下实现8K分辨率，此外还已加入VESA的显示串流压缩(DSC)1.2技术，能够提供视觉无损的更高压缩。
