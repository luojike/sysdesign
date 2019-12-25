Linpack标准测试
===
一、LINPACK标准概念
---

LINPACK标准是近年来很有名的一种进行浮点性能测试的标准。它由Jack Dongarra最早提出。LINPACK的名字也是来自于利用高斯消去法求解稠密矩阵线性方
程的线性代数包。LINPACK标准用来解决线性方程问题，问题的大小则作为一种可配置的参数来优化相关软件可以获得的最佳性能表现。事实上，LINPACK标准也
是根据问题大小分为三种测试的。它们依次为n=100,n=1000及不对n做限制的测试。在测试中均要求矩阵符合一定条件，运算结果符合精度。因为在LINPACK标准
中使用的是基于高斯消去法的矩阵分解，所以可以套用公式算出浮点运算次数，从而只要测出运行时间，就可求得运算速度。

二、LINPACK安装
---
在安装之前，我们需要做一些软件准备下。

（1）Linux平台，最新稳定内核的Linux发行版最佳，可以选择Red hat, Centos等。

（2）MPICH2，这是个并行计算的软件，可以到http://www.mcs.anl.gov/research/projects/mp ich2/downloads/index.php?s=downloads下载最新的源码包。

（3）Gotoblas，BLAS库（Basic Linear Algebra Subprograms）是执行向量和矩阵运算的子程序集合，这里我们选择公认性能最好的Gotoblas，最新版可到http://www.tacc.utexas.edu/tacc- projects/下载，需要注册。

（4）HPL，linpack测试的软件，可在http://www.netlib.org/benchmark/hpl/下载最新版本。

安装方法和步骤如下。

（1）安装MPICH2，并配置好环境变量，本书前面已作介绍。

（2）进入Linux系统，建议使用root用户，在/root下建立linpack文件夹，解压下载的Gotoblas和HPL文件到linpack文件夹下，改名为Gotoblas和hpl。

    #tar xvf GotoBLAS-*.tar.gz  
    #mv GotoBLAS-*  ~/linpack/Gotoblas  
    #tar xvf  hpl-*.tar.gz  
    #mv hpl-*  ~/linpack/hpl 

（3）安装Gotoblas。

进入Gotoblas文件夹，在终端下执行./ quickbuild.64bit（如果你是32位系统，则执行./ quickbuild.31bit）进行快速安装，当然，你也可以依据README里的介绍自定义安装。如果安装正常，在本目录下就会生成 libgoto2.a和libgoto2.so两个文件。

（4）安装HPL。

进入hpl文件夹从setup文件夹下提取与自己平台相近的Make.<arch>文件，复制到hpl文件夹内，比如我们的平台为 Intel xeon，所以就选择了Make.Linux_PII_FBLAS，它代表Linux操作系统、PII平台、采用FBLAS库。

编辑刚刚复制的文件，根据说明修改各个选项，使之符合自己的系统，比如我们系统的详细情况为，Intel xeon平台，mpich2安装目录为/usr/local/mipch2，hpl和gotoblas安装目录为/root/linpack，下面是我们 的配置文件Make.Linux_xeon，对需要修改的部分我们做了注解，大家可以参考修改：
