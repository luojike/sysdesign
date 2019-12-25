Linpack标准测试
===
一、LINPACK标准概念
---

LINPACK标准是近年来很有名的一种进行浮点性能测试的标准。它由Jack Dongarra最早提出。LINPACK的名字也是来自于利用高斯消去法求解稠密矩阵线性方
程的线性代数包。<br>LINPACK标准用来解决线性方程问题，问题的大小则作为一种可配置的参数来优化相关软件可以获得的最佳性能表现。Linpack测试包括三类，Linpack100、Linpack1000和HPL。<br>Linpack100求解规模为100阶的稠密线性代数方程组，它只允许采用编译优化选项进行优化，不
得更改代码，甚至代码中的注释也不得修改。Linpack1000要求求解规模为1000阶的线性代数方程组，达到指定的精度要求，可以在不改变计算量的前提下做算
法和代码上做优化。HPL即High Performance Linpack，也叫高度并行计算基准测试，它对数组大小N没有限制，求解问题的规模可以改变，除基本算法（计算
量）不可改变外，可以采用其它任何优化方法。前两种测试运行规模较小，已不是很适合现代计算机的发展，因此现在使用较多的测试标准为HPL，而且阶次N也是
linpack测试必须指明的参数。<br>
HPL是针对现代并行计算机提出的测试方式。用户在不修改任意测试程序的基础上，可以调节问题规模大小N(矩阵大小)、使用到的CPU数目、使用各种优化方法等
来执行该测试程序，以获取最佳的性能。HPL采用高斯消元法求解线性方程组。当求解问题规模为N时，浮点运算次数为(2/3 * N^3－2*N^2)。因此，只要给出问
题规模N，测得系统计算时间T，峰值=计算量(2/3 * N^3－2*N^2)/计算时间T，测试结果以浮点运算每秒（Flops）给出。<br>

二、LINPACK安装
---

在安装HPL之前，系统中必须具备以下三个条件：<br>
1）编译器：<br>
系统必须安装了支持C语言和Fortran 77语言的编译器。推荐采用在Linux操作系统中自带的GNU编译器。<br>
2）并行环境<br>
并行环境是指MPI。在以太网环境下，一般采用MPICH，当然也可以是其它版本的MPI，如LAM－MPI。在Myrinet网下，采用MPICH-GM。若是其它网络环境就采用相应的MPI。<br>
3）BLAS库<br>
BLAS库及基本线性代数库，采用BLAS库的性能对最终测得的Linpack性能有密切的关系。常用的BLAS库有GOTO、Atlas、ACML、ESSL、MKL等<br>

三．下载与编译
---

Step 1：   从www.netlib.org/benchmark/hpl 网站上下载HPL源代码包hpl.tar.gz并解包。<br>
Step 2：   解包。tar –xzvf hpl.tar.gz。所有HPL源代码都在hpl目录下。<br>
Step 3：   若采用GOTO库，则需要编译其补丁文件xerbla.f<br>
g77 –c xerbla.f<br>
生成目标文件xerbal.o<br>
Step 4：   编写Make文件。<br>
1） 从hpl/setup目录下拷贝Make.Linux_PII_FBLAS文件到hpl/目录下,并将文件更名为Make.test<br>
$cd hpl<br>
$cp setup/Make.Linux_PII_FBLAS Make.test<br>
2） 修改Make.test的文件<br>
主要修改的变量有：<br>
ARCH：必须与文件名Make.<arch>中的<arch>一致<br>
TOPdir：指明hpl程序所在的目录<br>
MPdir： MPI所在的目录<br>
MPlib： MPI库文件<br>
LAdir： BLAS库或VSIPL库所在的目录<br>
LAinc、LAlib：BLAS库或VSIPL库头文件、库文件<br>
HPL_OPTS：包含采用什么库、是否打印详细的时间、是否在L广播之前拷贝L<br>
CC：      C语言编译器<br>
CCFLAGS： C编译选项<br>
LINKER： Fortran 77编译器<br>
LINKFLAGS：Fortran 77编译选项<br>
Step 5：   编译<br>
在hpl目录下执行  make arch=test<br>
在编译完成后，在hpl/bin/test目录下生成可执行文件xhpl<br>
 
 四．修改配置文件
 ---
 
在编译完成后，在hpl/bin/test目录下生成可执行文件xhpl的同时，也生成了一个配置文件HPL.dat。一般的测试只需要在此配置文件的基础上修改几个选项就可以得到不错的性能。<br>
对于大部分系统，只需要修改Ns、NB和Ps×Qs三个选项。<br>
 1） Ns<br>
Ns表示求解线性方程组Ax＝b中矩阵A的规模（N）。<br>
  2） NB<br>
NB的选择与测试平台、数学库等相关<br>
  3） Ps×Qs<br>
Ps×Qs表示二维处理器网格。其有遵循以下几个要求：<br>
l P×Q＝进程数。这是HPL的硬性规定。<br>
l P×Q＝系统CPU数＝进程数。一般来说一个进程对于一个CPU可以得到最佳性能。<br>
l 当Q/4≤P≤Q时，性能较优。<br>
l 当P＝2n，即P2的幂时，性能较优。<br>

  五．运行
  ---
  
HPL的运行方式和MPI密切相关，不同的MPI在运行方面有一定的差别。在这里只说明在MPICH下运行Linpack程序。<br>
MPICH是基于以太网的MPI，也是目前使用最广泛的MPI。<br>
首先编辑配置文件<p4file>（具体文件名可以自己定义），<p4file>每一行代表运行一个进程。<br>
其中，每一行由三部分组成。第一个部分指出该进程运行在哪一个节点上；第二部分除了第一行是0之外，其余都是1；第三个部分是可执行文件xhpl所在的全路径。要注意的是，递交任务（即执行下面所说的mpirun命令）的节点必须是第一行所指明的节点（即第二部分为0的节点）。<br>
然后，运行xhpl程序。即：在hpl/<arch>/bin目录下执行：<br>
mpirun –p4pg <p4file> xhpl<br>
 
  六．查看结果
  ---
  
HPL允许一次顺序做多个不同配置测试，所以结果输出文件（缺省文件名为HPL.out）可能同时有多项测试结果。<br>
