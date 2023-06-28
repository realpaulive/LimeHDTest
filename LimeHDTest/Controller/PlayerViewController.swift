import AVFoundation
import AVKit

final class PlayerViewController: AVPlayerViewController {
    
    private var url: URL
    private let avPlayer = AVPlayer()
    

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVideoAsset()
    }
    
    private func setVideoAsset() {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredPeakBitRate = .greatestFiniteMagnitude
        avPlayer.replaceCurrentItem(with: playerItem)
        player = avPlayer
        entersFullScreenWhenPlaybackBegins = true
        player?.play()
    }
}
