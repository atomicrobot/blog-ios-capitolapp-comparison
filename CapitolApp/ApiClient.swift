import Foundation
import Combine

typealias ApiResult<T: Codable> = Result<T, ApiError>

enum ApiError: Error {
    case unspecificError(_ error: Error)
    case responseError(_ response: URLResponse?)
    case statusCodeError(_ response: HTTPURLResponse)
    case unparseableDataError(_ data: Data?)
}

class ApiClient {
    func loadUSStates() -> AnyPublisher<StateModel, Error> {
            let request =  URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")!
            let decoder = JSONDecoder()
            return URLSession.shared.dataTaskPublisher(for: request)
               .map { $0.data }
               .tryMap { try decoder.decode(StateModel.self, from: $0) }
               .mapError { return ApiError.unspecificError($0) }
               .eraseToAnyPublisher()
       }
}
