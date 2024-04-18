# Features


+ (?) 考虑一种捕捉output的方式? 利用trap DEBUG? 或者去拥抱asciinema/termRecord这些? 抑或是完全不在这里考虑这种功能
+ (?) 转dockerfile
+ (?) 尝试捕捉更多的信息? 例如每一个操作的改变?
+ (?) 操作迁移, 真实操作
+ (?) html显示, 这大概没必要做, 因为只记录command不记录output的化是没必要嘞, 不过再想想


## v24.4

+ (√)  2024-04-18  Update deployment using new rdee-* series processing logic

## v24.3
+ (√) wf:UPDATE | 添加`wf_pexec`函数, 还是需要的, `wf_exec`对应简化
+ (√) wf:BUGFIX | 之前wf_exec都是`$1`不合理, 改成`$*`
+ (√) wf:UPDATE | 添加`wf_say`函数, 及不执行, 仅描述做了啥操作, 起补充描述作用
+ (√) utest:BUGFIX | 修正了在已经load wf的情况下utest在location用例下错误的问题, 因为检出了额外的状态信息, 加个unload即可
+ (√) rebuild:基于函数式改编, 不然rec mode没办法访问history, 奶奶的
+ (√) 优化自动记录模式逻辑, 支持全记录-ignore模式与仅记录特定命令模式, 例如句尾加个";"
+ (deprecated) 优化指令, `-r`模式现在改为从history里寻找匹配到的模式记录下来
+ (√) 补充基于bats的单元测试
+ (√) 补充部署代码, 基于rdee范式, 可集成到rdeeEnv中一起部署

## v23.12.12
+ 重构现有逻辑, 记录文件改为markdown格式, 优化记录方式, 相同路径连续操作统一记录
+ 增加filter_mode, 解析.wfignore文件中的过滤词, 筛除无用命令
+ 增加auto_mode, 不需要每次`wf -e`的去记录, 支持自动化记录

## v21.4.6
+ (√) 在v21.3.17的功能性基础上, 采用getopts的方式来实现, 而非直接参数判断

## v21.3.17
+ (√) 在v21.1.12的基础上, 扩展了功能性, 支持灵活查看方式以及新建, 取消操作等等

## v21.1.12
+ (√) 一个极简的记录功能, 实现把命令记录到文件中的功能


