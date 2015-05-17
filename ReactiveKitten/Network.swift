import Foundation
import Interstellar

public final class Network {
    let baseURL = "http://api.giphy.com/v1/"
    let session = NSURLSession.sharedSession()
    
    public func search()->(term: String, completion: Result<[Gif]>->Void)->Void {
        return searchPath |> request |> parseJSON |> processArray |> parseGifs
    }
    
    private func request(path: String, completion: Result<NSData>->Void) {
        let url = NSURL(string: baseURL.stringByAppendingString(path))!
        let request = NSURLRequest(URL: url)
        session.dataTaskWithRequest(request){ data, response, error in
            if error != nil {
                completion(.Error(error))
            } else if let response = response as? NSHTTPURLResponse {
                if response.statusCode >= 200 && response.statusCode < 300 {
                    completion(.Success(Box(data)))
                } else {
                    completion(.Error(NSError(domain: "Networking", code: response.statusCode, userInfo: nil)))
                }
            } else {
                completion(.Error(NSError(domain: "Networking", code: 500, userInfo: nil)))
            }
        }.resume()
    }
    
    private func searchPath(term: String) -> Result<String> {
        return .Success(Box("gifs/search?q=\(term)&api_key=dc6zaTOxFJmzC"))
    }
    
    private func parseGifs(array: [[String: AnyObject]]) -> Result<[Gif]> {
        let gifs = self.compact(array.map { a in
            Gif.parse(a)
            })
        return .Success(Box(gifs))
    }
    
    private func parseJSON(data: NSData)->Result<[String: AnyObject]> {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [String: AnyObject] {
            return .Success(Box(json))
        } else {
            return .Error(error!)
        }
    }
    
    private func processArray(data: [String: AnyObject]) -> Result<[[String: AnyObject]]> {
        if let array = data["data"] as? [[String: AnyObject]] {
            return .Success(Box(array))
        } else {
            return .Error(NSError(domain: "Parse", code: 400, userInfo: nil))
        }
    }
    
    private func compact<T>(array: [T?]) -> [T] {
        var flat: Array<T> = []
        for t in array {
            if let t = t {
                flat.append(t)
            }
        }
        return flat
    }
}