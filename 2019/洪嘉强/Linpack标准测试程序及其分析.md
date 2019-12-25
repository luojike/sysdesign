Linpack标准测试
===
一、LINPACK标准概念
---

LINPACK标准是近年来很有名的一种进行浮点性能测试的标准。它由Jack Dongarra最早提出。LINPACK的名字也是来自于利用高斯消去法求解稠密矩阵线性方
程的线性代数包。LINPACK标准用来解决线性方程问题，问题的大小则作为一种可配置的参数来优化相关软件可以获得的最佳性能表现。Linpack测试包括三类，Linpack100、Linpack1000和HPL。Linpack100求解规模为100阶的稠密线性代数方程组，它只允许采用编译优化选项进行优化，不
得更改代码，甚至代码中的注释也不得修改。Linpack1000要求求解规模为1000阶的线性代数方程组，达到指定的精度要求，可以在不改变计算量的前提下做算
法和代码上做优化。HPL即High Performance Linpack，也叫高度并行计算基准测试，它对数组大小N没有限制，求解问题的规模可以改变，除基本算法（计算
量）不可改变外，可以采用其它任何优化方法。前两种测试运行规模较小，已不是很适合现代计算机的发展，因此现在使用较多的测试标准为HPL，而且阶次N也是
linpack测试必须指明的参数。<br>
HPL是针对现代并行计算机提出的测试方式。用户在不修改任意测试程序的基础上，可以调节问题规模大小N(矩阵大小)、使用到的CPU数目、使用各种优化方法等
来执行该测试程序，以获取最佳的性能。HPL采用高斯消元法求解线性方程组。当求解问题规模为N时，浮点运算次数为(2/3 * N^3－2*N^2)。因此，只要给出问
题规模N，测得系统计算时间T，峰值=计算量(2/3 * N^3－2*N^2)/计算时间T，测试结果以浮点运算每秒（Flops）给出。

二、LINPACK安装
---

在安装HPL之前，系统中必须具备以下三个条件：
1）编译器：系统必须安装了支持C语言和Fortran 77语言的编译器。推荐采用在Linux操作系统中自带的GNU编译器。
2）并行环境
并行环境是指MPI。在以太网环境下，一般采用MPICH，当然也可以是其它版本的MPI，如LAM－MPI。在Myrinet网下，采用MPICH-GM。若是其它网络环境就采用相应的MPI。
3）BLAS库
BLAS库及基本线性代数库，采用BLAS库的性能对最终测得的Linpack性能有密切的关系。常用的BLAS库有GOTO、Atlas、ACML、ESSL、MKL等
2．下载与编译
Step 1：   从www.netlib.org/benchmark/hpl 网站上下载HPL源代码包hpl.tar.gz并解包。
Step 2：   解包。tar –xzvf hpl.tar.gz。所有HPL源代码都在hpl目录下。
Step 3：   若采用GOTO库，则需要编译其补丁文件xerbla.f
g77 –c xerbla.f
生成目标文件xerbal.o
Step 4：   编写Make文件。
1） 从hpl/setup目录下拷贝Make.Linux_PII_FBLAS文件到hpl/目录下,并将文件更名为Make.test
$cd hpl
$cp setup/Make.Linux_PII_FBLAS Make.test
2） 修改Make.test的文件
主要修改的变量有：
ARCH：必须与文件名Make.<arch>中的<arch>一致
TOPdir：指明hpl程序所在的目录
MPdir： MPI所在的目录
MPlib： MPI库文件
LAdir： BLAS库或VSIPL库所在的目录
LAinc、LAlib：BLAS库或VSIPL库头文件、库文件
HPL_OPTS：包含采用什么库、是否打印详细的时间、是否在L广播之前拷贝L
CC：      C语言编译器
CCFLAGS： C编译选项
LINKER： Fortran 77编译器
LINKFLAGS：Fortran 77编译选项
Step 5：   编译
在hpl目录下执行  make arch=test
在编译完成后，在hpl/bin/test目录下生成可执行文件xhpl
 3．修改配置文件
在编译完成后，在hpl/bin/test目录下生成可执行文件xhpl的同时，也生成了一个配置文件HPL.dat。一般的测试只需要在此配置文件的基础上修改几个选项就可以得到不错的性能。
对于大部分系统，只需要修改Ns、NB和Ps×Qs三个选项。
 1） Ns
Ns表示求解线性方程组Ax＝b中矩阵A的规模（N）。
矩阵的规模N越大，有效计算所占的比例也越大，系统浮点处理性能也就越高；但与此同时，矩阵规模N的增加会导致内存消耗量的增加，一旦系统实际内存空间不足，使用缓存，性能会大幅度降低。因此，对于一般系统而言，要尽量增大矩阵规模N的同时，又要保证不使用系统缓存。
考虑到操作系统本身需要占用一定的内存，除了矩阵A（N×N）之外，HPL还有其它的内存开销，另外通信也需要占用一些缓存（具体占用的大小视不同的MPI而定）。一般来说，矩阵A占用系统总内存的80％左右为最佳，即N×N×8＝系统总内存×80％。
这只是一个参考值，具体N最优选择还跟实际的软硬件环境密切相关。当整个系统规模较小、节点数较少、每个节点的内存较大时，N可以选择大一点。当整个系统规模较大、节点数较多、每个节点的内存较小时是，N可以选择大一点。
  2） NB
NB的选择与测试平台、数学库等相关
  3） Ps×Qs
Ps×Qs表示二维处理器网格。其有遵循以下几个要求：
l P×Q＝进程数。这是HPL的硬性规定。
l P×Q＝系统CPU数＝进程数。一般来说一个进程对于一个CPU可以得到最佳性能。
l 当Q/4≤P≤Q时，性能较优。
l 当P＝2n，即P2的幂时，性能较优。
  4．运行：
HPL的运行方式和MPI密切相关，不同的MPI在运行方面有一定的差别。在这里只说明在MPICH下运行Linpack程序。
MPICH是基于以太网的MPI，也是目前使用最广泛的MPI。
首先编辑配置文件<p4file>（具体文件名可以自己定义），<p4file>每一行代表运行一个进程。下面是一个<p4file>的样例。
gnode1 0 /home/test/hpl/test/bin/xhpl
gnode1 1 /home/test/hpl/test/bin/xhpl
gnode2 1 /home/test/hpl/test/bin/xhpl
gnode2 1 /home/test/hpl/test/bin/xhpl
gnode3 1 /home/test/hpl/test/bin/xhpl
gnode3 1 /home/test/hpl/test/bin/xhpl
gnode4 1 /home/test/hpl/test/bin/xhpl
gnode4 1 /home/test/hpl/test/bin/xhpl
其中，每一行由三部分组成。第一个部分指出该进程运行在哪一个节点上；第二部分除了第一行是0之外，其余都是1；第三个部分是可执行文件xhpl所在的全路径。要注意的是，递交任务（即执行下面所说的mpirun命令）的节点必须是第一行所指明的节点（即第二部分为0的节点）。
然后，运行xhpl程序。即：在hpl/<arch>/bin目录下执行：
mpirun –p4pg <p4file> xhpl
  5．查看结果
HPL允许一次顺序做多个不同配置测试，所以结果输出文件（缺省文件名为HPL.out）可能同时有多项测试结果。
