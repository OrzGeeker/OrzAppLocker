import UIKit

/// 需要按主题描边的自绘视图。
///
/// 颜色是**每个视图自己的**，不是进程级共享状态：同一进程里多个锁屏、
/// 或者主题在运行期变化，都只影响自己。
protocol StrokeColorRenderable: AnyObject {
    var strokeColor: UIColor { get set }
    func refreshStrokeColor(_ color: UIColor)
}

extension StrokeColorRenderable where Self: UIView {
    /// 更新颜色并重绘。`draw` 里用的是 `strokeColor.cgColor`，
    /// 动态色只有在重新绘制时才会按当前 trait 解析，所以这里必须重绘。
    func refreshStrokeColor(_ color: UIColor) {
        strokeColor = color
        setNeedsDisplay()
    }
}

@objc(Indicator)
final class Indicator: UIView, StrokeColorRenderable {
    var strokeColor: UIColor = .label
    var isNeedClear = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect, strokeColor: strokeColor)
    }
}

@objc(PinIndicator)
final class PinIndicator: UIButton, StrokeColorRenderable {
    var strokeColor: UIColor = .label
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect, strokeColor: strokeColor)
    }
}

@objc(PhotoImageView)
final class PhotoImageView: UIImageView, StrokeColorRenderable {
    var strokeColor: UIColor = .label
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect, strokeColor: strokeColor)
    }
}

extension UIView {
    func drawCircle(_ rect:CGRect, strokeColor: UIColor) {
        layer.masksToBounds = true
        layer.cornerRadius = rect.width / 2.0
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let rect = CGRect(
            x: rect.origin.x + 0.5,
            y: rect.origin.y + 0.5,
            width: rect.width - 1,
            height: rect.height - 1
        )
        context.setLineWidth(1)
        context.setStrokeColor(strokeColor.cgColor)
        context.strokeEllipse(in: rect)
    }
    
    func shake(delegate: CAAnimationDelegate) {
        let animationKeyPath = "transform.translation.x"
        let shakeAnimation = "shake"
        let duration = 0.6
        let animation = CAKeyframeAnimation(keyPath: animationKeyPath)
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        animation.delegate = delegate
        layer.add(animation, forKey: shakeAnimation)
    }
}
