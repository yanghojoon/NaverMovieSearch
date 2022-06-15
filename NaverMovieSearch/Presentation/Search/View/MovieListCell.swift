import UIKit

protocol MovieListCellDelegate: AnyObject {
    
    func starButtonDidTap(at cell: MovieListCell, isSelected: Bool)
    
}

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
    private let starButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemGray
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    private var item: CellItem!
    private var starButtonTapped = false
    weak var delegate: MovieListCellDelegate!
    
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
        starButton.imageView?.image = nil
    }
    
    // MARK: - Methods
    func apply(item: CellItem) {
        self.item = item
        if item.movie.image == "" {
            thumnailImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        } else {
            thumnailImageView.loadCachedImage(of: item.movie.image)
        }
        titleLabel.text = item.movie.title.replaceWord
        directorLabel.text = "감독: \(item.movie.director.replaceWord)"
        actorsLabel.text = "출연: \(item.movie.actor.replaceWord)"
        userRatingLabel.text = "평점: \(item.movie.userRating.replaceWord)"
        
        print((item.movie.title, item.isSelected))
        if item.isSelected {
            starButton.tintColor = .systemYellow
        } else {
            starButton.tintColor = .systemGray
        }
    }
    
    func makeMovieItem() -> Movie {
        let movie = Movie(
            title: item.movie.title,
            link: item.movie.link,
            image: item.movie.image,
            director: item.movie.director,
            actor: item.movie.actor,
            userRating: item.movie.userRating
        )
        
        return movie
    }
    
    private func configureUI() {
        self.backgroundColor = .white
        self.addSubview(containerStackView)
        starButton.addTarget(self, action: #selector(tapStarButton), for: .touchUpInside)
        
        containerStackView.addArrangedSubview(thumnailImageView)
        containerStackView.addArrangedSubview(descriptionStackView)
        containerStackView.addArrangedSubview(starButton)
        
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
    
    @objc
    private func tapStarButton() {
        if starButton.tintColor == .systemGray {
            starButtonTapped = true
            starButton.tintColor = .systemYellow
            item.isSelected = true
            delegate.starButtonDidTap(at: self, isSelected: starButtonTapped)
        } else {
            starButtonTapped = false
            starButton.tintColor = .systemGray
            item.isSelected = false
            delegate.starButtonDidTap(at: self, isSelected: starButtonTapped)
        }
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
