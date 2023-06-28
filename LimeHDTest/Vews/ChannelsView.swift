import UIKit

final class ChannelsView: UICollectionViewCell {
    
    static var cellId = "ChannelsView"
    
    private let storageService = StorageService.shared
    
    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                collectionView.isHidden = StorageService.shared.favoritesId.isEmpty
                emptyLabel.isHidden = !StorageService.shared.favoritesId.isEmpty
            }
        }
    }
    
    private var channels: [Channel] {
        didSet {
            collectionView.reloadData()
        }
    }
    private lazy var favoriteChanels = channels.filter { storageService.favoritesId.contains($0.id) }

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет избранных каналов"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.15, alpha: 1)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ChannelCell.self, forCellWithReuseIdentifier: ChannelCell.cellId)
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        return cv
    }()
    
    override init(frame: CGRect) {
        self.channels = []
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.15, alpha: 1)
        setupViews()
        setupConstarints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addToFavorites(sender: Button) {
        let id = sender.tag
        if storageService.favoritesId.contains(id)  {
            sender.isSelected = false
            storageService.delete(id)
        } else {
            sender.isSelected = true
            storageService.add(id)
        }
        favoriteChanels = channels.filter { storageService.favoritesId.contains($0.id) }
        if let indexPath = sender.indexPath, isFavorite { collectionView.deleteItems(at: [indexPath]) }
    }
    
    func setupChanels(_ channels: [Channel]) {
        self.channels = channels
    }
    
    private func setupViews() {
        addSubview(emptyLabel)
        addSubview(collectionView)
    }
    
    private func setupConstarints() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: emptyLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: emptyLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            
            NSLayoutConstraint.init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: collectionView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: collectionView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
        ])
    }
}

extension ChannelsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFavorite ? favoriteChanels.count : channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChannelCell.cellId, for: indexPath) as! ChannelCell
        isFavorite ? cell.setupCell(whithChannel: favoriteChanels[indexPath.row]) : cell.setupCell(whithChannel: channels[indexPath.row])
        guard let id = cell.id else { return cell }
        cell.starButton.isSelected = storageService.favoritesId.contains(id)
        cell.starButton.tag = id
        cell.starButton.indexPath = indexPath
        cell.starButton.addTarget(self, action: #selector(addToFavorites(sender:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 76)
    }
}
