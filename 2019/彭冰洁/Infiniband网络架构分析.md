Infiniband网络架构分析
==

目录
==

- 什么是Infiniband网络     
- InfiniBand架构  
- InfiniBand速率发展介绍   
- IB技术的优势   
- 

Infiniband网络
----
InfiniBand是一种网络通信协议，它提供了一种基于交换的架构，由处理器节点之间、处理器节点和输入/输出节点(如磁盘或存储)之间的点
对点双向串行链路构成。每个链路都有一个连接到链路两端的设备，这样在每个链路两端控制传输(发送和接收)的特性就被很好地定义和控制了。  
适配器通过PCI Express接口一端连接到CPU，另一端通过InfiniBand网络端口连接到InfiniBand子网。与其他网络通信协议相比，这提供了明
显的优势，包括更高的带宽、更低的延迟和增强的可伸缩性。   
![网络](http://m.qpic.cn/psc?/V10d7b8e2YPTcE/T7ZeoLlLvDuhDKIHjjjMLVQ0EdCmxjnUo4TUeU*22KEuab75u09MD9IpzerADZDgUMmHZIzpx7qFZI4I51gay7LUN4hmRBrRubQaD3xAzzY!/b&bo=dgIuAQAAAAARF3s!&rf=viewer_4)    
InfiniBand通过交换机在节点之间直接创建一个私有的、受保护的通道，进行数据和消息的传输，无需CPU参与远程直接内存访问(RDMA)和
发送/接收由InfiniBand适配器管理和执行的负载。   

InfiniBand架构
----
InfiniBand Architecture(IBA)是为硬件实现而设计的，而TCP则是为软件实现而设计的。因此，InfiniBand是比TCP更轻的传输服务，因为它不
需要重新排序数据包，因为较低的链路层提供有序的数据包交付。传输层只需要检查包序列并按顺序发送包。    
进一步，因为InfiniBand提供以信用为基础的流控制(发送方节点不给接收方发送超出广播 “信用“大小的数据包),传输层不需要像TCP窗口算法那样
的包机制确定最优飞行包的数量。这使得高效的产品能够以非常低的延迟和可忽略的CPU利用率向应用程序交付56、100Gb/s的数据速率。    
IB是以通道(Channel)为基础的双向、串行式传输，在连接拓朴中是采用交换、切换式结构(Switched Fabric)，所以会有所谓的IBA交换器(Switch)，此外在
线路不够长时可用IBA中继器(Repeater)进行延伸。    
而每一个IBA网络称为子网(Subnet)，每个子网内最高可有65,536个节点(Node)，IBASwitch、IBA Repeater仅适用于Subnet范畴，若要通跨
多个IBA Subnet就需要用到IBA路由器(Router)或IBA网关器(Gateway)。    
至于节点部分，Node想与IBA Subnet接轨必须透过配接器(Adapter)，若是CPU、内存部分要透过HCA (Host Channel Adapter)，若为硬盘、I/O部分
则要透过TCA (Target Channel Adapter)，之后各部分的衔接称为联机(Link)。上述种种构成了一个完整的IBA。     

InfiniBand速率发展介绍               
----        
InfiniBand串行链路可以在不同的信令速率下运行，然后可以捆绑在一起实现更高的吞吐量。原始信令速率与编码方案耦合，产生有效的传输速率。   
编码将通过铜线或光纤发送的数据的错误率降至最低，但也增加了一些开销(例如，每8位数据传输10位)。     
典型的实现是聚合四个链接单元(4X)。目前，InfiniBand系统提供以下吞吐量速率:         
![吞吐量速率](https://m.qpic.cn/psc?/V10d7b8e2YPTcE/T7ZeoLlLvDuhDKIHjjjMLYgCPRkga4huE5BbAXK10Eh.cBQKEF0K1Vr1SWYLE4B8GpjlKE*Q79dHcg03*EhcoFh1qVogYjz85dGulYROmfc!/b&bo=YwIvAQAAAAARB38!&rf=viewer_4)      

IB技术的优势  
--
Infiniband大量用于FC/IP SAN、NAS和服务器之间的连接,作为iSCSI RDMA的存储协议iSER已被IETF标准化。目前EMC全系产品已经切换到Infiniband组网，IBM/TMS的FlashSystem系列，IBM的存储系统XIV Gen3，DDN的SFA系列都采用Infiniband网络。    
相比FC的优势主要体现在性能是FC的3.5倍，Infiniband交换机的延迟是FC交换机的1/10，支持SAN和NAS。   
存储系统已不能满足于传统的FC SAN所提供的服务器与裸存储的网络连接架构。HP SFS和IBM GPFS 是在Infiniband fabric连接起来的服务器和iSER Infiniband存储构建的并行文件系统，完全突破系统的性能瓶颈。      
Infiniband采用PCI串行高速带宽链接，从SDR、DDR、QDR、FDR到EDR HCA连接，可以做到1微妙、甚至纳米级别极低的时延，基于链路层的流控机制实现先进的拥塞控制。      
InfiniBand采用虚通道(VL即Virtual Lanes)方式来实现QoS，虚通道是一些共享一条物理链接的相互分立的逻辑通信链路，每条物理链接可支持多达15条的标准虚通道和一条管理通道(VL15)。       
![](http://m.qpic.cn/psc?/V10d7b8e2YPTcE/T7ZeoLlLvDuhDKIHjjjMLcfaxfy5TsBsoz6u*La7lNUX23KzEiBD1bzi6xcUmUBUWqngZLs7BtMtgkCRCnxxvCeM7mNvfkQMNqTp8ifYG*g!/b&bo=gAI.AQAAAAARF50!&rf=viewer_4)
RDMA技术实现内核旁路，可以提供远程节点间RDMA读写访问，完全卸载CPU工作负载，基于硬件传出协议实现可靠传输和更高性能。     
![](http://m.qpic.cn/psc?/V10d7b8e2YPTcE/T7ZeoLlLvDuhDKIHjjjMLVfUKIZHJbJVPENlNGvi8LuVQgMx*WMKF72p8kd6hixzVnAu.e5hWDDmVH1lDqMAlwsLf71BuVpYdX4S*NyH9m4!/b&bo=gAJxAQAAAAARF9I!&rf=viewer_4)    
相比TCP/IP网络协议，IB使用基于信任的、流控制的机制来确保连接的完整性，数据包极少丢失，接受方在数据传输完毕之后，返回信号来标示缓存空间的可用性，所以IB协议消除了由于原数据包丢失而带来的重发延迟，从而提升了效率和整体性能。      
TCP/IP具有转发损失的数据包的能力，但是由于要不断地确认与重发，基于这些协议的通信也会因此变慢，极大地影响了性能。     
