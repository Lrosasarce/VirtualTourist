//
//  VRTClient.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 15/11/21.
//

import Foundation

class VRTClient {
    
    static let shared = VRTClient()
    static let apiKey = "31dc2be66bf29d9fa64e32b2b9ad3112"
    static let secret = "87faffa78c97284c"
    private let logEnabled = true
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        static let apiKeyParam = "?api_key=\(VRTClient.apiKey)"
        static let jsonFormat = "&format=json&nojsoncallback=1"
        
        case photosByLocation(latitude: Double, longitude: Double)
        case photoResoruce(server: String, id: String, size: String, secret: String)
        
        var stringValue: String {
            switch self {
            case .photosByLocation(let latitude, let longitude):
                return Endpoints.base + Endpoints.apiKeyParam + Endpoints.jsonFormat + "&lat=\(latitude)&lon=\(longitude)&method=flickr.photos.search&per_page=10"
                
            case .photoResoruce(let server, let id, let size, let secret):
                return "https://live.staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    private func showLog(description: String, data: Data) {
        if logEnabled {
            print("============================")
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print(description + "\n" + responseString)
            print("============================")
        }
    }
    
    @discardableResult func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let newData = data
            let decoder = JSONDecoder()
            self.showLog(description: "Response: \(url.absoluteString)", data: newData)
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(VRTResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    private func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let newData = data
            
            self.showLog(description: "Response: \(url.absoluteString)",data: newData)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(VRTResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func fetchPhotosByCoordinate(latitude: Double, longitude: Double, completion: @escaping(PhotoResult?, Error?) -> Void) {
        
        VRTClient.shared.taskForGETRequest(url: VRTClient.Endpoints.photosByLocation(latitude: latitude, longitude: longitude).url, responseType: PhotoResponse.self) { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(response?.photos, nil)
        }
        
    }
    
    
    class func downloadPhotoImage(server: String, id: String, size: String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.photoResoruce(server: server, id: id, size: size, secret: secret).url) { data, response, error in
            DispatchQueue.main.async {
                print("ImageUrl: \(response?.url?.absoluteString ?? "")")
                completion(data, error)
            }
        }
        task.resume()
    }
    
    /*
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getFavorites(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getFavorites.url, responseType: MovieResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { response, error in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body) { response, error in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void) {
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionId = response.sessionId
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        let body = LogoutRequest(sessionId: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    class func search(query: String, completion: @escaping ([Movie], Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func markWatchlist(movieId: Int, watchlist: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkWatchlist(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
        taskForPOSTRequest(url: Endpoints.markWatchlist.url, responseType: TMDBResponse.self, body: body) { response, error in
            if let response = response {
                // separate codes are used for posting, deleting, and updating a response
                // all are considered "successful"
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    class func markFavorite(movieId: Int, favorite: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkFavorite(mediaType: "movie", mediaId: movieId, favorite: favorite)
        taskForPOSTRequest(url: Endpoints.markFavorite.url, responseType: TMDBResponse.self, body: body) { response, error in
            if let response = response {
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    */
    
//    class func downloadPosterImage(path: String, completion: @escaping (Data?, Error?) -> Void) {
//        let task = URLSession.shared.dataTask(with: Endpoints.posterImage(path).url) { data, response, error in
//            DispatchQueue.main.async {
//                completion(data, error)
//            }
//        }
//        task.resume()
//    }
    
}
