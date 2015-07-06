import Foundation
import Interstellar

public final class Network {
    let baseURL = "http://api.giphy.com/v1/"
    let session = NSURLSession.sharedSession()
    
    public func search(term: String, completion: Result<[Gif]>->Void)->Void {
        Signal(term)
        .bind(searchPath)
        .bind(request)
        .bind(parseJSON)
        .bind(processArray)
        .bind(parseGifs)
        .subscribe { result in
            completion(result)
        }
    }
    
    private func request(path: String, completion: Result<NSData>->Void) {
        let url = NSURL(string: baseURL.stringByAppendingString(path))!
        let request = NSURLRequest(URL: url)
        session.dataTaskWithRequest(request){ data, response, error in
            if let error = error {
                completion(.Error(error))
            } else if let response = response as? NSHTTPURLResponse {
                if response.statusCode >= 200 && response.statusCode < 300 {
                    completion(.Success(data!))
                } else {
                    completion(.Error(NSError(domain: "Networking", code: response.statusCode, userInfo: nil)))
                }
            } else {
                completion(.Error(NSError(domain: "Networking", code: 500, userInfo: nil)))
            }
        }!.resume()
    }
    
    private func searchPath(term: String) -> Result<String> {
        return .Success("gifs/search?q=\(term)&api_key=dc6zaTOxFJmzC")
    }
    
    private func parseGifs(array: [[String: AnyObject]]) -> Result<[Gif]> {
        let gifs = compact(array.map { a in
            Gif.parse(a)
            })
        return .Success(gifs)
    }
    
    private func parseJSON(data: NSData)->Result<[String: AnyObject]> {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
                return .Success(json)
            } else {
                let error = NSError(domain: "return content is not a dictionary", code: 421, userInfo: nil)
                return .Error(error)
            }
        } catch let error as NSError {
            return .Error(error)
        }
    }
    
    private func processArray(data: [String: AnyObject]) -> Result<[[String: AnyObject]]> {
        if let array = data["data"] as? [[String: AnyObject]] {
            return .Success(array)
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