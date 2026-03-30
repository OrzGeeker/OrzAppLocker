import UIKit

@objc(Indicator)
final class Indicator: UIView {
    static var strokeColor: UIColor = .label
    var isNeedClear = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect, strokeColor: Self.strokeColor)
    }
}

@objc(PinIndicator)
final class PinIndicator: UIButton {
    static var strokeColor: UIColor = .label
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect, strokeColor: Self.strokeColor)
    }
}

@objc(PhotoImageView)
final class PhotoImageView: UIImageView {
    static var strokeColor: UIColor = .label
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect, strokeColor: Self.strokeColor)
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
