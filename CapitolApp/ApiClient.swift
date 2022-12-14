import Foundation

typealias ApiResult<T: Codable> = Result<T, ApiError>

enum ApiError: Error {
    case unspecificError(_ error: Error)
    case responseError(_ response: URLResponse?)
    case statusCodeError(_ response: HTTPURLResponse)
    case unparseableDataError(_ data: Data?)
}

class ApiClient {
    func loadUStates(completion: @escaping (ApiResult<StateModel>) -> ()) {
        let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")!)
        jsonRequest(request, completion)
    }
}

extension ApiClient {
    private func jsonRequest<T: Codable>(_ request: URLRequest, _ completion: @escaping (ApiResult<T>) -> ()) {
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(ApiResult.failure(ApiError.unspecificError(error)))
                    return
                }
                
                guard let response = response, let httpResponse = response as? HTTPURLResponse else {
                    completion(ApiResult.failure(ApiError.responseError(response)))
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    completion(ApiResult.failure(ApiError.statusCodeError(httpResponse)))
                    return
                }
                
                let decoder = JSONDecoder()
                guard let data = data, let parsed = try? decoder.decode(T.self, from: data) else {
                    completion(ApiResult.failure(ApiError.unparseableDataError(data)))
                    return
                }
                
                completion(ApiResult.success(parsed))
            }
        }).resume()
    }
}
