class MyCustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizer()
    }

    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self  // 设置委托为当前视图
        self.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        print("Tap detected in MyCustomView!")
    }

    // 实现 UIGestureRecognizerDelegate 方法
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 检查是否为特定视图，避免干扰其他自定义视图
        if self is MyCustomView {
            return false // 让自定义视图自己处理
        }
        return true
    }
}
