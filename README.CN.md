# 言泉输入法 Linux 版

<p align="center">
  <img src="cassotis_ime_yanquan.png" alt="Cassotis IME logo" width="280">
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0--only-blue" alt="License: GPL-3.0-only"></a>
  <a href="https://github.com/shenmin/cassotis-ime-linux/actions/workflows/ci.yml"><img src="https://github.com/shenmin/cassotis-ime-linux/actions/workflows/ci.yml/badge.svg" alt="Linux CI"></a>
</p>

<p align="center">
  <img src="snapshot.jpg" alt="言泉输入法 Linux 版截图" width="600" height="282">
</p>

[English](README.md) | 简体中文 | [Windows 版](https://github.com/shenmin/cassotis-ime) | [macOS 版](https://github.com/shenmin/cassotis-ime-mac)

言泉输入法 Linux 版是同时支持 IBus 与 Fcitx 5 的原生中文拼音输入法。
本项目源自
[言泉输入法 Windows 版](https://github.com/shenmin/cassotis-ime)，并使用
[Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon) 生成的词库。
共享的 Free Pascal 引擎以言泉输入法 v2.1.0 为行为基线，由一个约 1.5 亿参数的
本地字符语言模型统一参与长句、短词、一键补全与 Tab 续写，并结合输入的拼音
修正同音字。支持全拼、简拼、六种双拼、用户学习及快捷输入。词库查询、模型推理、补全与
学习均在本地完成，不依赖云服务、网络连接或 GPU。

## 主要功能

- 使用 [Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon)
  生成的简体、繁体词库。
- 支持全拼及微软、小鹤、自然码、搜狗、紫光、拼音加加六套双拼方案。
- 全拼支持 `lue`/`nue` 与 `lve`/`nve` 两种写法，也支持 `jv`/`qv`/`xv` 音节
  对应的规范 `ju`/`qu`/`xu` 拼写；显式隔音符仍严格分隔音节，
  音节边界有歧义或已确认部分词语时，仍可选择完整前缀词及相应单字。
- 长句先由词库约束的路径搜索生成完整候选，再由共享语言模型选词及修正同音字。
  保留可单独选择的前缀词和单字；模型不可用或超时时，仍可正常使用词库候选。
- 短词依据完整匹配、用户选择、词频及前文进行排序；词库没有的三至五音节短语
  可由语言模型结合前文成句，并对照拼音纠正同音字，例如 `jiuguize` → “旧规则”。
  用户明确选过的短语可以学习，而不是依靠固定的首字拼接规则。
- 文档局部自适应只使用当前框架已提供的光标附近文本，临时提升文档内重复术语、
  转移关系和已经出现过的续写；有界证据按输入上下文隔离，并在上下文结束时清除，
  不会持久化文档内容。
- 持久化用户学习；选中已学习候选后按 `Ctrl+Delete` 可以删除。
  用户词随简繁模式转换显示，学习和删除仍对应同一词条，不会重复记录。
- 受控的一键补全和可配置快捷键；词库精确补全、可靠转移及文档局部召回提供
  即时结果，共享语言模型在后台重新选择或续写，置信不足则不显示预测。
- 短词补全在后台结合词库证据和共享字符模型重新排序；长句补全综合词库尾词、
  后续词召回及模型预测字符，通过学习式策略选择结果。等待后台结果时仍可正常
  选择普通候选，过期输入或其他应用上下文的结果不会覆盖当前补全。
- 没有预测续写时，全拼可将当前显示的前缀与一个完全匹配的词库尾词组合为
  Tab 兜底转换；不递归拼接长句，也不会自动把组合结果学成用户词。
  预测续写保留箭头标记，完整尾词转换只显示设定的补全快捷键；后台预测就绪后
  仍可替换兜底结果。
- 功能快捷键可单独启用或禁用，关闭后仍保留原有按键绑定。
- `ufh`、`uxh`、`usx` 等快捷输入符号、序号、数学符号；`urq`、`usj`、`uxq`
  输入日期、时间、星期。`i123.45` 或 `v123.45` 转换中文数字和金额大写，
  通过字母候选键、方向键与空格或鼠标选择。双拼用 `Shift+U/I/V` 进入。
  详见[快捷输入说明](CONFIGURATION.CN.md#快捷输入)。
- 中文标点模式下，连续输入数字后紧接句号键，默认输出小数点 `.`；可在设置中关闭。
- 可设置半角标点例外，提供 Markdown 预设，仅在中文标点、半角字符模式下生效。
- 全拼下可识别英文单词，原文显示为不编号的候选并可按空格上屏；中文数字选词、
  翻页和补全保持不变，英文原文不会作为中文用户词学习。
- IBus 与 Fcitx 5 使用各自的原生适配层，共享同一引擎、设置状态和用户
  词库；候选窗口外观与位置由当前框架及桌面主题负责。
- 提供 GTK 3 设置程序，配置 Linux 版支持的跨平台输入选项。

## v2.0.0

v2.0.0 将原先分散的神经模型合并为一个语言模型，长句、短词、补全和纠错
共用同一份权重与推理会话。现在仅分发 1 个神经模型，
引擎保留 7 组精简的编译参数；已移除旧模型代码和资源，升级时清理旧模型。
本版同时增加 U/I/V 快捷输入、数字后的自动小数点及词库外短语的语言模型组句。
还包括半角标点例外、英文单词识别、部分纠错选词与退格时的原始按键保护，以及
`tian/a`、`xing/a` 等鼻音与元音边界歧义下的前缀候选补齐，仍严格保留显式隔音符
与双拼边界。完整单音节 `ying`、`jiu`、`bu` 分别固定首选“应/應”“就”“不”。

引擎对齐言泉输入法和 Cassotis Lexicon v2.1.0 的行为与数据基线，
使用 schema 24 字词库，简体、繁体基础库分别有 249,876 和 253,088 条记录。
此数量包含 Unihan 等来源的单字读音条目及多字词条；同一字词可有多种读音记录，
不等于去重后的词语数量。简体包含 23,918 条单字记录和 225,958 条多字记录，
繁体包含 24,177 条单字记录和 228,911 条多字记录。
短词补全在后台重新排序；长句补全通过学习式策略综合词库与模型证据。
保留有界缓存、共享模型会话及空闲时回收可释放堆内存，不卸载模型，
也不丢失当前上下文。内存、延迟与准确度的实测结果见
[BENCHMARK.CN.md](BENCHMARK.CN.md)，不将某次测量视为所有场景的峰值上限。
等待后台结果时仍保留静态补全，模型置信不足时保持原有候选。
模型加载与预热在后台完成，就绪前仍可通过词库和原有排序正常输入、上屏及
使用静态补全，不让首次输入等待神经模型加载。

x86_64 与 aarch64 分别原生测量 16,300 条长句和 65,000 条短词，
报告长句选词、短词上下文、短词补全和长句补全四组指标。
测试机配置、计时范围、实测延迟与内存占用见
[BENCHMARK.CN.md](BENCHMARK.CN.md)。
发行检查还覆盖原生核心与词库测试、安装包内容、冷启动响应和自动化 IBus/Fcitx
桌面矩阵。桌面与输入框架的具体测试范围见
[COMPATIBILITY.md](COMPATIBILITY.md)。

面向 amd64 与 arm64 提供 `.deb` 安装包和便携二进制包。验证环境为
两个架构的 Ubuntu 26.04.1 GNOME Wayland，结果记录在
[BENCHMARK.CN.md](BENCHMARK.CN.md)。已发布安装包及校验信息请以
[GitHub Releases](https://github.com/shenmin/cassotis-ime-linux/releases) 为准。

两种架构的安装包均包含 IBus 与 Fcitx 5 适配层，安装后选择其中一个框架
启用即可。

两种架构的便携包均包含与对应 `.deb` 相同的动态链接二进制文件，仍然要求
系统提供兼容的运行库，并不是与发行版无关的通用安装包。依赖兼容的 Debian
系系统可安装与自身架构相符的软件包；其他发行版可先运行便携安装器的依赖预检，
如果二进制不兼容，则在本机从源码构建。

具体测试范围和平台状态见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 基准测试

以下为采用 v2.1.0 引擎及词库基线的 Linux v2.0.0 完整实测。
两种架构的四组完整基准均已通过，未放宽准确率、延迟或内存门槛。
安装包与桌面验收范围另见 [COMPATIBILITY.md](COMPATIBILITY.md)。
历史版本数据保留在 [BENCHMARK.CN.md](BENCHMARK.CN.md)。

原生实测于 2026-10-14（UTC+8）在 Ubuntu 26.04.1 虚拟机上进行，
两个架构均为 8 vCPU；x86_64 为 16 GiB 内存，aarch64 为 8 GiB。
x86_64 的物理主机为 Intel Core i5-12600K，aarch64 运行在 Apple silicon 上。
这些是各自测试机的实测，不是受控的硬件性能对比。
测试方法、语料来源、歧义词子集、不限时诊断与内存测量详见
[BENCHMARK.CN.md](BENCHMARK.CN.md)。

### 候选选词

长句包含 16,300 条，短词的每种上下文模式均包含 65,000 条。
下表使用生产设置，保留 100 ms 前台字符语言模型预算；延迟单位均为 ms。

| 架构 | 测试项 | Top1 | Top2 | 平均 | 中位数 | P95 | 最大 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 长句 | 13,372/16,300 (82.04%) | 14,264/16,300 (87.51%) | 115.642 | 114 | 181 | 492 |
| aarch64 | 长句 | 13,383/16,300 (82.10%) | 14,271/16,300 (87.55%) | 113.221 | 111 | 179 | 491 |
| x86_64 | 短词，无上下文 | 61,160/65,000 (94.09%) | 63,607/65,000 (97.86%) | 4.840 | 3 | 12 | 71 |
| aarch64 | 短词，无上下文 | 61,160/65,000 (94.09%) | 63,610/65,000 (97.86%) | 4.549 | 3 | 12 | 68 |
| x86_64 | 短词，有上下文 | 63,363/65,000 (97.48%) | 64,291/65,000 (98.91%) | 7.756 | 5 | 21 | 118 |
| aarch64 | 短词，有上下文 | 63,360/65,000 (97.48%) | 64,290/65,000 (98.91%) | 7.363 | 5 | 20 | 69 |

### 短词一键补全

65,000 条短词输入产生 12,831 次补全机会。
最终显示延迟包含异步重排，按键延迟单独报告。

| 架构 | 命中 | 每次命中平均省键 | 稳定 / 可比较对数 | 按键 P95 | 最终显示 P95 |
| --- | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 10,440/12,831 (81.37%) | 2.633 | 2,124/2,186 (97.16%) | 1.978 ms | 27.904 ms |
| aarch64 | 10,442/12,831 (81.38%) | 2.633 | 2,126/2,188 (97.17%) | 1.923 ms | 30.007 ms |

### 长句一键补全

全部 16,300 条使用实际部署的 120 ms 后台预算。正确延伸已输入前缀即可命中，
不要求一次补到参考句末尾。耗时包含解码、最终候选处理和可见补全；
延迟单位均为 ms。

| 架构 | 命中 | 预测提示覆盖 | 累计省键 | 平均 | 中位数 | P95 | 最大 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 3,758/16,300 (23.06%) | 16,123/16,300 (98.91%) | 9,273 | 115.514 | 111 | 193 | 523 |
| aarch64 | 3,767/16,300 (23.11%) | 16,117/16,300 (98.88%) | 9,291 | 118.191 | 115 | 194 | 464 |

## 安装

先按系统环境选择安装方式，避免在只读系统中执行系统级安装命令：

| 系统环境 | 下载格式 | 安装方式 |
| --- | --- | --- |
| 依赖兼容的 Debian、Ubuntu 及衍生系统 | `.deb` | [APT 安装](#debian-installation) |
| SteamOS 桌面模式等系统目录只读的环境 | `.tar.gz` | [用户目录安装，无需 sudo](#user-installation) |
| 其他具有兼容运行库、系统目录可写的发行版 | `.tar.gz` | [便携包的系统安装](#system-installation) |

<a id="debian-installation"></a>

### Debian / Ubuntu：APT 安装

从 [GitHub Releases](https://github.com/shenmin/cassotis-ime-linux/releases)
下载与系统架构相符的 `.deb`，将本地计算的 SHA-256 与 Release 资产信息中
显示的摘要核对一致后，再用 APT 安装：

```bash
arch="$(dpkg --print-architecture)"  # 输出 amd64 或 arm64
package="cassotis-ime_2.0.0_${arch}.deb"
sha256sum "${package}"
sudo apt install "./${package}"
```

安装器会刷新当前活动的 IBus 和 Fcitx 5 桌面会话。在使用 IBus 的 GNOME
桌面中，Cassotis 会直接加入输入源列表，无需重启系统或重新登录，也不会
强制切换当前输入源。如果安装时没有活动的图形桌面会话，则会在下次登录时
自动发现 Cassotis。按 `Super+Space` 并选择 **Cassotis 言泉拼音输入法**
即可开始输入。

使用 Fcitx 5 会话时，应先把桌面输入法框架切换为 Fcitx 5，再通过 Fcitx 5
配置工具添加 Cassotis。IBus 与 Fcitx 5 可以同时安装，但当前桌面会话应只
由其中一个框架管理。

设置界面可以从 GNOME 输入源中的 Cassotis“首选项”，或
`fcitx5-configtool` 中 Cassotis 的配置操作打开。安装后的备用命令是
`/usr/libexec/cassotis-ime/cassotis-settings`。

通过 APT 安装的版本使用 `sudo apt remove cassotis-ime` 卸载，用户词库和
设置会保留。

<a id="user-installation"></a>

### SteamOS 等只读系统：用户目录安装

先从 [GitHub Releases](https://github.com/shenmin/cassotis-ime-linux/releases)
下载与 `uname -m` 对应的便携包（`x86_64` 或 `aarch64`），并核对 SHA-256。
在 SteamOS 的**桌面模式**或其他系统目录只读的桌面环境中，使用当前发布的
便携二进制包，将程序安装到个人目录。不要沿用旧包中的安装脚本，也不要运行
`sudo ./install.sh`。请先结束正在输入的拼音，再在当前桌面用户的终端执行；
以下命令**不要使用 `sudo` 或 `su`**：

```bash
arch="$(uname -m)"  # 输出 x86_64 或 aarch64
archive="cassotis-ime-linux-2.0.0-${arch}.tar.gz"
sha256sum "${archive}"
tar -xzf "${archive}"
cd "cassotis-ime-linux-2.0.0-${arch}"
./install.sh --user --check &&
./install.sh --user
```

`--check` 只做预检，不安装文件；通过后才执行下一行安装命令。

自动选择时，KDE 优先使用已安装的 Fcitx 5，GNOME 优先使用 IBus；也可以通过
`--framework fcitx5` 或 `--framework ibus` 明确选择。安装器会先检查架构、
动态库/ABI 依赖和框架版本，通过后才复制文件。程序安装在
`~/.local/libexec/cassotis-ime`，词库安装在
`${XDG_DATA_HOME:-$HOME/.local/share}/cassotis-ime`，不写入 `/usr`，不关闭系统
只读保护。所选框架本身需要已安装，并已启用为桌面的输入法框架；
安装器不会自动安装依赖或替换当前桌面框架。指定框架时，两条命令均加上
相同的参数，例如 `./install.sh --user --framework ibus --check` 和
`./install.sh --user --framework ibus`。

安装后在当前框架中选择 Cassotis；若列表未刷新，重启该框架或重新登录。
用户目录安装的设置备用命令为
`~/.local/libexec/cassotis-ime/cassotis-settings`。

便携包附带独立的 OpenCC 简繁转换运行库及数据，在系统缺少它们时使用，
不会替换系统动态库。已在 SteamOS 3.8.14 的 KDE X11 桌面、IBus 1.5.32 下
验证用户目录安装、升级、卸载和实际输入；本次测试不覆盖 SteamOS 游戏模式，
也不覆盖 SteamOS 上的 Fcitx 5。SteamOS 仅验收安装与实际使用，不运行性能
基准；完整基准在两种架构的 Ubuntu 上执行。此方式不代表二进制包适用于所有发行版。
如果预检提示动态库不兼容或 Fcitx 版本过低，需要使用面向该发行版构建的
二进制，不应通过关闭系统只读保护处理。
详见 [用户目录安装与卸载](BUILD.md#portable-user-installation)。

升级时解压新版便携包，以同一桌面用户再次运行上述预检与安装命令。
使用 `--user` 安装的版本应通过 `./uninstall.sh --user` 卸载，**不要加 sudo**。
它只移除安装清单中未经修改的程序文件，保留用户词库和设置。不要混用系统安装、
源码用户目录安装和便携用户目录安装。

<a id="system-installation"></a>

### 其他系统：便携包的系统安装

仅当系统目录可写、具有管理员权限且运行库兼容时，才使用以下方式。
SteamOS 等只读系统请使用上面的[用户目录安装](#user-installation)。

```bash
arch="$(uname -m)"  # 输出 x86_64 或 aarch64
archive="cassotis-ime-linux-2.0.0-${arch}.tar.gz"
sha256sum "${archive}"
tar -xzf "${archive}"
cd "cassotis-ime-linux-2.0.0-${arch}"
sudo ./install.sh
```

便携安装器不会自动解决运行库依赖，所需库见 [BUILD.md](BUILD.md)。
仅这种系统级便携安装使用 `sudo ./uninstall.sh` 卸载，用户词库和设置会保留。

## 构建与测试

```bash
./rebuild_all.sh
```

构建与框架安装说明、基准测试结果和兼容性信息见：

- [BUILD.md](BUILD.md)
- [配置说明](CONFIGURATION.CN.md)
- [基准测试](BENCHMARK.CN.md) / [English](BENCHMARK.md)
- [COMPATIBILITY.md](COMPATIBILITY.md)
- [CHANGELOG.md](CHANGELOG.md)
- [词库格式](docs/DICTIONARY.md)
- [IPC 与进程架构](docs/IPC.md)

## 相关项目

- [言泉输入法 Windows 版](https://github.com/shenmin/cassotis-ime)
- [Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon)

## 许可证

程序源码采用 GPL-3.0-only；随发行包分发的 Cassotis Lexicon 数据库产物采用
CC BY-SA 4.0。详见 [LICENSE](LICENSE) 与 [NOTICE.md](NOTICE.md)。
词库上游来源的归属信息见
[Lexicon Attribution](docs/LEXICON_ATTRIBUTION.md)。
