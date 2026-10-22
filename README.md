# OrzAppLocker

一个轻量、低侵入的 iOS PIN 码锁组件：通过全屏弹窗完成「锁定 / 设置密码 / 修改密码 / 关闭密码」流程，使用 Keychain 持久化 PIN，支持文案与主题配置。

## 特性

- ✅ 链式 API：`OrzAppLocker.chain.configure(...).show(...)`
- ✅ Keychain 可配置（service / key / accessibility）
- ✅ 文案与主题可配置（内置 `zhCN` / `enUS`、`dark` / `light` / `adaptive`）
- ✅ 无 LocalAuthentication 依赖
- ✅ `Action.lock` 自动检测是否已设置 PIN（无 PIN 自动进入设置流程）

## 安装

### Swift Package Manager

使用 Swift Package Manager 集成 OrzAppLocker。

#### 远程依赖

在 Xcode 里通过仓库地址添加，或在 `Package.swift` 中添加：

```swift
.package(url: "https://github.com/OrzGeeker/OrzAppLocker.git", from: "0.0.1")
```

## 使用

### 快速开始

```swift
import OrzAppLocker

OrzAppLocker.chain
    .configure(
        .default(
            service: "com.yourapp.locker",
            strings: .zhCN,
            theme: .dark
        )
    )

OrzAppLocker.chain.lock()
```

### 动作（Action）

```swift
OrzAppLocker.chain.show(.setPasscode, over: rootVC)
OrzAppLocker.chain.show(.changePasscode, over: rootVC)
OrzAppLocker.chain.show(.disablePasscode, over: rootVC)
```

### 回调（Callbacks）

```swift
OrzAppLocker.chain
    .configure(
        .default(
            service: "com.yourapp.locker",
            onResult: { result in
                switch result {
                case .unlocked:
                    break
                case .passcodeSet:
                    break
                case .passcodeChanged:
                    break
                case .passcodeDisabled:
                    break
                case .cancelled:
                    break
                }
            },
            onFailedAttempt: { action in
                print("failed at: \(action)")
            }
        )
    )
    .lock(over: rootVC)
```

## Keychain 检测

对 `Action.lock`，组件会自动检测 Keychain 是否已有 PIN：
- 没有 PIN：进入设置流程（创建 + 确认）
- 有 PIN：进入验证流程（解锁）

## 配置说明

`OrzAppLocker.Configuration` 主要字段：
- `keychain`：`service / key / accessibility`（来自 [Valet](https://github.com/square/Valet) 的 `Accessibility`）
- `strings`：文案（内置 `Strings.zhCN / .enUS`）
- `theme`：主题（内置 `Theme.dark / .light / .adaptive`）
- `image`：头像/图片，不传则隐藏
- `cancelVisibility`：取消按钮显示策略（`.automatic / .hidden / .visible`）
- `onResult`：成功/取消回调
- `onFailedAttempt`：输错 PIN（或两次不一致）回调

## 亮暗模式

`.dark` / `.light` 是固定配色，适合要求锁屏始终一个样子的 App。

需要跟随系统亮暗模式时用 `.adaptive`：

```swift
OrzAppLocker.chain
    .configure(.default(service: "com.yourapp.locker", theme: .adaptive))
    .lock(over: rootVC)
```

`.adaptive` 用的是语义色（`.systemBackground` / `.label` / `.secondaryLabel` 等），所以：

- 系统亮暗切换时**不需要重建锁屏**，视图自己重取色
- 锁屏**显示期间**切换外观也会立即跟随（`AppLocker` 内部监听 trait 变化并重新应用主题；
  密码点、按键圆圈、头像描边是自绘的，会一起重绘）
- 提高对比度、着色外观等辅助模式同样生效

## 使用要点 / 注意事项

- PIN 固定为 4 位数字（当前版本不可配置）。
- `over:` 建议传当前活跃的 `UIViewController`；不传时会自动从 keyWindow 的 `rootViewController` 解析。
- `keychain.service` 必须为非空字符串；如果你传了空字符串，内部会因为无法构造 `Valet.Identifier` 而直接不展示锁页。
- `cancelVisibility` 默认是 `.automatic`：验证态（有 PIN 的 lock）会隐藏取消按钮；创建/修改/关闭流程会根据 action 自动隐藏或展示。
- `Action.lock` 的首次“设置 PIN 成功”会回调 `Result.unlocked`（不是 `Result.passcodeSet`）。
- 当前版本 `Result.passcodeChanged` 不会被触发：`.changePasscode` 修改成功后会回调 `Result.passcodeSet`。

## 环境要求

- iOS 13.0+
- Swift 5.9+（swift-tools-version: 5.9）

## 依赖

- [Valet](https://github.com/square/Valet) - Keychain 访问封装

## 变更记录

### 0.1.0

- 新增 `Theme.adaptive`：跟随系统亮暗模式的语义色主题
- 锁屏在显示期间响应 `UITraitCollection` 变化（iOS 17 用 `registerForTraitChanges`，
  iOS 13–16 回退 `traitCollectionDidChange`），切外观即时生效
- 修复描边色用 `static var` 存放的问题：密码点、按键圆圈、头像描边的颜色改为实例属性，
  多锁屏/多窗口不再互相覆盖；`photoImageView` 的 IBOutlet 类型改为 `PhotoImageView`
- 新增 `OrzAppLockerTests`（`.adaptive` 跟随 trait、固定配色不跟随、描边色实例隔离）

## License

MIT License - 详见 LICENSE 文件
