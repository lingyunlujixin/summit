 
-- 2016/04/14 Add By Lujx

* 该项目下有三个小功能，存放位置及说明如下：

  1> vba/scd
  
     通过简单的Excel配置，用VBA生成「实现缓慢变化维（Slowly Changing Dimensions）的SQL语句（MySQL及Hive通用版）」。
     
     亲测比较高效，已用于生产环境。
     
  2> vba/azk
  
     开源项目azkaban调度kettle（Pentaho Data Integration）时，任务依赖自动化管理工具。
  
  3> vba/fmt
  
     一些其他的小技巧。

* 特别说明：

  1 通用库（CommonUtil、CommonConst、FileOperation）在vba/目录下。

  2 项目引用了3个第三方VBA包（git位置： https://github.com/VBA-tools ），为适应日志处理需求，对其中Logger.bas做了更改。

    ※第三方VBA包放在了vba/thirdparty/下，今后如再有其他引用，亦打算放在该位置下，不再特别说明。

    ※如有必要，请用上述的git地址获取最新版本的第三方VBA包，本项目难保同步更新。
    
  3 功能尚不完善，并且会基于「通用」的考量不断做出修改，有任何建议或问题，欢迎Email！

