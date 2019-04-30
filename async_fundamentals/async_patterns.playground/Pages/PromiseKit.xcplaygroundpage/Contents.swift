//: [Previous](@previous)

import Foundation
import PromiseKit

var str = "Hello, playground"

let pmk = PMKNamespacer.promise
let url = URL(string: "https:/google.com")!
let urlRequest = URLRequest(url: url)
let promise = URLSession.shared.dataTask(pmk, with: urlRequest)
promise.pipe { (result) in
    switch result {
    case .fulfilled(let data):
        print(data.response.description)
    case .rejected(let error):
        print(error)
    }
}
