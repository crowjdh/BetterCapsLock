//
//  InputSourceManager.swift
//  CapsLockNoDelay
//
//  Created by Donghyun Jung on 2021/02/20.
//

import Cocoa
import Carbon

class InputSource {
  let tisInputSource: TISInputSource

  var id: String {
    return tisInputSource.id
  }

  var name: String {
    return tisInputSource.name
  }

  init(tisInputSource: TISInputSource) {
    self.tisInputSource = tisInputSource
  }

  func select() {
    TISSelectInputSource(tisInputSource)
  }

  static func fromName(name: String) -> InputSource? {
    return InputSource.sources.first(where: {$0.name == name})
  }
}

extension InputSource: Equatable {
  static func == (lhs: InputSource, rhs: InputSource) -> Bool {
    return lhs.id == rhs.id
  }
}

extension InputSource {
  static var sources: [InputSource] {
    let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
    let inputSourceList = inputSourceNSArray as! [TISInputSource]

    return inputSourceList
      .filter {
        $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable
    }.map {
      InputSource(tisInputSource: $0)
    }
  }
}

extension TISInputSource {
  enum Category {
    static var keyboardInputSource: String {
      return kTISCategoryKeyboardInputSource as String
    }
  }

  private func getProperty(_ key: CFString) -> AnyObject? {
    let cfType = TISGetInputSourceProperty(self, key)
    if (cfType != nil) {
      return Unmanaged<AnyObject>.fromOpaque(cfType!).takeUnretainedValue()
    } else {
      return nil
    }
  }

  var id: String {
    return getProperty(kTISPropertyInputSourceID) as! String
  }

  var name: String {
    return getProperty(kTISPropertyLocalizedName) as! String
  }

  var category: String {
    return getProperty(kTISPropertyInputSourceCategory) as! String
  }

  var isSelectable: Bool {
    return getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool
  }

  var sourceLanguages: [String] {
    return getProperty(kTISPropertyInputSourceLanguages) as! [String]
  }
}

extension IOHIDServiceClient {
    
    static func getValue(key: String) -> CFTypeRef? {
        var value: CFTypeRef?
        withKeyboardServiceClient { keyboardServiceClient in
            value = IOHIDServiceClientCopyProperty(keyboardServiceClient, key as CFString)
        }
        
        return value
    }
    
    static func setValue(key: String, value: Any) {
        let cfKey = key as CFString
        let cfValue = value as CFTypeRef
        
        withKeyboardServiceClient { keyboardServiceClient in
            IOHIDServiceClientSetProperty(keyboardServiceClient, cfKey, cfValue)
        }
    }
    
    static func withKeyboardServiceClient(action: (IOHIDServiceClient) -> ()) {
        let eventSystemClient = IOHIDEventSystemClientCreateSimpleClient(kCFAllocatorDefault)
        
        guard let services = IOHIDEventSystemClientCopyServices(eventSystemClient) else {
            return
        }
        
        for i in 0..<CFArrayGetCount(services) {
            let rawServiceClient = CFArrayGetValueAtIndex(services, i)
            let serviceClient = unsafeBitCast(rawServiceClient, to: IOHIDServiceClient.self)
            let product = IOHIDServiceClientCopyProperty(serviceClient, "Product" as CFString) as? String
            let conforms = IOHIDServiceClientConformsTo(serviceClient, 0x01, 0x06)
            if let product = product, product.contains("Internal Keyboard"), conforms == 1 {
                action(serviceClient)
                return
            }
        }
    }
}
