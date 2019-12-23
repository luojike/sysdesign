# Infiniband网络结构分析
## Infiniband网络 ##
InfiniBand（直译为“无限带宽”技术，缩写为IB）是一个用于高性能计算的计算机网络通信标准，它具有极高的吞吐量和极低的延迟，用于计算机与计算机之间的数据互连。InfiniBand也用作服务器与存储系统之间的直接或交换互连，以及存储系统之间的互连。
### IB基本概念
IB是以通道为基础的双向、串行式传输，在连接拓朴中是采用交换、切换式结构(Switched Fabric)，在线路不够长时可用IBA中继器(Repeater)进行延伸。
InfiniBand Architecture(IBA)是为硬件实现而设计的，而TCP则是为软件实现而设计的。因此，InfiniBand是比TCP更轻的传输服务，因为它不需要重新排序数据包，因为较低的链路层提供有序的数据包交付。传输层只需要检查包序列并按顺序发送包。
每一个IBA网络称为子网(Subnet)，每个子网内最高可有65,536个节点(Node)，IBA Switch、IBARepeater仅适用于Subnet范畴，若要通跨多个IBASubnet就需要用到IBA路由器(Router)或IBA网关器(Gateway)。
每个节点(Node) 必须透过配接器(Adapter)与IBA Subnet连接，节点CPU、内存要透过HCA(Host Channel Adapter)连接到子网；节点硬盘、I/O则要透过TCA(TargetChannel Adapter)连接到子网，这样的一个拓扑结构就构成了一个完整的IBA。
IB的传输方式和介质相当灵活，在设备机内可用印刷电路板的铜质线箔传递(Backplane背板)，在机外可用铜质缆线或支持更远光纤介质。若用铜箔、铜缆最远可至17m，而光纤则可至10km，同时IBA也支持热插拔，及具有自动侦测、自我调适的Active Cable活化智能性连接机制。
### IB技术的发展
1999年开始起草规格及标准规范，2000年正式发表，但发展速度不及Rapid I/O、PCI-X、PCI-E和FC，加上Ethernet从1Gbps进展至10Gbps。所以直到2005年之后，InfiniBand Architecture(IBA)才在集群式超级计算机上广泛应用。全球Top 500大效能的超级计算机中有相当多套系统都使用上IBA。
### IB协议简介
InfiniBand也是一种分层协议(类似TCP/IP协议)，每层负责不同的功能，下层为上层服务，不同层次相互独立。 IB采用IPv6的报头格式。其数据包报头包括本地路由标识符LRH，全局路由标示符GRH，基本传输标识符BTH等。
#### 物理层
物理层定义了电气特性和机械特性，包括光纤和铜媒介的电缆和插座、底板连接器、热交换特性等。定义了背板、电缆、光缆三种物理端口。
并定义了用于形成帧的符号(包的开始和结束)、数据符号(DataSymbols)、和数据包直接的填充(Idles)。详细说明了构建有效包的信令协议，如码元编码、成帧标志排列、开始和结束定界符间的无效或非数据符号、非奇偶性错误、同步方法等。
#### 链路层
链路层描述了数据包的格式和数据包操作的协议，如流量控制和子网内数据包的路由。链路层有链路管理数据包和数据包两种类型的数据包。
#### 网络层
网络层是子网间转发数据包的协议，类似于IP网络中的网络层。实现子网间的数据路由，数据在子网内传输时不需网络层的参与。
数据包中包含全局路由头GRH，用于子网间数据包路由转发。全局路由头部指明了使用IPv6地址格式的全局标识符(GID)的源端口和目的端口，路由器基于GRH进行数据包转发。GRH采用IPv6报头格式。GID由每个子网唯一的子网 标示符和端口GUID捆绑而成。
#### 传输层
传输层负责报文的分发、通道多路复用、基本传输服务和处理报文分段的发送、接收和重组。传输层的功能是将数据包传送到各个指定的队列(QP)中，并指示队列如何处理该数据包。当消息的数据路径负载大于路径的最大传输单元(MTU)时，传输层负责将消息分割成多个数据包。
接收端的队列负责将数据重组到指定的数据缓冲区中。除了原始数据报外，所有的数据包都包含BTH，BTH指定目的队列并指明操作类型、数据包序列号和分区信息。
#### 上层协议
InfiniBand为不同类型的用户提供了不同的上层协议，并为某些管理功能定义了消息和协议。InfiniBand主要支持SDP、SRP、iSER、RDS、IPoIB和uDAPL等上层协议。
+ SDP(SocketsDirect Protocol)是InfiniBand Trade Association (IBTA)制定的基于infiniband的一种协议，它允许用户已有的使用TCP/IP协议的程序运行在高速的infiniband之上。
+ SRP(SCSIRDMA Protocol)是InfiniBand中的一种通信协议，在InfiniBand中将SCSI命令进行打包，允许SCSI命令通过RDMA(远程直接内存访问)在不同的系统之间进行通信，实现存储设备共享和RDMA通信服务。
+ iSER(iSCSIRDMA Protocol)类似于SRP(SCSI RDMA protocol)协议，是IB SAN的一种协议 ，其主要作用是把iSCSI协议的命令和数据通过RDMA的方式跑到例如Infiniband这种网络上，作为iSCSI RDMA的存储协议iSER已被IETF所标准化。
+ RDS(ReliableDatagram Sockets)协议与UDP 类似，设计用于在Infiniband 上使用套接字来发送和接收数据。实际是由Oracle公司研发的运行在infiniband之上，直接基于IPC的协议。
+ IPoIB(IP-over-IB)是为了实现INFINIBAND网络与TCP/IP网络兼容而制定的协议，基于TCP/IP协议，对于用户应用程序是透明的，并且可以提供更大的带宽，也就是原先使用TCP/IP协议栈的应用不需要任何修改就能使用IPoIB。
+ uDAPL(UserDirect Access Programming Library)用户直接访问编程库是标准的API，通过远程直接内存访问 RDMA功能的互连（如InfiniBand）来提高数据中心应用程序数据消息传送性能、伸缩性和可靠性。
### Infiniband的网络拓扑结构，其组成单元主要分为四类：
+ HCA（Host Channel Adapter），它是连接内存控制器和TCA的桥梁；
+ TCA(Target Channel Adapter)，它将I/O设备（例如网卡、SCSI控制器）的数字信号打包发送给HCA；
+ Infiniband link，它是连接HCA和TCA的光纤，InfiniBand架构允许硬件厂家以1条、4条、12条光纤3种方式连结TCA和HCA；
+ 交换机和路由器；
无论是HCA还是TCA，其实质都是一个主机适配器，它是一个具备一定保护功能的可编程DMA（Direct Memory Access，直接内存存取 ）引擎
