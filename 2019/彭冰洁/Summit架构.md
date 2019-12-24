Summit架构   
==

目录  
==  
- Summit简介    
- 工作原理
- HPCG   
- 硬件架构    
- 节点性能情况   
- 机架和系统   

Summit简介   
----
Summit超级计算机是IBM计划研发的一款超级计算机，其计算性能将超过中国TaihuLight超级计算机。预计将在2018年初提供给美国能源部橡树岭国家实验室，计算性能比原定指标提升四分之一以上。          
013年6月起，中国超算长期蝉联第一，美国的超级计算机再未问鼎全球超算top500榜单。而Summit的问世让这一宝座终易主。1988年，ORNL的科学家们完成了首次G浮点(gigaflops)运算，1998年完成了首次T浮点(teraflops)运算，2008年完成了首次P浮点(petaflops)运算，2018年又完成了首次exaops计算。         
超级计算机Summit的发布让美国向“2021年交付E级超算”的目标又迈进了一步。             
它将在能源研究、科学发现、经济竞争力和国家安全等方面带来深远影响，助力科学家们在未来应对更多新的挑战，促进科学发现和激发科技创新中国计划于2020年推出首台E级超算;美国能源部启动了“百亿亿次计算项目(Exascale Computing Project)”，希望于2021年至少交付一台E级超算，其中一台的名字为“极光(Aurora)”，初步规划峰值运算能力超过每秒130亿亿次，内存超过8PB，系统功耗约为40MW。            
欧盟预计于2022年—2023年交付首台E级超算，使用的是美国、欧盟处理器，架构有可能类似ARM;日本发展E级超算的“旗舰2020计划”由日本理化所主导，完成时间也设定在2020年。         

工作原理   
----
这台让美国重夺世界第一的Summit超算系统由4608台计算服务器组成，每个服务器包含两个22核Power9处理器（IBM生产）
和6个Tesla V100图形处理单元加速器（NVIDIA生产）。Summit还拥有超过10PB的存储器，配以快速、高带宽的路径以实现有效的数据传输。     
凭借每秒高达20亿亿次(200PFlops)的浮点运算速度峰值，Summit的威力将是ORNL之前排名第一的系统Titan的8倍，相当于普通笔记本电脑运算速度的100万倍，
比之前位于榜首的中国超级计算机“神威⋅太湖之光”峰值性能（每秒12.5亿亿次）快约60%。      
![各国计算机性能](https://m.qpic.cn/psc?/V10d7b8e2YPTcE/T7ZeoLlLvDuhDKIHjjjMLcUSaAaNO6vuoPu3j2kSiTkV5fFQEGqhEGnrjL6yvpdaFJHKEIyO1kkurZqMSEOLWQDGl16hP51uHcrlNulK5hs!/b&bo=WAKvAQAAAAARB8Q!&rf=viewer_4)       
超级计算机运算速度对比   
![超级计算机运算速度对比](http://m.qpic.cn/psc?/V10d7b8e2YPTcE/T7ZeoLlLvDuhDKIHjjjMLV1yJaGn2STrLp9H*MG6alHi7r9.Jy4LUX9cotGxwbBs8*Y8EqluobnJJrB4QrkEsQ.jIpPCBWvMoTYdWS73Nkk!/b&bo=HAKVAQAAAAARF6o!&rf=viewer_4)   
根据超算Top500排行的数据，Summit超级计算机的峰值浮点性能为187.7PFlops，Linpack浮点性能为122.3PFlops，功耗为8805.5kW。相比之下，我国的神威太湖之光的峰值浮点性能为125.4PFlops，Linpack浮点性能为93.0PFlops，功耗为15371kW，HPCG性能为2925.75TFlops/s。    

HPCG   
---
TOP500所使用的Linpack Benchmark是一个比较老的测试规范，它的最后一个版本发布于2008年，版本号是HPL2.0。在测试中，Linpack更关注线性方程计算，所谓线性方程，是指未知数都是一次的方程，类似于ax+by+cz+……+d=0这样的类型。这种方程的本质在于方程两边乘以任何非零的数，整个方程的根是不受影响的，在笛卡尔坐标系中，线性方程以一条直线的方式呈现，这也是其名称的由来。        
比较新一些的规范是HPCG，也就是The High Performance Conjugate Gradients高度共轭梯度基准测试，其最新的相关论文在2015年11月发布。相比Linpack侧重于线性方程而言，HPCG的测试中包含的内容更多，包括稀疏矩阵向量乘法、SymGS（Symmetric Gauss-Seidel smoother，对称高斯-赛德尔平滑算法，用于稀疏三角形求解）、全球点计算（用于大型分布式计算测试）、矢量计算、多重网格预条件子计算等。HPCG多重、复杂的算法为超级计算机带来了更大的挑战。   
实际上，之所以在Linpack之后还推出HPCG排行榜，是因为业内专家（包括TOP500的创始人之一田纳西大学的教授Jack Dongarra，同时也是HPCG测试算法的论文作者）认为Linpack测试在部分领域可能难以准确地衡量超算的性能。比如线性方程计算的测试数据很难用于衡量大量微分方程计算所需的性能，因此HPCG的出现恰好填补了这个空缺。不过虽然HPCG比较新，但是这并不意味着Linkpack短期内会被取代。根据TOP500和HPCG的说明，虽然HPCG可以代表一大类应用程序的性能需求，甚至可以被认为是许多应用程序实现的性能基础，但也只是一部分而已，另一部分应用程序使用Linpark衡量依旧是有意义的，因此HPCG和HPL（Linpack）可以在一起衡量整个超算系统的性能。但是专业人士也指出，HPCG性能和HPL性能的差距越小，证明超算系统在不同算法的平衡性上就越出色，这也是体现各自系统架构实力的一个重要因素。在这个比较中，国产的神威太湖之光存在一定差距，其HPGC/HPL只有0.5%左右，相比Summit的2.4%差距非常大，应该是架构设计上存在一些差异。    

硬件架构  
----
从硬件架构方面来看，Summit依旧采用的是异构方式，其主CPU来自于IBM Power 9，22核心，主频为 3.07GHz，总计使用了103752颗，核心数量达到2282544个。GPU方面搭配了27648块英伟达Tesla V100计算卡，总内存为2736TB，操作系统为RHEL 7.4。         
从架构角度来看，Summit并没有在超算的底层技术上予以彻底革新，而是通过不断使用先进制程、扩大计算规模来获得更高的性能。虽然扩大规模是提高超算效能的有效方式，但是为了将这样多的 CPU、GPU和相关存储设备有效组合也是一件困难的事情。在这一点上，Summit采用了多级结构。最基本的结构被称为计算节点，众多的计算节点组成了计算机架，多个计算机架再组成Summit超算本身。      
2CPU+6GPU：Summit采用的计算节点型号为Power System AC922，之前的研发代号为Witherspoon，后文我们将其简称为AC922，这是一种19英寸的2U机架式外壳。从内部布置来看，每个AC922内部有2个CPU插座，满足两颗Power 9处理器的需求。每颗处理器配备了3个GPU插槽，每个插槽使用一块GV100核心的计算卡。这样2颗处理器 就可以搭配6颗GPU。内存方面，每颗处理器设计了8通道内存，每个内存插槽可以使用32GB DDR4 2666内存，这样总计可以给每个CPU可以带来256GB、107.7GB/s的内存容量和带宽。GPU方面，它没有使用了传统的PCIe插槽，而是采用了SXM2外形设计，每颗GPU配备16GB的HBM2内存，对每个CPU-GPU组而言，总计有48GB的HBM2显存和2.7TBps的带宽。        
![ ](http://04.imgmini.eastday.com/mobile/20180809/20180809214415_5ab8053d0f319d774a18ba8a6f1c2fae_5.jpeg)       
传统的英特尔体系中，CPU和GPU之间的连接采用的是PCIe总线，带宽稍显不足。但是在Summit上，由于IBM Power 9处理器的加入，因此可以使用更强大的NVLink来取代PCIe总线。   
单颗Power 9处理器有3组共6个NVLink通道，每组2个通道。由于Power 9处理器的NVLink版本是2.0，因此其单通道速度已经提升至25GT/s，2个通道可以在CPU和GPU之间实现双向100GB/s的带宽，此外，Power 9还额外提供了48个PCIe 4.0通道。和CPU类似，GV100 GPU也有6个NVLink 2.0通道，同样也分为3组，其中一组连接CPU，另外2组连接其他两颗GPU。和CPU-GPU之间的链接一样，GPU与GPU之间的连接带宽也是100GB/s。

节点性能情况   
---
Summit的一个完整节点拥有2颗22核心的Power 9处理器，总计44颗物理核心。每颗Power 9处理器的物理核心支持同时执行2个矢量单精度运算。换句话说，每颗核心可以在每个周期执行16次单精度浮点运算。在3.07GHz时，每颗CPU核心的峰值性能可达49.12GFlops。一个节点的CPU双精度峰值性能略低于1.1TFlops，GPU的峰值性能大约是47TFlops。请注意，这里的数值和最终公开的数据存在一些差异，其主要原因是公开数据的性能只包含GPU部分，这也是大多数浮点密集型应用可以实现的最高性能。当然，如果包含CPU的话，Summit本身的峰值性能将超越220PFlops。            
除了CPU和GPU外，每个节点都配备了1.6TB的NVMe SSD和一个Mellanox Infiniband EDR网络接口。      
![](http://04.imgmini.eastday.com/mobile/20180809/20180809214415_5ab8053d0f319d774a18ba8a6f1c2fae_9.jpeg)     

机架和系统      
---
机架是由计算节点组成的并行计算单元，Summit的每个机架中安置了18个计算节点和Mellanox IB EDR交换器。每个节点都配备了双通道的Mellanox InfiniBand ConnectX5网卡，支持双向100Gbps带宽。节点的网卡直接通过插槽连接至CPU，带宽为12.5GBx2—实际上每个节点的网络都是由2颗CPU分出的PCIe 4.0 x8通道合并而成，PCI-E 4.0 x8的带宽为16GB/s，合并后的网卡可以为每颗CPU提供12.5GB/s的网络直连带宽，这样做可以最大限度地降低瓶颈。    
由于一个机架有18个计算节点，因此总计有9TB的DDR4内存和另外1.7TB的HBM2内存，总计内存容量高达10.7TB。一个机架的最大功率为59kW，峰值计算能力包括CPU的话是846TFlops，只计算GPU的话是775TFlops。      
在机架之后就是整个Summit系统了。完整的Summit系统拥有256个机架，18个交换机架，40个存储机架和4个基础架构机架。完整的Summit系统拥有2.53PB的DDR4内存、475TB的HBM2内存和7.37PB的NVMe SSD存储空间。
