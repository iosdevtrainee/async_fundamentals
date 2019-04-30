//
//  ViewController.swift
//  async_fundamentals
//
//  Created by iosdevrookie on 3/12/19.
//  Copyright © 2019 iosdevrookie. All rights reserved.
//

import UIKit
import RxSwift
import PromiseKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Cold Observables

        let people = [Person(name:"John",age:12),
                      Person(name:"Sean",age:22),
                      Person(name:"Anthony",age:32),
                      Person(name:"Paulie",age:34),
                      Person(name:"Alice",age:2)]
        let observablePeople = Observable.from(people)
        observablePeople.filter { $0.age > 22}
            .subscribe { (observer) in
                switch observer {
                case .next(let element):
                    print(element)
                case .error(let error):
                    print(error)
                case .completed:
                    print("Done!!!")
                }
        }
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
    }


}

