class MyCustomView: UIView, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizer()
    }

    private func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
    }

    @objc override func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        print("Tap detected!")
    }

    // 实现 UIGestureRecognizerDelegate 方法
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIView {
    func addGestureRecognizerWithDelegate() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        self.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        print("Tap detected!")
    }
}
