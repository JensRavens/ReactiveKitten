import UIKit
import Interstellar

var TextSignalHandle: UInt8 = 0
var TypingSignalHandle: UInt8 = 0
extension UISearchBar: UISearchBarDelegate {
    public var textSignal: Signal<String> {
        let signal: Signal<String>
        if let handle = objc_getAssociatedObject(self, &TextSignalHandle) as? Signal<String> {
            signal = handle
        } else {
            signal = Signal("")
            delegate = self
            objc_setAssociatedObject(self, &TextSignalHandle, signal, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
        return signal
    }
    
    public var typingSignal: Signal<String> {
        let signal: Signal<String>
        if let handle = objc_getAssociatedObject(self, &TypingSignalHandle) as? Signal<String> {
            signal = handle
        } else {
            signal = Signal("")
            delegate = self
            objc_setAssociatedObject(self, &TypingSignalHandle, signal, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
        return signal
    }
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            typingSignal.update(.Success(Box(self.text)))
        } else {
            typingSignal.update(.Error(NSError(domain: "User", code: 404, userInfo: nil)))
        }
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resignFirstResponder()
    }
    
    public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        setShowsCancelButton(false, animated: true)
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        resignFirstResponder()
        textSignal.update(.Success(Box(text)))
    }
}
