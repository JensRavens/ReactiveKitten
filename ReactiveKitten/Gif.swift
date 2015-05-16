import Foundation

public struct Gif {
    let id: String
    let caption: String?
    let link: NSURL?
//    let width: Int
//    let height: Int
    let url: NSURL
    
    public static func parse(dict: [String: AnyObject]) -> Gif? {
        if let id = dict["id"] as? String,
            caption = dict["caption"] as? String?,
            link_string = dict["embed_url"] as? String,
            link = NSURL(string: link_string),
            image = dict["images"]?["downsized"] as? [String: AnyObject],
//            width = image["width"] as? Int,
//            height = image["height"] as? Int,
            url_string = image["url"] as? String,
            url = NSURL(string: url_string)
        {
            return Gif(id: id, caption: caption, link: link, url: url)
        } else {
            return nil
        }
    }
}
