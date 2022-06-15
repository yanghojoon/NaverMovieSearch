import UIKit

class MovieListCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Design.containerStackViewVerticalInset,
            leading: Design.containerStackViewHorizontalInset,
            bottom: Design.containerStackViewVerticalInset,
            trailing: Design.containerStackViewHorizontalInset
        )
        stackView.spacing = Design.containerStackViewSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    private let thumnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Design.titleLabelFont
        return label
    }()
    private let directorLabel: UILabel = {
        let label = UILabel()
        label.font = Design.descriptionContentFont
        return label
    }()
    private let actorsLabel: UILabel = {
        let label = UILabel()
        label.font = Design.descriptionContentFont
        return label
    }()
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Design.descriptionContentFont
        return label
    }()
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemGray
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        thumnailImageView.image = nil
        titleLabel.text = nil
        directorLabel.text = nil
        actorsLabel.text = nil
        userRatingLabel.text = nil
        favoriteButton.imageView?.image = nil
    }
    
    // MARK: - Methods
    func apply(imageURL: String, title: String, director: String, actors: String, userRating: String) {
        if imageURL == "" {
            thumnailImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        } else {
            thumnailImageView.loadCachedImage(of: imageURL)
        }
        titleLabel.text = title.replaceWord
        directorLabel.text = "감독: \(director.replaceWord)"
        actorsLabel.text = "출연: \(actors.replaceWord)"
        userRatingLabel.text = "평점: \(userRating.replaceWord)"
    }
    
    private func configureUI() {
        self.backgroundColor = .white
        self.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(thumnailImageView)
        containerStackView.addArrangedSubview(descriptionStackView)
        containerStackView.addArrangedSubview(favoriteButton)
        
        descriptionStackView.addArrangedSubview(titleLabel)
        descriptionStackView.addArrangedSubview(directorLabel)
        descriptionStackView.addArrangedSubview(actorsLabel)
        descriptionStackView.addArrangedSubview(userRatingLabel)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            thumnailImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.15),
            thumnailImageView.heightAnchor.constraint(equalTo: descriptionStackView.heightAnchor)
        ])
    }
    
}

extension MovieListCell {
    
    private enum Design {
        
        static let containerStackViewHorizontalInset: CGFloat = 10
        static let containerStackViewVerticalInset: CGFloat = 15
        static let containerStackViewSpacing: CGFloat = 10
        
        static let titleLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
        static let descriptionContentFont: UIFont = .preferredFont(forTextStyle: .body)
        
    }
}
