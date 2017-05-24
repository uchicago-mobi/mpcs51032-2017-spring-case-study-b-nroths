import AlgoliaSearch
import InstantSearchCore
import Foundation


struct Record {
    private let json: JSONObject
    let renderer = Highlighter(highlightAttrs: [
        NSForegroundColorAttributeName: UIColor.red,
        NSBackgroundColorAttributeName: UIColor.yellow,
    ])
    
    
    
    init(json: JSONObject) {
        self.json = json
        renderer.preTag = "<em>"
        renderer.postTag = "</em>"
    }
    
    var restaurant_name: String {
        return json["name"] as! String
    }
    
    var item_description: String? {
        return json["item_description"] as? String
    }
    
    var item_name: String? {
        return json["item_name"] as? String

    }
    
    var merchant_logo: URL? {
        guard let urlString = json["merchant_logo"] as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    var restaurant_name_highlighted: String? {
        return SearchResults.highlightResult(hit: json, path: "name")?.value
    }
    
    var item_name_highlighted: String? {
        return SearchResults.highlightResult(hit: json, path: "item_name")?.value
    }
    
    var item_description_highlighted: String? {
        return SearchResults.highlightResult(hit: json, path: "item_description")?.value
    }
    
    var yelp_rating: Int? {
        return json["yelp_rating"] as? Int
    }
    
    var review_count: Int? {
        return json["review_count"] as? Int
    }
}
