# DevEco Studio 项目导入说明

## 📦 项目结构

本项目已配置为可直接导入 DevEco Studio 的完整项目。

## 🚀 导入步骤

### 1. 解压项目
```bash
tar -xzf DailyCuration-IDE.tar.gz
```

### 2. 打开项目
- 启动 DevEco Studio 4.0+
- `File` → `Open`
- 选择 `DailyCuration-IDE` 文件夹
- 等待项目同步完成

### 3. 配置 SDK（首次）
如果提示缺少 SDK：
- 点击 `Download` 下载 HarmonyOS SDK
- 选择 API 9 或更高版本

### 4. 配置签名
- `File` → `Project Structure` → `Signing Configs`
- 勾选 ✅ `Automatically generate signature`
- 点击 `Apply` → `OK`

### 5. 编译运行
- 点击工具栏 🔨 编译按钮
- 或 `Build` → `Build Hap(s)/APP(s)` → `Build Hap(s)`

## 📂 文件说明

```
DailyCuration-IDE/
├── .idea/                    # IDE 配置文件
│   ├── workspace.xml
│   ├── misc.xml
│   └── modules.xml
├── build-profile.json5       # 项目构建配置
├── oh-package.json5          # 项目依赖
├── hvigorfile.ts             # Hvigor 构建脚本
└── entry/                    # 入口模块
    ├── build-profile.json5   # 模块构建配置
    ├── oh-package.json5      # 模块依赖
    ├── hvigorfile.ts         # 模块构建脚本
    └── src/main/
        ├── ets/              # ArkTS 源码
        │   ├── entryability/
        │   ├── pages/
        │   ├── components/
        │   ├── model/
        │   └── utils/
        ├── resources/        # 资源文件
        └── module.json5      # 模块配置
```

## ⚠️ 注意事项

1. **首次导入**可能需要下载 Gradle 依赖，请保持网络畅通
2. **SDK 版本**需要 API 9 (HarmonyOS 4.0) 或更高
3. **签名配置**必须使用自动签名或配置有效的开发者证书

## 🔧 常见问题

**Q: 导入后显示红色错误？**
A: 等待 Gradle 同步完成，或点击 `File` → `Sync Project with Gradle Files`

**Q: 编译提示缺少 SDK？**
A: `Tools` → `SDK Manager` → 下载 HarmonyOS SDK API 9+

**Q: 无法安装到真机？**
A: 确保已配置签名，并开启手机的开发者模式和 USB 调试

## 📱 运行

编译成功后：
1. 连接鸿蒙设备（或启动模拟器）
2. 点击运行按钮（▶️）
3. 或导出 HAP 后使用 `hdc install` 安装

---

**项目版本**: 1.0.0  
**最低 SDK**: API 9 (HarmonyOS 4.0)  
**目标 SDK**: API 11 (HarmonyOS 4.1)