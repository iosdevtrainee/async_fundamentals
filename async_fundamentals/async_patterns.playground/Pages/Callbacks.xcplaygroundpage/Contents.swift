//: [Previous](@previous)

import Foundation
var str = "Hello, playground"

enum Result<Value> {
    case value(Value)
    case error(Error)
}

typealias Handler = (Result<Value> -> Void)
func callback(urlString: String, callback: @escaping Handler) {
    URLSession.shared.dataTask(with: "https://google.com") { (data, response, error) in
        if let error = error {
            callback(.error(error))
        } else if let data = data {
            callback(.value(data))
        }
    }

}

