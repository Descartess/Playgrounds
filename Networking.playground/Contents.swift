//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum Result<Value> {
    case success(Value)
    case error(Error)
}

extension Result {
    func get() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .error(let error):
            throw error
        }
    }
}

extension Result where Value == Data {
    func decoded<T: Decodable> (using decoder: JSONDecoder = .init()) throws -> T {
        let data = try get()
        return try decoder.decode(T.self, from: data)
    }
}

let baseUrl = "https://swapi.co/api/"


enum Endpoints {
    case person(id: Int?)
    case planet(id: Int?)
    case vehicle(id: Int?)
    
    var rawString: String {
        switch self {
        case .person(let .some(id)):
            return "people/\(id)/"
        case .person(.none):
            return "people/"
        case .planet(let .some(id)):
            return "planets/\(id)/"
        case .planet(.none):
            return "planets/"
        case .vehicle(let .some(id)):
            return "starships/\(id)/"
        case .vehicle(.none):
            return "starships"
        }
    }
    
    var url: URL {
        guard
            let url =  URL(string: baseUrl + rawString)
        else { preconditionFailure("Invalid Url") }
        return url
    }
}

struct Person: Codable {
    var name: String
    var height: String
    var mass: String
    var gender: String
}

struct Planet: Codable {
    var name: String
    var climate: String
    var diameter: String
    var population: String
}

struct StarShips: Codable {
    var name: String
    var model: String
    var manufacturer: String
}

//:  Networking Approach 1.

typealias completionHandler = (Result<Data>) -> Void

protocol httpClient {
    func get(_ url: URL,completion: @escaping completionHandler)
    func post(_ urlRequest: URLRequest,body: Data, completion: @escaping completionHandler)
}

extension httpClient {
    func get(_ url: URL,completion: @escaping completionHandler) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.error(error))
            }
        }
        task.resume()
    }
    
    func post(_ urlRequest: URLRequest, body: Data, completion: @escaping completionHandler) {
        var request = urlRequest
        request.httpBody = body
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.error(error))
            }
        }
        task.resume()
    }
}

class AppClient: httpClient {

}

//: Making requests as follows

let client = AppClient()

client.get(Endpoints.person(id: 1).url) { result in
    do {
        let person = try result.decoded() as Person
        print(person)
    } catch let error {
        print(error)
    }
}


//: Networking Approach 2

struct Resources<T: Decodable> {
    var endpoint: Endpoints
}

extension Resources {
    func loadResources() {
        let task = URLSession.shared.dataTask(with: endpoint.url) { data, response, error in
            guard
                let data = data,
                let values = try? JSONDecoder().decode(T.self, from: data)
            else { return }
            print(values)
        }
        task.resume()
    }
}

let person:Resources<Person> = Resources(endpoint: Endpoints.person(id: 2))

person.loadResources()

