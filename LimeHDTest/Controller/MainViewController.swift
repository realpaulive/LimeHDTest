import UIKit

final class MainViewController: UIViewController {
    
    private var channels: [Channel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    private var networkService = NetworkService()
    
    private lazy var statusBarBack: UIView = {
        let sbb = UIView()
        sbb.translatesAutoresizingMaskIntoConstraints = false
        sbb.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1)
        return sbb
    }()
    
    private lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.delegate = self
        mb.translatesAutoresizingMaskIntoConstraints = false
        return mb
    }()
    
    private lazy var seachBar: UISearchBar = {
        let sb = UISearchBar()
        sb.searchBarStyle = UISearchBar.Style.default
        sb.placeholder = "Напишите название телеканала"
        sb.sizeToFit()
        sb.isTranslucent = false
        sb.backgroundImage = UIImage()
        sb.delegate = self
        return sb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ChannelsView.self, forCellWithReuseIdentifier: ChannelsView.cellId)
        cv.dataSource = self
        cv.delegate = self
        cv.bounces = false
        return cv
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        view.backgroundColor = .black
        navigationItem.titleView = seachBar
        fetchChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationAppearence()
    }
    
    private func setupViews() {
        view.addSubview(statusBarBack)
        view.addSubview(collectionView)
        view.addSubview(menuBar)
    }
    
    private func setupConstraints() {
        //        navigationController?.hidesBarsOnSwipe = true
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: menuBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: menuBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: menuBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: menuBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: statusBarBack, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: statusBarBack, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44 + 60),
            
            NSLayoutConstraint(item: statusBarBack, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: statusBarBack, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: menuBar, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }
    
    func fetchChannels() {
        guard let url = URL(string: "http://limehd.online/playlist/channels.json") else { return }
        networkService.fetchChannels(url: url) { [weak self] result in
            switch result {
            case .success(let channels):
                DispatchQueue.main.async {
                    self?.channels = channels
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    
}

extension MainViewController {
    private func setNavigationAppearence() {
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let row = Int(targetContentOffset.pointee.x / collectionView.frame.width)
        let indexPath = IndexPath(row: row, section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        menuBar.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChannelsView.cellId, for: indexPath) as! ChannelsView
        cell.setupChanels(self.channels)
        if indexPath.row == 1 { cell.isFavorite = true }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension MainViewController: MenuBarDelegate {
    func scrollToIndexItem(_ index: Int) {
        collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(index), y: 0), animated: true)
        collectionView.reloadData()
    }
}
