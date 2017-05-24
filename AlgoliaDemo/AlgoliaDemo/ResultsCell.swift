import UIKit
import InstantSearchCore

class ResultsCell: UITableViewCell {
    @IBOutlet weak var merchantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var yelpLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var restaurantLabel: UILabel!
    static let placeholder = UIImage(named: "placeholder")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var item: Record? {
        didSet {
            //titleLabel.highlightedTextColor = movie?.title_highlighted
            if let url = item?.merchant_logo {
                merchantImageView.setImageWith(url, placeholderImage: ResultsCell.placeholder)
            } else {
                merchantImageView.cancelImageDownloadTask()
                merchantImageView.image = ResultsCell.placeholder
            }
        }
    }
}



extension UILabel {
    var highlightedText: String? {
        get {
            return attributedText?.string
        }
        set {
            let color = highlightedTextColor ?? self.tintColor ?? UIColor.blue
            attributedText = newValue == nil ? nil : Highlighter(highlightAttrs: [NSForegroundColorAttributeName: color]).render(text: newValue!)
        }
    }
}

