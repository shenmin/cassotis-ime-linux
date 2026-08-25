# 言泉输入法 Linux 版

<p align="center">
  <img src="cassotis_ime_yanquan.png" alt="Cassotis IME logo" width="280">
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue" alt="License: GPL-3.0"></a>
</p>

[English](README.md) | 简体中文 | [Windows 版](https://github.com/shenmin/cassotis-ime)

言泉输入法 Linux 版是同时支持 IBus 与 Fcitx 5 的原生中文拼音输入法。
本项目源自
[言泉输入法 Windows 版](https://github.com/shenmin/cassotis-ime)，并使用
[Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon) 生成的词库。
共享的 Free Pascal 引擎移植了言泉输入法 v1.17.0 的候选召回、短词排序、
长句排序、一键补全、用户学习、模糊拼音与双拼逻辑。

## 主要功能

- 使用 [Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon)
  生成的简体、繁体词库。
- 支持全拼及微软、小鹤、自然码、搜狗、紫光、拼音加加六套双拼方案。
- 完整使用言泉输入法 v1.17.0 的短词、长句本地统计排序模型链。
- 持久化用户学习，并可删除已学习候选。
- 受控的一键补全和可配置快捷键。
- IBus 与 Fcitx 5 使用各自的原生适配层，共享同一引擎和用户词库。
- 提供 GTK 3 设置程序，配置 Linux 版支持的跨平台输入选项。

## 已验证发行环境

首个二进制版本已在 Ubuntu 26.04、GNOME、Wayland、x86_64 环境完成验收。
安装包同时包含 IBus 与 Fcitx 5 适配层，安装后选择其中一个框架启用即可。
构建脚本已识别 Linux aarch64 目标，但在原生硬件完成同等验收前不发布
aarch64 二进制包。

具体测试范围和平台状态见 [COMPATIBILITY.md](COMPATIBILITY.md)。

## 安装

从 GitHub Release 下载 `.deb` 与 `SHA256SUMS`，校验后用 APT 安装：

```bash
sha256sum --check SHA256SUMS
sudo apt install ./cassotis-ime_0.1.0_amd64.deb
```

安装器会刷新当前活动的 IBus 和 Fcitx 5 桌面会话。在使用 IBus 的 GNOME
桌面中，Cassotis 会直接加入输入源列表，无需重启系统或重新登录，也不会
强制切换当前输入源。如果安装时没有活动的图形桌面会话，则会在下次登录时
自动发现 Cassotis。

使用 Fcitx 5 会话时，应先把桌面输入法框架切换为 Fcitx 5，再通过 Fcitx 5
配置工具添加 Cassotis。IBus 与 Fcitx 5 可以同时安装，但当前桌面会话应只
由其中一个框架管理。

便携包包含相同文件，也可用于系统安装或暂存安装：

```bash
tar -xzf cassotis-ime-linux-0.1.0-x86_64.tar.gz
cd cassotis-ime-linux-0.1.0-x86_64
sudo ./install.sh
```

只有使用便携包安装时才使用 `sudo ./uninstall.sh` 卸载；通过软件包安装的
版本应执行 `sudo apt remove cassotis-ime`。两种卸载方式都不会删除用户词库
和设置，并会在安装、卸载时刷新桌面及 IBus 组件缓存。软件包只建议安装
IBus 或 Fcitx 5 其中一个框架，不会建议同时安装两个桌面守护进程。

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
