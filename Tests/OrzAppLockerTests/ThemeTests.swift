import XCTest
import UIKit
@testable import OrzAppLocker

final class ThemeTests: XCTestCase {
    private let light = UITraitCollection(userInterfaceStyle: .light)
    private let dark = UITraitCollection(userInterfaceStyle: .dark)

    /// 自适应主题必须真的随系统外观变化，否则锁屏会一直是创建时的那一套颜色。
    func testAdaptiveThemeFollowsUserInterfaceStyle() {
        let theme = OrzAppLocker.Theme.adaptive

        XCTAssertNotEqual(
            theme.backgroundColor.resolvedColor(with: light),
            theme.backgroundColor.resolvedColor(with: dark)
        )
        XCTAssertNotEqual(
            theme.titleColor.resolvedColor(with: light),
            theme.titleColor.resolvedColor(with: dark)
        )
        XCTAssertNotEqual(
            theme.indicatorStrokeColor.resolvedColor(with: light),
            theme.indicatorStrokeColor.resolvedColor(with: dark)
        )
        XCTAssertNotEqual(
            theme.keypadStrokeColor.resolvedColor(with: light),
            theme.keypadStrokeColor.resolvedColor(with: dark)
        )
    }

    /// 固定配色保持原样：`.dark` 在浅色系统下仍是深色，供需要强制配色的调用方使用。
    func testFixedThemesIgnoreUserInterfaceStyle() {
        let theme = OrzAppLocker.Theme.dark
        XCTAssertEqual(
            theme.backgroundColor.resolvedColor(with: light),
            theme.backgroundColor.resolvedColor(with: dark)
        )
    }

    /// 描边色是每个视图自己的状态，改了不能影响别的视图。
    func testStrokeColorIsPerView() {
        let first = Indicator()
        let second = Indicator()
        first.refreshStrokeColor(.red)

        XCTAssertEqual(first.strokeColor, UIColor.red)
        XCTAssertEqual(second.strokeColor, UIColor.label)
    }
}
