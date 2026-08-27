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

[English](README.md) | 简体中文 | [Windows 版](https://github.com/shenmin/cassotis-ime)

言泉输入法 Linux 版是同时支持 IBus 与 Fcitx 5 的原生中文拼音输入法。
本项目源自
[言泉输入法 Windows 版](https://github.com/shenmin/cassotis-ime)，并使用
[Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon) 生成的词库。
共享的 Free Pascal 引擎以言泉输入法 v1.17.0 为行为基线，移植了候选召回、
短词排序、长句排序、一键补全、用户学习、模糊拼音与双拼逻辑。词库查询、
排序、补全与学习均在本地完成，不依赖云服务或网络连接。

## 主要功能

- 使用 [Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon)
  生成的简体、繁体词库。
- 支持全拼及微软、小鹤、自然码、搜狗、紫光、拼音加加六套双拼方案。
- 移植言泉输入法 v1.17.0 的短词、上下文候选和长句本地统计排序模型链。
- 持久化用户学习；选中已学习候选后按 `Ctrl+Delete` 可以删除。
- 受控的一键补全和可配置快捷键。
- IBus 与 Fcitx 5 使用各自的原生适配层，共享同一引擎、设置状态和用户
  词库；候选窗口外观与位置由当前框架及桌面主题负责。
- 提供 GTK 3 设置程序，配置 Linux 版支持的跨平台输入选项。

## 已验证发行环境

v0.1.1 同时提供 amd64 与 arm64 的 `.deb` 安装包和便携二进制包。完整发行
验收目前在 Ubuntu 26.04 LTS、GNOME、Wayland、x86_64 环境完成。ARM64
产物已在 Ubuntu 26.04.1 ARM64 主机上原生构建，并通过核心测试、简繁词库
回归、产物一致性与完整性校验、软件包实际安装及已安装引擎自检；ARM64 上的
完整 IBus/Fcitx 桌面矩阵和人工 GUI 验收仍待完成。

两种架构的安装包均包含 IBus 与 Fcitx 5 适配层，安装后选择其中一个框架
启用即可。

两种架构的便携包均包含与对应 `.deb` 相同的动态链接二进制文件，仍然要求
系统提供兼容的运行库，并不是与发行版无关的通用安装包。依赖兼容的 Debian
系系统可安装与自身架构相符的软件包；其他发行版建议在本机从源码构建。

具体测试范围和平台状态见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 安装

从 [GitHub Releases](https://github.com/shenmin/cassotis-ime-linux/releases)
下载与系统架构相符的 `.deb`，将本地计算的 SHA-256 与 Release 资产信息中
显示的摘要核对一致后，再用 APT 安装：

```bash
arch="$(dpkg --print-architecture)"  # 输出 amd64 或 arm64
package="cassotis-ime_0.1.1_${arch}.deb"
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

也可以校验并安装与系统架构相符的便携二进制包：

```bash
arch="$(uname -m)"  # 输出 x86_64 或 aarch64
archive="cassotis-ime-linux-0.1.1-${arch}.tar.gz"
sha256sum "${archive}"
tar -xzf "${archive}"
cd "cassotis-ime-linux-0.1.1-${arch}"
sudo ./install.sh
```

便携安装器不会自动解决运行库依赖，所需库见 [BUILD.md](BUILD.md)。

只有使用便携包安装时才使用 `sudo ./uninstall.sh` 卸载；通过软件包安装的
版本应执行 `sudo apt remove cassotis-ime`。两种卸载方式都不会删除用户词库
和设置，并会在安装、卸载时刷新桌面元数据及活动输入法会话。软件包只建议
安装 IBus 或 Fcitx 5 其中一个框架，不会建议同时安装两个桌面守护进程。

## 构建与测试

```bash
./rebuild_all.sh
```

完整的构建、框架安装、基准测试和发行验收命令见：

- [BUILD.md](BUILD.md)
- [配置说明](CONFIGURATION.CN.md)
- [基准测试](BENCHMARK.CN.md) / [English](BENCHMARK.md)
- [RELEASE.md](RELEASE.md)
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
