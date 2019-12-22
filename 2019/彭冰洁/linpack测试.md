Linpack测试及性能分析
=======
1、Linpack简介
-
Linpack是国际上最流行的用于测试高性能计算机系统浮点性能的benchmark。
通过对高性能计算机采用高斯消元法求解一元N次稠密线性代数方程组的测试，评价高性能计算机的浮点性能。  
Linpack测试包括三类，Linpack100、Linpack1000和HPL。
Linpack100求解规模为100阶的稠密线性代数方程组，它只允许采用编译优化选项进行优化，不得更改代码，甚至代码中的注释也不得修改。
Linpack1000要求求解1000阶的线性代数方程组，达到指定的精度要求，可以在不改变计算量的前提下做算法和代码上做优化。
HPL即High Performance Linpack，也叫高度并行计算基准测试，它对数组大小N没有限制，求解问题的规模可以改变，除基本算法（计算量）不可改变外，
可以采用其它任何优化方法。前两种测试运行规模较小，已不是很适合现代计算机的发展。
HPL是针对现代并行计算机提出的测试方式。用户在不修改任意测试程序的基础上，
可以调节问题规模大小(矩阵大小)、使用CPU数目、使用各种优化方法等等来执行该测试程序，以获取最佳的性能。  
HPL采用高斯消元法求解线性方程组。求解问题规模为N时，浮点运算次数为(2/3 * N^3－2*N^2)。
因此，只要给出问题规模N，测得系统计算时间T，峰值=计算量(2/3 * N^3－2*N^2)/计算时间T，测试结果以浮点运算每秒（Flops）给出。 
  
2、计算机计算峰值简介
-
衡量计算机性能的一个重要指标就是计算峰值或者浮点计算峰值，它是指计算机每秒钟能完成的浮点计算最大次数。包括理论浮点峰值和实测浮点峰值。
理论浮点峰值是该计算机理论上能达到的每秒钟能完成浮点计算最大次数，它主要是由CPU的主频决定的。  
理论浮点峰值＝CPU主频×CPU每个时钟周期执行浮点运算的次数×系统中CPU数  
CPU每个时钟周期执行浮点运算的次数是由处理器中浮点运算单元的个数及每个浮点运算单元在每个时钟周期能处理几条浮点运算来决定的。
  
3、Linpack安装与测试
-
安装HPL之前先安装并行环境mpich，运行时需要BLAS库或者VSIPL库，库的性能对最终测得的Linpack性能有密切的关系。  
第一步，下载HPL包hpl2.3.tar.gz并解压。  
第二步，编写make文件。从hpl/setup目录下选择合适的Make.<arch>文件copy到hpl/目录下，如：Make.Linux_PII_FBLAS文件代表Linux操作系统、PII平台、采用FBLAS库；Make.Linux_PII_CBLAS_gm文件代表Linux操作系统、PII平台、采用CBLAS库且MPI为GM。HPL所列都是一些比较老的平台，只要找相近平台的文件然后加以修改即可。修改的内容根据实际环境的要求，在Make文件中也作了详细的说明。主要修改的变量有：  
ARCH： 必须与文件名Make.<arch>中的<arch>一致  
TOPdir：指明hpl程序所在的目录  
MPdir： MPI所在的目录  
MPlib： MPI库文件    
LAdir： BLAS库或VSIPL库所在的目录   
LAinc、LAlib：BLAS库或VSIPL库头文件、库文件   
CC： C语言编译器  
CCFLAGS：C编译选项  
LINKER：Fortran 77编译器  
LINKFLAGS：Fortran 77编译选项（Fortran 77语言只有在采用Fortran库是才需要）  
第三步，编译。在hpl目录下执行make arch=<arch>，<arch>即为Make.<arch>文件的后缀，生成可执行文件xhpl(在hpl/bin/<arch>目录下) 。
HPL.dat文件是Linpack测试的优化配置文件。  
在hpl/bin/test文件夹下，在终端运行'mpirun -np 4 xphl'指令。    
PS：因为是在虚拟机搭建的环境下面跑的，得到的数据非常不尽人意。   

4、Linpack优化方法
-
修改HPL.dat的配置情况，达到优化的目的。  
HPLinpack benchmark input file
（注释）  
Innovative Computing Laboratory, University of Tennessee
（注释）    
HPL.out      output file name (if any)
（指定文件）  
6            device out (6=stdout,7=stderr,file)
（6是标准输出，7是输出至标准错误输出）  
4            # of problems sizes (N)
（求解矩阵的次数）  
29 30 34 35  Ns
（矩阵的大小）  
4            # of NBs  
1 2 3 4      NBs
（求解矩阵分块的大小NB）  
0            PMAP process mapping (0=Row-,1=Column-major)
（选择处理器阵列按列还是按行）  
3            # of process grids (P x Q)  
2 1 4        Ps  
2 4 1        Qs
（二维处理器网络）  
16.0         threshold
（测试的精度）  
3            # of panel fact  
0 1 2        PFACTs (0=left, 1=Crout, 2=Right)   
2            # of recursive stopping criterium  
2 4          NBMINs (>= 1)  
1            # of panels in recursion  
2            NDIVs  
3            # of recursive panel fact.  
0 1 2        RFACTs (0=left, 1=Crout, 2=Right)
（L分解的方式）  
1            # of broadcast  
0            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
（L的横向广播方式）  
1            # of lookahead depth  
0            DEPTHs (>=0)
（横向通信的通信深度）  
2            SWAP (0=bin-exch,1=long,2=mix)  
64           swapping threshold
(U的广播算法）  
0            L1 in (0=transposed,1=no-transposed) form  
0            U  in (0=transposed,1=no-transposed) form
（分别说明L和U的数据存放方式）  
1            Equilibration (0=no,1=yes)
（默认）  
8            memory alignment in double (> 0)
（地址对齐）    
矩阵的规模N越大，有效计算所占的比例也越大，系统浮点处理性能也就越
高；但与此同时，矩阵规模的增加会导致内存消耗量的增加，一旦系统实际内
存空间不足，使用缓存、性能会大幅度降低。因此，对于一般系统而言，要尽量
增大矩阵规模N的同时，又要保证不使用系统缓存。因为操作系统本身需要占
用一定的内存，除了矩阵（N×N）之外，HPL还有其他的内存开销，另外通信也
需要占用一些缓存。矩阵占用系统总内存的80%左右为最佳，即N×N×8=系统
总内存×80%。  
NB：为提高数据的局部性，从而提高整体性能，HPL采用分块矩阵的算法。分块
的大小对性能有很大的影响，NB的选择和软硬件许多因素密切相关。NB值
的选择主要是通过实际测试得到最优值。  
HPL求解时对矩阵执行LU分解。得到一个上三角矩阵U和一个下三角矩阵L，A等于这两个矩阵的乘积。
LU 分解的形式有三种：Right-looking LU Faetoriza—tion、Left-looking LU 
Faetorization 和 Crout-looking LU Factorization，它们之间的区别主要体现在panel 内 LU 分解以及尾矩阵更新的执行顺序不同。   








