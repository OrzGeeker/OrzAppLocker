import UIKit
import AudioToolbox
import Valet

public enum OrzAppLocker {
    public struct Chain {
        fileprivate init() {}

        @discardableResult
        public func configure(_ configuration: Configuration) -> Chain {
            OrzAppLocker.setConfiguration(configuration)
            return self
        }

        @discardableResult
        public func lock(over viewController: UIViewController? = nil) -> Chain {
            OrzAppLocker.show(.lock, over: viewController)
            return self
        }

        @discardableResult
        public func show(_ action: Action, over viewController: UIViewController? = nil) -> Chain {
            OrzAppLocker.show(action, over: viewController)
            return self
        }
    }

    public enum Action {
        case lock
        case setPasscode
        case changePasscode
        case disablePasscode
    }

    public enum Result: Equatable {
        case unlocked
        case passcodeSet
        case passcodeChanged
        case passcodeDisabled
        case cancelled
    }

    public struct Keychain {
        public var service: String
        public var key: String
        public var accessibility: Accessibility

        public init(
            service: String,
            key: String = "pincode",
            accessibility: Accessibility = .whenUnlockedThisDeviceOnly
        ) {
            self.service = service
            self.key = key
            self.accessibility = accessibility
        }

        public static func `default`(
            service: String? = nil,
            key: String = "pincode",
            accessibility: Accessibility = .whenUnlockedThisDeviceOnly
        ) -> Keychain {
            let resolvedService = service ?? Bundle.main.bundleIdentifier ?? "OrzAppLocker"
            return Keychain(service: resolvedService, key: key, accessibility: accessibility)
        }
    }

    public struct Strings {
        public var title: String
        public var subtitleLock: String
        public var subtitleSetPasscode: String
        public var subtitleChangePasscode: String
        public var subtitleDisablePasscode: String
        public var subtitleConfirmPasscode: String
        public var cancel: String
        public var delete: String

        public init(
            title: String,
            subtitleLock: String,
            subtitleSetPasscode: String,
            subtitleChangePasscode: String,
            subtitleDisablePasscode: String,
            subtitleConfirmPasscode: String,
            cancel: String,
            delete: String
        ) {
            self.title = title
            self.subtitleLock = subtitleLock
            self.subtitleSetPasscode = subtitleSetPasscode
            self.subtitleChangePasscode = subtitleChangePasscode
            self.subtitleDisablePasscode = subtitleDisablePasscode
            self.subtitleConfirmPasscode = subtitleConfirmPasscode
            self.cancel = cancel
            self.delete = delete
        }

        public static var zhCN: Strings {
            Strings(
                title: "密码保护",
                subtitleLock: "输入密码解锁",
                subtitleSetPasscode: "创建密码",
                subtitleChangePasscode: "输入旧密码",
                subtitleDisablePasscode: "输入密码以关闭",
                subtitleConfirmPasscode: "确认密码",
                cancel: "取消",
                delete: "删除"
            )
        }

        public static var enUS: Strings {
            Strings(
                title: "Passcode Lock",
                subtitleLock: "Enter your passcode",
                subtitleSetPasscode: "Create your passcode",
                subtitleChangePasscode: "Enter your current passcode",
                subtitleDisablePasscode: "Enter your passcode",
                subtitleConfirmPasscode: "Confirm your passcode",
                cancel: "Cancel",
                delete: "Delete"
            )
        }
    }

    public struct Theme {
        public var backgroundColor: UIColor
        public var titleColor: UIColor
        public var subtitleColor: UIColor
        public var indicatorFilledColor: UIColor
        public var indicatorEmptyColor: UIColor
        public var indicatorStrokeColor: UIColor
        public var keypadTextColor: UIColor
        public var keypadHighlightTextColor: UIColor
        public var keypadStrokeColor: UIColor
        public var photoStrokeColor: UIColor

        public init(
            backgroundColor: UIColor,
            titleColor: UIColor,
            subtitleColor: UIColor,
            indicatorFilledColor: UIColor,
            indicatorEmptyColor: UIColor,
            indicatorStrokeColor: UIColor,
            keypadTextColor: UIColor,
            keypadHighlightTextColor: UIColor,
            keypadStrokeColor: UIColor,
            photoStrokeColor: UIColor
        ) {
            self.backgroundColor = backgroundColor
            self.titleColor = titleColor
            self.subtitleColor = subtitleColor
            self.indicatorFilledColor = indicatorFilledColor
            self.indicatorEmptyColor = indicatorEmptyColor
            self.indicatorStrokeColor = indicatorStrokeColor
            self.keypadTextColor = keypadTextColor
            self.keypadHighlightTextColor = keypadHighlightTextColor
            self.keypadStrokeColor = keypadStrokeColor
            self.photoStrokeColor = photoStrokeColor
        }

        public static var dark: Theme {
            Theme(
                backgroundColor: .black,
                titleColor: .white,
                subtitleColor: .lightGray,
                indicatorFilledColor: .white,
                indicatorEmptyColor: .clear,
                indicatorStrokeColor: .white,
                keypadTextColor: .white,
                keypadHighlightTextColor: .systemGreen,
                keypadStrokeColor: .white,
                photoStrokeColor: .white
            )
        }

        /// 跟随系统亮暗模式的自适应配色。
        ///
        /// 全部使用语义色：系统切换亮暗、提高对比度、着色外观时都会自动跟随，
        /// 且不需要重建锁屏界面。
        public static var adaptive: Theme {
            Theme(
                backgroundColor: .systemBackground,
                titleColor: .label,
                subtitleColor: .secondaryLabel,
                indicatorFilledColor: .label,
                indicatorEmptyColor: .clear,
                indicatorStrokeColor: .label,
                keypadTextColor: .label,
                keypadHighlightTextColor: .systemGreen,
                keypadStrokeColor: .label,
                photoStrokeColor: .label
            )
        }

        public static var light: Theme {
            Theme(
                backgroundColor: .white,
                titleColor: .black,
                subtitleColor: .darkGray,
                indicatorFilledColor: .black,
                indicatorEmptyColor: .clear,
                indicatorStrokeColor: .black,
                keypadTextColor: .black,
                keypadHighlightTextColor: .systemGreen,
                keypadStrokeColor: .black,
                photoStrokeColor: .black
            )
        }
    }

    public enum CancelVisibility {
        case automatic
        case hidden
        case visible
    }

    public struct Configuration {
        public var keychain: Keychain
        public var strings: Strings
        public var theme: Theme
        public var image: UIImage?
        public var cancelVisibility: CancelVisibility
        public var onResult: ((Result) -> Void)?
        public var onFailedAttempt: ((Action) -> Void)?

        public init(
            keychain: Keychain,
            strings: Strings,
            theme: Theme,
            image: UIImage? = nil,
            cancelVisibility: CancelVisibility = .automatic,
            onResult: ((Result) -> Void)? = nil,
            onFailedAttempt: ((Action) -> Void)? = nil
        ) {
            self.keychain = keychain
            self.strings = strings
            self.theme = theme
            self.image = image
            self.cancelVisibility = cancelVisibility
            self.onResult = onResult
            self.onFailedAttempt = onFailedAttempt
        }

        public static func `default`(
            service: String? = nil,
            strings: Strings = .zhCN,
            theme: Theme = .dark,
            image: UIImage? = nil,
            cancelVisibility: CancelVisibility = .automatic,
            onResult: ((Result) -> Void)? = nil,
            onFailedAttempt: ((Action) -> Void)? = nil
        ) -> Configuration {
            Configuration(
                keychain: .default(service: service),
                strings: strings,
                theme: theme,
                image: image,
                cancelVisibility: cancelVisibility,
                onResult: onResult,
                onFailedAttempt: onFailedAttempt
            )
        }
    }

    private static var configuration = Configuration.default()

    static func setConfiguration(_ configuration: Configuration) {
        self.configuration = configuration
    }

    static func show(_ action: Action, over viewController: UIViewController? = nil) {
        Presenter.present(action: action, configuration: configuration, over: viewController)
    }

    public static var chain: Chain { Chain() }
}

private enum Constants {
    static let nibName = "AppLocker"
    static let duration = 0.3
    static let maxPinLength = 4

    enum button: Int {
        case delete = 1000
        case cancel = 1001
    }
}

@objc(AppLocker)
final class AppLocker: UIViewController {
    @IBOutlet weak var photoImageView: PhotoImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submessageLabel: UILabel!
    @IBOutlet var pinIndicators: [Indicator]!
    @IBOutlet weak var cancelButton: UIButton!
    
    fileprivate var configuration: OrzAppLocker.Configuration!
    fileprivate var action: OrzAppLocker.Action = .lock
    fileprivate var mode: Mode = .validate
    fileprivate var valet: Valet!
    private var pin = ""
    private var reservedPin = ""
    private var isFirstCreationStep = true
    private var savedPin: String? {
        get {
            return try? valet.string(forKey: configuration.keychain.key)
        }
        set {
            guard let newValue = newValue else { return }
            try? valet.setString(newValue, forKey: configuration.keychain.key)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        observeUserInterfaceStyle()
    }

    /// 锁屏显示期间系统切换亮暗模式时，重新应用主题。
    ///
    /// 主题色可能是动态色，视图会自己重取色；但密码点、按键圆圈、头像描边是
    /// `draw` 里转 `cgColor` 画的，必须重绘才会按新 trait 解析。
    private func observeUserInterfaceStyle() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
                (viewController: AppLocker, _: UITraitCollection) in
                viewController.applyTheme()
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // iOS 17 起走 registerForTraitChanges，这里只作旧系统回退。
        if #unavailable(iOS 17.0),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyTheme()
        }
    }
    
    fileprivate enum Mode {
        case validate
        case change
        case disable
        case create
    }

    fileprivate func applyMode(_ mode: Mode, cancelHidden: Bool) {
        self.mode = mode
        switch mode {
        case .create:
            submessageLabel.text = configuration.strings.subtitleSetPasscode
            cancelButton.isHidden = cancelHidden
        case .change:
            submessageLabel.text = configuration.strings.subtitleChangePasscode
            cancelButton.isHidden = cancelHidden
        case .disable:
            submessageLabel.text = configuration.strings.subtitleDisablePasscode
            cancelButton.isHidden = cancelHidden
        case .validate:
            submessageLabel.text = configuration.strings.subtitleLock
            cancelButton.isHidden = true
            isFirstCreationStep = false
        }
    }
    
    private func precreateSettings() {
        applyMode(.create, cancelHidden: cancelButton.isHidden)
        clearView()
    }
    
    private func drawing(isNeedClear: Bool, tag: Int? = nil) {
        let results = pinIndicators.filter { $0.isNeedClear == isNeedClear }
        let pinView = isNeedClear ? results.last : results.first
        pinView?.isNeedClear = !isNeedClear
        
        UIView.animate(withDuration: Constants.duration, animations: {
            pinView?.backgroundColor = isNeedClear ? self.configuration.theme.indicatorEmptyColor : self.configuration.theme.indicatorFilledColor
        }) { _ in
            isNeedClear ? self.pin = String(self.pin.dropLast()) : self.pincodeChecker(tag ?? 0)
        }
    }
    
    private func pincodeChecker(_ pinNumber: Int) {
        if pin.count < Constants.maxPinLength {
            pin.append("\(pinNumber)")
            if pin.count == Constants.maxPinLength {
                switch mode {
                case .create:
                    createModeAction()
                case .change:
                    changeModeAction()
                case .disable:
                    deactiveModeAction()
                case .validate:
                    validateModeAction()
                }
            }
        }
    }
    
    private func createModeAction() {
        if isFirstCreationStep {
            isFirstCreationStep = false
            reservedPin = pin
            clearView()
            submessageLabel.text = configuration.strings.subtitleConfirmPasscode
        } else {
            confirmPin()
        }
    }
    
    private func changeModeAction() {
        if pin == savedPin {
            precreateSettings()
        } else {
            configuration.onFailedAttempt?(action)
            incorrectPinAnimation()
        }
    }
    
    private func deactiveModeAction() {
        if pin == savedPin {
            removePin()
        } else {
            configuration.onFailedAttempt?(action)
            incorrectPinAnimation()
        }
    }
    
    private func validateModeAction() {
        if pin == savedPin {
            dismiss(animated: true) {
                self.configuration.onResult?(.unlocked)
            }
        } else {
            configuration.onFailedAttempt?(action)
            incorrectPinAnimation()
        }
    }
    
    private func removePin() {
        try? valet.removeObject(forKey: configuration.keychain.key)
        dismiss(animated: true) {
            self.configuration.onResult?(.passcodeDisabled)
        }
    }
    
    private func confirmPin() {
        if pin == reservedPin {
            savedPin = pin
            dismiss(animated: true) {
                if self.action == .lock {
                    self.configuration.onResult?(.unlocked)
                } else {
                    self.configuration.onResult?(.passcodeSet)
                }
            }
        } else {
            configuration.onFailedAttempt?(action)
            incorrectPinAnimation()
        }
    }
    
    private func incorrectPinAnimation() {
        pinIndicators.forEach { view in
            view.shake(delegate: self)
            view.backgroundColor = configuration.theme.indicatorEmptyColor
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    fileprivate func clearView() {
        pin = ""
        pinIndicators.forEach { view in
            view.isNeedClear = false
            UIView.animate(withDuration: Constants.duration, animations: {
                view.backgroundColor = self.configuration.theme.indicatorEmptyColor
            })
        }
    }
    
    @IBAction func keyboardPressed(_ sender: UIButton) {
        switch sender.tag {
        case Constants.button.delete.rawValue:
            drawing(isNeedClear: true)
        case Constants.button.cancel.rawValue:
            clearView()
            dismiss(animated: true) {
                self.configuration.onResult?(.cancelled)
            }
        default:
            drawing(isNeedClear: false, tag: sender.tag)
        }
    }
    
    fileprivate func applyTheme() {
        let theme = configuration.theme
        view.backgroundColor = theme.backgroundColor
        messageLabel.textColor = theme.titleColor
        submessageLabel.textColor = theme.subtitleColor

        pinIndicators.forEach { $0.refreshStrokeColor(theme.indicatorStrokeColor) }
        photoImageView.refreshStrokeColor(theme.photoStrokeColor)
        allButtons(in: view).forEach { button in
            button.setTitleColor(theme.keypadTextColor, for: .normal)
            button.setTitleColor(theme.keypadHighlightTextColor, for: .highlighted)
            (button as? PinIndicator)?.refreshStrokeColor(theme.keypadStrokeColor)
        }
    }
    
    fileprivate func setupTexts() {
        messageLabel.text = configuration.strings.title
    }
    
    fileprivate func setupButtons() {
        if let cancel = view.viewWithTag(Constants.button.cancel.rawValue) as? UIButton {
            cancel.setTitle(configuration.strings.cancel, for: .normal)
        }
        if let delete = view.viewWithTag(Constants.button.delete.rawValue) as? UIButton {
            delete.setTitle(configuration.strings.delete, for: .normal)
        }
        let buttons = allButtons(in: view)
        buttons.forEach { button in
            button.setTitleColor(configuration.theme.keypadTextColor, for: .normal)
            button.setTitleColor(configuration.theme.keypadHighlightTextColor, for: .highlighted)
            button.setNeedsDisplay()
        }
    }
    
    private func allButtons(in view: UIView) -> [UIButton] {
        var result: [UIButton] = []
        for subview in view.subviews {
            if let button = subview as? UIButton {
                result.append(button)
            }
            if !subview.subviews.isEmpty {
                result.append(contentsOf: allButtons(in: subview))
            }
        }
        return result
    }
}

extension AppLocker: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        clearView()
    }
}

private enum Presenter {
    static func present(action: OrzAppLocker.Action, configuration: OrzAppLocker.Configuration, over viewController: UIViewController?) {
        let root = resolveRoot(from: viewController)
        guard let root,
              let identifier = Identifier(nonEmpty: configuration.keychain.service),
              let locker = Bundle.module.loadNibNamed(Constants.nibName, owner: nil, options: nil)?.first as? AppLocker
        else {
            return
        }
        if root.presentedViewController is AppLocker { return }

        let hasPin = hasSavedPin(keychain: configuration.keychain)
        let (mode, cancelHidden): (AppLocker.Mode, Bool) = resolveModeAndCancelHidden(
            action: action,
            hasPin: hasPin,
            configuration: configuration
        )

        locker.configuration = configuration
        locker.action = action
        locker.valet = Valet.valet(with: identifier, accessibility: configuration.keychain.accessibility)

        locker.loadViewIfNeeded()
        locker.applyTheme()
        locker.setupTexts()
        locker.setupButtons()

        if let image = configuration.image {
            locker.photoImageView.image = image
            locker.photoImageView.isHidden = false
        } else {
            locker.photoImageView.isHidden = true
        }
        locker.applyMode(mode, cancelHidden: cancelHidden)

        root.present(locker, animated: true, completion: nil)
    }

    private static func resolveRoot(from viewController: UIViewController?) -> UIViewController? {
        if let viewController { return viewController }
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } }
                .first?
                .rootViewController
        }
        return UIApplication.shared.keyWindow?.rootViewController
            ?? UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
    }

    private static func resolveModeAndCancelHidden(
        action: OrzAppLocker.Action,
        hasPin: Bool,
        configuration: OrzAppLocker.Configuration
    ) -> (AppLocker.Mode, Bool) {
        let mode: AppLocker.Mode
        switch action {
        case .lock:
            mode = hasPin ? .validate : .create
        case .setPasscode:
            mode = .create
        case .changePasscode:
            mode = .change
        case .disablePasscode:
            mode = .disable
        }

        if mode == .validate { return (mode, true) }

        let cancelHidden: Bool
        switch configuration.cancelVisibility {
        case .hidden:
            cancelHidden = true
        case .visible:
            cancelHidden = false
        case .automatic:
            cancelHidden = (action == .lock)
        }
        return (mode, cancelHidden)
    }

    private static func hasSavedPin(keychain: OrzAppLocker.Keychain) -> Bool {
        guard let identifier = Identifier(nonEmpty: keychain.service) else { return false }
        let valet = Valet.valet(with: identifier, accessibility: keychain.accessibility)
        let pin = try? valet.string(forKey: keychain.key)
        return pin?.isEmpty == false
    }
}
