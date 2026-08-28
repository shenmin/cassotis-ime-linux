# 质量与一致性验收

[English](BENCHMARK.md) | 简体中文

发行门禁由源码与数据的机械一致性检查、Linux 原生单元测试与集成测试、
有边界的传输和内存压力测试、冻结候选一致性测试，以及语料规模的质量与
延迟基准测试共同组成。任何单项指标都不能单独证明两个平台完全一致。

## 基准版本

当前 Linux 引擎依据以下版本完成审查和移植：

- Cassotis IME v1.18.0（`48b8bc21bc408faa32a756764b39cf109e4be0fc`）
- Cassotis Lexicon v1.18.0（`51f41d211aa062cf70e96a017ee6e5b9d79474a7`）
- 简体词库 schema 24，SHA-256：
  `db8a59c61fe8d306b33dd08a8932a17007fdab8ac0480f49389cc9430493cc07`
- 繁体词库 schema 24，SHA-256：
  `06b2cba302e61bd016e4a7f8e47ba2c317d18cdda32457ac8ad232585ce4c829`

`tools/parity/validate_source_parity.py` 检查两个基准仓库的提交，分别
冻结并校验两端已经审阅的生产引擎、SQLite provider、拼音解析器、模糊音和
双拼源码清单，同时校验全部 42 个生成模型单元、扩展模型证据和冻结词库。
清单还会绑定 Transformer 与本地补全模型、运行时索引和清单、原生推理桥，
以及各架构对应的 ONNX Runtime。清单独立绑定 Delphi 与 FPC 的平台适配
源码，并不伪称两端文件可以逐字相同。
随后通过实际 SQLite provider 运行小型回归集 `tests/cases/candidate_quality.tsv` 和
`tests/cases/candidate_quality_tc.tsv`，保护已确认的简体与繁体候选行为。
完整质量门禁还会在仅排除依赖主机的耗时列后，对每一个非 Top1 样本计算签名。
这样无需公开私有基准语料，也能冻结逐样本名次和首选结果。

## Linux 完整基准测试

`cassotis-quality-benchmark` 在 Linux 上原生运行，使用与 Windows 项目
相同的最终词库和冻结测试集：

- 16,300 条长句测试
- 65,000 条无上下文短词测试
- 同一组 65,000 条带冻结左侧上下文的短词测试

直接构建并运行：

```bash
./scripts/build.sh
./build/bin/cassotis-quality-benchmark \
  --dictionary /path/to/dict_sc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --neural-runtime ./build/bin \
  --report-dir ./quality-report

python3 tools/parity/validate_quality_report.py \
  --summary ./quality-report/quality-summary.txt \
  --dictionary /path/to/dict_sc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --baseline tests/baselines/quality-v1.18.0-linux-x86_64.txt
```

长句准确率轨道使用确定性工作量上限，不以墙钟时间截断已经完成的
Transformer 决策；独立的生产模式轨道使用实际部署的 30 ms 神经结果接受
预算测量延迟。两个轨道使用同一模型和有界搜索。这样既避免主机瞬时负载改变
冻结准确率，又保留真实的生产延迟行为。

测试程序报告 Top1、Top2、Top5、Top9 数量，平均、P50、P95 和最大查询
延迟，以及 Linux 进程 RSS 与内存高水位。内存事件只记录测试轨道和样例
编号，不记录私有查询文本。所有非 Top1 结果都会写入
`long-failures.tsv` 或 `short-failures.tsv`；这些文件用于诊断，并不代表
测试被忽略，也不会作为公开发行制品发布。

## 冻结的 v1.18.0 移植结果

完整发行测试使用外部提供的冻结测试文件。源句不属于公开程序发行内容，
因此本仓库不重新分发这些文件。发行记录通过文件大小和 SHA-256 绑定输入，
避免将另一组测试集的结果静默复用：

| 输入 | 样例数 | 字节数 | SHA-256 |
| --- | ---: | ---: | --- |
| 长句 | 16,300 | 2,673,936 | `3f50a9323ad798e691f86ea70c6dffa13b4a9f55b624fc3499a138258190ff0f` |
| 带冻结上下文的短词 | 65,000 | 9,200,779 | `cd02fc1a24e89a106c200f4864d5ad2c11afd4c8d784059a4b6e9a10c51fbab8` |

Ubuntu 26.04 x86_64 与 Ubuntu 26.04.1 aarch64 发行主机使用经过审查的
schema 24 简体词库，得到以下原生引擎结果。候选名次来自不设置神经模型
墙钟超时的确定性准确率测试；耗时列来自另一轮采用部署版 30 ms 神经结果
预算的生产模式测试：

| 架构 | 测试轨道 | Top1 | Top2 | Top5 | Top9 | 平均 | P50 | P95 | 最大值 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 长句 | 10,687/16,300 | 12,104/16,300 | 12,104 | 12,104 | 149.270 ms | 134 ms | 305 ms | 1,024 ms |
| x86_64 | 短词，无上下文 | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 9.038 ms | 7 ms | 23 ms | 67 ms |
| x86_64 | 短词，有上下文 | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 10.120 ms | 8 ms | 25 ms | 87 ms |
| aarch64 | 长句 | 10,704/16,300 | 12,107/16,300 | 12,107 | 12,107 | 86.083 ms | 72 ms | 188 ms | 566 ms |
| aarch64 | 短词，无上下文 | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 5.394 ms | 4 ms | 13 ms | 42 ms |
| aarch64 | 短词，有上下文 | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 5.986 ms | 5 ms | 14 ms | 41 ms |

11,728 条标记为真实竞争候选的短词样例，在两个架构上均于无上下文时取得
8,737/10,528 的 Top1/Top2，在有上下文时取得 9,596/10,775。x86_64 与
aarch64 的全部短词汇总计数和逐样本失败签名完全一致。Windows v1.18.0
长句参考值为 Top1 10,731、Top2 12,128。Linux 长句结果与之接近，但 ONNX
Runtime 和浮点计算可能使少量样本跨过模型决策边界，因此两个架构分别冻结
精确逐样本签名；生产排序逻辑中不存在架构专用分支。延迟依赖测试主机，不能
把不同硬件上的数据直接解释成实现速度倍数。

v0.2.0 将字符语言模型的 span 评分改为不依赖先前无关查询留下的 n-gram
缓存。该项经过审查的运行时行为变更需要重新冻结长句签名。与临时基线相比，
x86_64 有 23 条 Top1 由错转对、21 条由对转错，净增 2 条；aarch64 有
3 条转对、2 条转错，净增 1 条。汇总质量下限没有降低，短词逐样本签名也
没有变化。

x86_64 与 aarch64 基准进程的最大 RSS/内存高水位分别为 763,640 KiB 和
866,268 KiB，均低于 960 MiB 的发行上限。两次干净构建门禁均通过全部
129 个 FPCUnit 测试、22/22 个简体冻结候选、9/9 个繁体冻结候选，以及
确定性的 500 样本神经补全测试。八上下文、8,300 次按键的传输测试在
x86_64 上平均为 19,472.237 微秒、最大为 129,987 微秒，预热后 RSS 增长
8 KiB；在 aarch64 上平均为 11,604.921 微秒、最大为 41,059 微秒，预热后
RSS 无增长。两个架构均通过引擎重启恢复测试。

## 完整发行门禁

首先在同时具有 Windows 和词库仓库 checkout 的机器上生成源码一致性报告：

```bash
python3 tools/parity/validate_source_parity.py \
  --windows-root /path/to/cassotis-ime \
  --lexicon-root /path/to/cassotis-lexicon \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --report source-parity.json
```

然后在目标 Linux 桌面会话中运行发行门禁：

```bash
./scripts/validate_release.sh \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --source-parity-report /path/to/source-parity.json \
  --report-dir ./release-validation
```

生成的 `release-validation.json`、平台矩阵、日志、基准文件、安装包校验和
与安装包共同构成一份可审计的发行记录。

仓库中的 x86_64 与 aarch64 基线是最低发行门槛，不是训练目标。它们要求
测试样例数量完整，平均、P95、最大延迟和峰值内存有明确上限，并冻结逐样本
失败签名和 v1.18.0 神经补全签名。只有更换冻结语料、经过审查的引擎基线或
明确记录的运行时变更时才能更新对应文件，不能通过降低阈值掩盖质量退化。

## 如何理解结果

本基准测量同步引擎查询时间，不包含按键投递、候选窗口绘制、桌面合成器
延迟或网络推理。测试有意不使用持久化用户词库；实际用户学习可以改善
个人候选排序，其行为由服务层和适配器测试单独验证。
