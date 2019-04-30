import UIKit
import RxSwift

struct Person {
    public let name: String
    public let age: Int
}

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


let observablePersons = Observable.of(Person(name:"John",age:12),
                                     Person(name:"Sean",age:22),
                                     Person(name:"Anthony",age:32),
                                     Person(name:"Paulie",age:34),
                                     Person(name:"Alice",age:2))



observablePersons.filter{ $0.name == "John"  }
    .asSingle()
    .subscribe { (singleEvent: SingleEvent<Person>) in
        switch singleEvent {
        case .error(let error):
            print(error)
        case .success(let person):
            print(person)
        }
}

observablePersons
    .asSingle()
    .subscribe { (singleEvent: SingleEvent<Person>) in
        switch singleEvent {
        case .error(let error):
            print("\(error) Something")
        case .success(let person):
            print(person)
        }
}



