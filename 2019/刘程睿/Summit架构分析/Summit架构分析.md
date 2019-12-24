# Summit架构分析
Summit超级计算机是IBM计划研发的一款超级计算机。在2018年的6月，美国能源部在橡树岭国家实验室正式宣布了全新的超级计算机——Summit。
## Summit架构解析
![架构](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Summit%E6%9E%B6%E6%9E%84%E5%88%86%E6%9E%90/image/%E6%9E%B6%E6%9E%84.png)
### 硬件架构
![硬件架构](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Summit%E6%9E%B6%E6%9E%84%E5%88%86%E6%9E%90/image/%E7%A1%AC%E4%BB%B6%E6%9E%B6%E6%9E%84.png)

从硬件架构方面来看，Summit依旧采用的是异构方式，其主CPU来自于IBM Power 9，22核心，主频为3.07GHz，总计使用了103752颗，核心数量达到2282544个。GPU方面搭配了27648块英伟达Tesla V100计算卡，总内存为2736TB，操作系统为RHEL 7.4。从架构角度来看，Summit并没有在超算的底层技术上予以彻底革新，而是通过不断使用先进制程、扩大计算规模来获得更高的性能。
虽然扩大规模是提高超算效能的有效方式，但是为了将这样多的CPU、GPU和相关存储设备有效组合也是一件困难的事情。在这一点上，Summit采用了多级结构。最基本的结构被称为计算节点，众多的计算节点组成了计算机架，多个计算机架再组成Summit超算本身。
### 计算节点
Summit采用的计算节点型号为Power System AC922，之前的研发代号为Witherspoon，后文我们将其简称为AC922，这是一种19英寸的2U机架式外壳。从内部布置来看，每个AC922内部有2个CPU插座，满足两颗Power 9处理器的需求。每颗处理器配备了3个GPU插槽，每个插槽使用一块GV100核心的计算卡。这样2颗处理器就可以搭配6颗GPU。
![node](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Summit%E6%9E%B6%E6%9E%84%E5%88%86%E6%9E%90/image/node.png)
### 内存
内存方面，每颗处理器设计了8通道内存，每个内存插槽可以使用32GB DDR4 2666内存，这样总计可以给每个CPU可以带来256GB、107.7GB/s的内存容量和带宽。GPU方面，它没有使用了传统的PCIe插槽，而是采用了SXM2外形设计，每颗GPU配备16GB的HBM2内存，对每个CPU-GPU组而言，总计有48GB的HBM2显存和2.7TBps的带宽。
![all memory](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Summit%E6%9E%B6%E6%9E%84%E5%88%86%E6%9E%90/image/Overall%20System%20Characteristics.png)
### NVLink 2.0
传统的英特尔体系中，CPU和GPU之间的连接采用的是PCIe总线，带宽稍显不足。但是在Summit上，由于IBM Power 9处理器的加入，因此可以使用更强大的NVLink来取代PCIe总线。单颗Power 9处理器有3组共6个NVLink通道，每组2个通道。由于Power 9处理器的NVLink版本是2.0，因此其单通道速度已经提升至25GT/s，2个通道可以在CPU和GPU之间实现双向100GB/s的带宽，此外，Power 9还额外提供了48个PCIe 4.0通道。
### X总线
由于每个AC922上拥有2个CPU插槽，因此CPU之间的通讯也很重要。Summit的每个节点上，CPU之间的通讯依靠的是IBM自家的X总线。X总线是一个4byte的16GT/s链路，可以提供64GB/s的双向带宽，能够基本满足两颗处理器之间通讯的需求。
另外在CPU的对外通讯方面，每一个节点拥有4组向外的PCIe 4.0通道，包括两组x16（支持CAPI），一组x8（支持CAPI）和一组x4。其中2组x16通道分别来自于两颗CPU，x8通道可以从一颗CPU中配置，另一颗CPU可以配置x4通道。其他剩余的PCIe 4.0通道就用于各种I/O接口，包括PEX、USB、BMC和1Gbps网络等。
### 机架和系统
机架是由计算节点组成的并行计算单元，Summit的每个机架中安置了18个计算节点和Mellanox IB EDR交换器。每个节点都配备了双通道的Mellanox InfiniBand ConnectX5网卡，支持双向100Gbps带宽。节点的网卡直接通过插槽连接至CPU，带宽为12.5GBx2—实际上每个节点的网络都是由2颗CPU分出的PCIe 4.0 x8通道合并而成，PCI-E 4.0 x8的带宽为16GB/s，合并后的网卡可以为每颗CPU提供12.5GB/s的网络直连带宽，这样做可以最大限度地降低瓶颈。
一个机架有18个计算节点，因此总计有9TB的DDR4内存和另外1.7TB的HBM2内存，总计内存容量高达10.7TB。一个机架的最大功率为59kW，峰值计算能力包括CPU的话是846TFlops，只计算GPU的话是775TFlops。
![外观](https://github.com/luojike/sysdesign/blob/master/2019/%E5%88%98%E7%A8%8B%E7%9D%BF/Summit%E6%9E%B6%E6%9E%84%E5%88%86%E6%9E%90/image/%E5%A4%96%E8%A7%82.png)

一个开放的机架有18个计算节点，开关在中部和顶部。在机架之后就是整个Summit系统了。完整的Summit系统拥有256个机架，18个交换机架，40个存储机架和4个基础架构机架。完整的Summit系统拥有2.53PB的DDR4内存、475TB的HBM2内存和7.37PB的NVMe SSD存储空间。
目前业内报告的Summit系统性能依旧偏向保守，当然，最好性能并不是最有意义的，实际的负载性能最为重要。橡树岭国家实验室在初步测试Summit针对基因组数据的性能时，达到了1.88 exaops的混合精度性能，这个测试主要是用的是GV100的张量核心矩阵乘法，这也是迄今为止报告的最高性能。
