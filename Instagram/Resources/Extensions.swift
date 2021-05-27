//
//  Extensions.swift
//  Instagram
//
//  Created by Anh Dinh on 4/14/21.
//

import Foundation
import UIKit

extension UIView {
    var top: CGFloat{
        frame.origin.y
    }
    
    var bottom: CGFloat{
        frame.origin.y + height
    }
    
    var left: CGFloat{
        frame.origin.x
    }
    
    var right: CGFloat{
        frame.origin.x + width
    }
    
    var width: CGFloat{
        frame.size.width
    }
    
    var height: CGFloat{
        frame.size.height
    }
}

extension Decodable {
    // convert dictionary to an Object I guess
    init?(with dictionary: [String: Any]){
        guard  let data = try? JSONSerialization.data(withJSONObject: dictionary,
                                                      options: .prettyPrinted)
        else {
            return nil
        }
        
        guard let result = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        
        self = result
    }
}

extension Encodable {
    // func return dictionary [String: something]
    // something ở đây có thể là caption, id, username, email
    // vậy có nghĩa struct của object phải là dạng <variable>: String để xài đươc thằng asDictionary này
    func asDictionary() -> [String: Any]?{
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data,
        options: .allowFragments) as? [String: Any]
        return json
    }
    
}

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    static func date(from date: Date) -> String? {
        let formatter = DateFormatter.formatter
        let string = formatter.string(from: date)
        return string
    }
}
