import UIKit

class CustomTableViewCell: UITableViewCell {

    let label1 = UILabel()
    let label2 = UILabel()

    private var label1TopConstraint: NSLayoutConstraint!
    private var label2TopConstraintWithLabel1: NSLayoutConstraint!
    private var label2TopConstraintWithoutLabel1: NSLayoutConstraint!
    private var label2BottomConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(label1)
        contentView.addSubview(label2)
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up initial constraints but do not activate them
        label1TopConstraint = label1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        label2TopConstraintWithLabel1 = label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10)
        label2TopConstraintWithoutLabel1 = label2.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        label2BottomConstraint = label2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label2BottomConstraint
        ])
    }
    
    func configure(hasLabel1: Bool, text1: String?, text2: String) {
        if hasLabel1 {
            label1.text = text1
            label1.isHidden = false
            label2TopConstraintWithoutLabel1.isActive = false
            NSLayoutConstraint.activate([label1TopConstraint, label2TopConstraintWithLabel1])
        } else {
            label1.isHidden = true
            label2TopConstraintWithLabel1.isActive = false
            NSLayoutConstraint.activate([label2TopConstraintWithoutLabel1])
        }
        label2.text = text2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset any changes to the view hierarchy or properties
        label1.text = nil
        label2.text = nil
        label1.isHidden = false
        NSLayoutConstraint.deactivate([label1TopConstraint, label2TopConstraintWithLabel1, label2TopConstraintWithoutLabel1])
    }
}