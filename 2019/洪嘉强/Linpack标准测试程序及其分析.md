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
（2）MPICH2
（3）Gotoblas，BLAS库（Basic Linear Algebra Subprograms）是执行向量和矩阵运算的子程序集合，这里我们选择公认性能最好的Gotoblas
（4）HPL，linpack测试的软件
安装如下。
（1）安装MPICH2，并配置好环境变量
（2）进入Linux系统，建议使用root用户，在/root下建立linpack文件夹，解压下载的Gotoblas和HPL文件到linpack文件夹下，改名为Gotoblas和hpl
（3）安装Gotoblas。
（4）安装HPL。
