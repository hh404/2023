import UIKit

protocol DropdownSelectionCellDelegate: AnyObject {
    func didSelectValue(_ value: String, for cell: DropdownSelectionCell)
}

class DropdownSelectionCell: UITableViewCell {
    
    weak var delegate: DropdownSelectionCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▼", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dropdownButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            dropdownButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        dropdownButton.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dropdownButtonTapped() {
        // Notify delegate to show poplist
        delegate?.didSelectValue("Selected Value", for: self) // Example value
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}