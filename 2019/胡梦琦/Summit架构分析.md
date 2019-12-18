# Summit架构分析
* * * 
## 目录
* 背景
* 概述
* 异构系统
* 计算节点
* CPU之间的通讯
* 总结

## 背景
Summit超级计算机是IBM计划研发的一款超级计算机，其计算性能超过中国TaihuLight超级计算机。  

**排名记录**

	 	2018年11月12日，新一期全球超级计算机500强榜单在美国达拉斯发布，美国超级计算机“顶点”蝉联冠军。
		2019年11月18日，全球超级计算机500强榜单发布，美国超级计算机“顶点”以每秒14.86亿亿次的浮点运算速度再次登顶。  

## 概述
Summit 一共有 4608 个运算节点，每节点是一台主机，节点内使用 CPU+GPU 异构运算体系，由两颗 POWER9 CPU 以及六块 Tesla V100 运算加速卡组成，CPU 与 GPU 之间的连接采用的是英伟达公司开发的 NVLink 总线，每个节点的 CPU 和 GPU 共用 512GiB 的一致性存储器，CPU 和 GPU 可相互直接访问这个存储器空间以共用数据，另外还配备了容量高达 800GB的非易失性随机存取存储器作为突发性缓存或扩展存储器容量之用。  

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.9.jpg)

Summit 使用液冷系统，每分钟流量高达 4000 加仑，4608 台主机连同液冷系统的整机组全速运行时的功率就高达一千五百万瓦。仅 GPGPU 部分的双精度浮点数的运算性能就高达 215 Pflops；Tesla V100 内置有用于深度学习运算的 Tensor Core，因此每颗 GPGPU 也能提供约 125 Tflops 的混合精度浮点数性能，而全机组的更高达 3.3 Eflops。  

Summit 擅长人工智能、机器学习和深度学习方面的运算，将其运用于动物健康、物理、气候模式等运算，获得的运算结果也比运行同样项目的泰坦更细致。未来还会加入天体分析、超导体、新型材料等方面的研究。  

## 异构系统
### 异构体系
从硬件架构方面来看，Summit依旧采用的是CPU+GPU异构体系，每个节点性能42TFLOPS，由2个Power 9 22核处理器及6个Telsa V100加速卡组成，搭配512GB DDR4内存及96GB HBM 2显存，每个节点搭配1.6TB非易失性内存，这样一来总的内存容量超过10PB，存储系统容量高达250PB，带宽2.5TB/s。
从架构角度来看，Summit并没有在超算的底层技术上予以彻底革新，而是通过不断使用先进制程、扩大计算规模来获得更高的性能。

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.1.jpg)

▲SXM2接口的Tesla V100。  

虽然扩大规模是提高超算效能的有效方式，但是为了将这样多的CPU、GPU和相关存储设备有效组合也是一件困难的事情。在这一点上，Summit采用了多级结构。最基本的结构被称为计算节点，众多的计算节点组成了计算机架，多个计算机架再组成Summit超算本身。
### 机架和系统

机架是由计算节点组成的并行计算单元，Summit的每个机架中安置了18个计算节点和Mellanox IB EDR交换器。每个节点都配备了双通道的Mellanox InfiniBand ConnectX5网卡，支持双向100Gbps带宽。节点的网卡直接通过插槽连接至CPU，带宽为12.5GBx2—实际上每个节点的网络都是由2颗CPU分出的PCIe 4.0 x8通道合并而成，PCI-E 4.0 x8的带宽为16GB/s，合并后的网卡可以为每颗CPU提供12.5GB/s的网络直连带宽，这样做可以最大限度地降低瓶颈。

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.8.jpg)

▲国外WikiChip机构制作的Summit的系统结构布局图。

由于一个机架有18个计算节点，因此总计有9TB的DDR4内存和另外1.7TB的HBM2内存，总计内存容量高达10.7TB。一个机架的最大功率为59kW，峰值计算能力包括CPU的话是846TFlops，只计算GPU的话是775TFlops。

在机架之后就是整个Summit系统了。完整的Summit系统拥有256个机架，18个交换机架，40个存储机架和4个基础架构机架。完整的Summit系统拥有2.53PB的DDR4内存、475TB的HBM2内存和7.37PB的NVMe SSD存储空间。


## 计算节点
### 2CPU+6GPU  
Summit采用的计算节点型号为Power System AC922，之前的研发代号为Witherspoon，后文我们将其简称为AC922，这是一种19英寸的2U机架式外壳。从内部布置来看，每个AC922内部有2个CPU插座，满足两颗Power 9处理器的需求。每颗处理器配备了3个GPU插槽，每个插槽使用一块GV100核心的计算卡。这样2颗处理器就可以搭配6颗GPU。  

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.2.jpg)

▲Summit的一个计算节点，以及其内部设备。

内存方面，每颗处理器设计了8通道内存，每个内存插槽可以使用32GB DDR4 2666内存，这样总计可以给每个CPU可以带来256GB、107.7GB/s的内存容量和带宽。GPU方面，它没有使用了传统的PCIe插槽，而是采用了SXM2外形设计，每颗GPU配备16GB的HBM2内存，对每个CPU-GPU组而言，总计有48GB的HBM2显存和2.7TBps的带宽。

#### NVLink 2.0

继续进一步深入AC922的话，其主要的技术难题在于CPU和GPU之间的连接。传统的英特尔体系中，CPU和GPU之间的连接采用的是PCIe总线，带宽稍显不足。但是在Summit上，由于IBM Power 9处理器的加入，因此可以使用更强大的NVLink来取代PCIe总线。本刊在之前的文章中也曾深入分析过NVLink的相关技术，在这里就不再赘述。

单颗Power 9处理器有3组共6个NVLink通道，每组2个通道。由于Power 9处理器的NVLink版本是2.0，因此其单通道速度已经提升至25GT/s，2个通道可以在CPU和GPU之间实现双向100GB/s的带宽，此外，Power 9还额外提供了48个PCIe 4.0通道。

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.4.jpg)

▲国外WikiChip机构制作的Summit内部NVLink 2.0连接示意图。  
和CPU类似，GV100 GPU也有6个NVLink 2.0通道，同样也分为3组，其中一组连接CPU，另外2组连接其他两颗GPU。和CPU-GPU之间的链接一样，GPU与GPU之间的连接带宽也是100GB/s。
### 完整的节点性能情况

Summit的一个完整节点拥有2颗22核心的Power 9处理器，总计44颗物理核心。每颗Power 9处理器的物理核心支持同时执行2个矢量单精度运算。换句话说，每颗核心可以在每个周期执行16次单精度浮点运算。在3.07GHz时，每颗CPU核心的峰值性能可达49.12GFlops。一个节点的CPU双精度峰值性能略低于1.1TFlops，GPU的峰值性能大约是47TFlops。

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.6.jpg)

请注意，这里的数值和最终公开的数据存在一些差异，其主要原因是公开数据的性能只包含GPU部分，这也是大多数浮点密集型应用可以实现的最高性能。当然，如果包含CPU的话，Summit本身的峰值性能将超越220PFlops。

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.7.jpg)

除了CPU和GPU外，每个节点都配备了1.6TB的NVMe SSD和一个Mellanox Infiniband EDR网络接口。


## CPU之间的通讯

### X总线

除了CPU和GPU、GPU之间的通讯外，由于每个AC922上拥有2个CPU插槽，因此CPU之间的通讯也很重要。Summit的每个节点上，CPU之间的通讯依靠的是IBM自家的X总线。X总线是一个4byte的16GT/s链路，可以提供64GB/s的双向带宽，能够基本满足两颗处理器之间通讯的需求。

![alt 图标](https://github.com/MQ-Hu/hello-world/blob/master/images/4.5.jpg)

▲国外WikiChip机构制作的Summit内部CPU间通讯结构示意图。

另外在CPU的对外通讯方面，每一个节点拥有4组向外的PCIe 4.0通道，包括两组x16（支持CAPI），一组x8（支持CAPI）和一组x4。其中2组x16通道分别来自于两颗CPU，x8通道可以从一颗CPU中配置，另一颗CPU可以配置x4通道。其他剩余的PCIe 4.0通道就用于各种I/O接口，包括PEX、USB、BMC和1Gbps网络等。

## 总结
Summit通过强大的CPU和GPU以及网络、系统等部分先进的技术综合和结构设计，成功登顶了全球第一超算的宝座，并且这可能不是Summit的终点，Summit仅仅是美国能源部在探索百亿亿次超算道路上的一个中间站而已。  
目前的消息显示，橡树岭国家实验室正在准备一款名为Frontier的百亿亿次超算，其性能应该可以达到Summit的5~10倍。目前尚不清楚新的超算是在Summit上升级而来还是全部重新建立，但是无论如何，百亿亿次级别超算正在朝我们一步步走来，时间节点在2021年左右。
