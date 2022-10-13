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
        let request = URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")!
        jsonRequest(request, completion)
    }
}

extension ApiClient {
    private func jsonRequest<T: Codable>(_ request: URL, _ completion: @escaping (ApiResult<T>) -> ()) {
        Task {
            let decoder = JSONDecoder()
            do {
                let (data, _) = try await URLSession.shared.data(from: request)
                let capitalData = try decoder.decode(T.self , from: data)
                completion(ApiResult.success(capitalData))
            } catch {
                completion(ApiResult.failure(ApiError.unspecificError(error)))
            }
        }
    }
}
