# 质量与一致性验收

[English](BENCHMARK.md) | 简体中文

发行门禁由源码与数据的机械一致性检查、Linux 原生单元测试与集成测试、
有边界的传输和内存压力测试、冻结候选一致性测试，以及语料规模的质量与
延迟基准测试共同组成。任何单项指标都不能单独证明两个平台完全一致。

## 基准版本

Linux v0.1.0 引擎依据以下版本完成审查和移植：

- Cassotis IME v1.17.0（`e9056cefb479c2df778664ec49e6da2056c59525`）
- Cassotis Lexicon v1.17.0（`a9a29c4a5d4679a65b34e9556decc31925a0857a`）
- 简体词库 schema 22，SHA-256：
  `a07942f79fe607bdb7dad14e0b0e82b87fef47473380cf98eda415afc6a9c354`
- 繁体词库 schema 22，SHA-256：
  `3cb9de47d9ff3dbc9a517d53a64ac0a547ecd4c72b1767e26c13152a8963c17e`

`tools/parity/validate_source_parity.py` 检查两个基准仓库的提交、全部
40 个生成模型单元、扩展模型证据和冻结词库。随后通过实际 SQLite
provider 运行小型回归集 `tests/cases/candidate_quality.tsv` 和
`tests/cases/candidate_quality_tc.tsv`，保护已确认的简体与繁体候选行为。

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
  --report-dir ./quality-report

python3 tools/parity/validate_quality_report.py \
  --summary ./quality-report/quality-summary.txt \
  --dictionary /path/to/dict_sc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --baseline tests/baselines/quality-v1.17.0-linux-x86_64.txt
```

测试程序报告 Top1、Top2、Top5、Top9 数量，平均、P50、P95 和最大查询
延迟，以及 Linux 进程 RSS 与内存高水位。内存事件只记录测试轨道和样例
编号，不记录私有查询文本。所有非 Top1 结果都会写入
`long-failures.tsv` 或 `short-failures.tsv`；这些文件用于诊断，并不代表
测试被忽略，也不会作为公开发行制品发布。

## 冻结的 v0.1.0 结果

完整发行测试使用外部提供的冻结测试文件。源句不属于公开程序发行内容，
因此本仓库不重新分发这些文件。发行记录通过文件大小和 SHA-256 绑定输入，
避免将另一组测试集的结果静默复用：

| 输入 | 样例数 | 字节数 | SHA-256 |
| --- | ---: | ---: | --- |
| 长句 | 16,300 | 2,673,936 | `3f50a9323ad798e691f86ea70c6dffa13b4a9f55b624fc3499a138258190ff0f` |
| 带冻结上下文的短词 | 65,000 | 9,200,779 | `cd02fc1a24e89a106c200f4864d5ad2c11afd4c8d784059a4b6e9a10c51fbab8` |

Ubuntu 26.04 x86_64 发行主机使用经过审查的 schema 22 简体词库，得到
以下原生引擎结果：

| 测试轨道 | Top1 | Top2 | Top5 | Top9 | 平均 | P50 | P95 | 最大值 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 长句 | 10,553/16,300（64.74%） | 12,008/16,300（73.67%） | 12,008 | 12,008 | 111.051 ms | 92 ms | 246 ms | 868 ms |
| 短词，无上下文 | 60,346/65,000（92.84%） | 63,163/65,000（97.17%） | 64,498 | 64,619 | 7.602 ms | 6 ms | 19 ms | 169 ms |
| 短词，有上下文 | 61,827/65,000（95.12%） | 63,516/65,000（97.72%） | 64,540 | 64,619 | 8.485 ms | 7 ms | 20 ms | 160 ms |

11,728 条标记为真实竞争候选的短词样例，在无上下文时取得
8,737/10,528 的 Top1/Top2，在有上下文时取得 9,596/10,775。
启用上下文后的短词质量计数与 Windows v1.17.0 参考结果完全一致。
Windows 长句参考值为 Top1 10,595、Top2 12,023；Linux 发行门槛允许经过
审查的少量编译器和运行时差异，但会拒绝更大的退化。延迟依赖测试主机，
不能把 Windows 与 Linux 不同硬件上的数据直接解释成实现速度倍数。

单个基准进程的最大 RSS/内存高水位为 557,252 KiB，低于 768 MiB 的发行
上限。同一次干净构建门禁还通过了全部 123 个 FPCUnit 测试、22/22 个
简体冻结候选、9/9 个繁体冻结候选，以及八上下文、8,300 次按键的传输
测试。该传输测试的 IPC 按键平均延迟为 19,855.531 微秒，最大延迟为
152,703 微秒；预热后 RSS 只增长 12 KiB，并成功通过引擎重启恢复测试。

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

仓库中的 x86_64 基线是最低发行门槛，不是训练目标。它要求测试样例数量
完整，平均、P95、最大延迟和峰值内存有明确上限，并要求 Top1/Top2 结果
接近经过审查的 Windows v1.17.0 参考值。只有更换冻结语料或经过审查的
引擎基准时才能更新该文件，不能通过降低阈值掩盖质量退化。

## 如何理解结果

本基准测量同步引擎查询时间，不包含按键投递、候选窗口绘制、桌面合成器
延迟或网络推理。测试有意不使用持久化用户词库；实际用户学习可以改善
个人候选排序，其行为由服务层和适配器测试单独验证。
