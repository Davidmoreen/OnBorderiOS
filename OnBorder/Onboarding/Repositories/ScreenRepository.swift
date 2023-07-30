import Foundation
import Combine

protocol ScreenRepositoryProtocol {
    func getOnboardingScreen() -> AnyPublisher<Screen, Error>
    func logConversion(screenId: Int)
}

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}

class ScreenRepository: ScreenRepositoryProtocol {
    private let endpointUrl = "http://localhost:3000"
    
    func getOnboardingScreen() -> AnyPublisher<Screen, Error> {
        let url = buildUrl(path: "/onboarding_screen")
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Screen.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func logConversion(screenId: Int) {
        let request = buildRequest(
            path: "/screens/\(screenId)/log_conversion",
            method: .post
        )
        URLSession.shared.dataTask(with: request).resume()
    }

    private func buildUrl(path: String) -> URL {
        var urlComponents = URLComponents(string: endpointUrl)!
        urlComponents.path = path
        return urlComponents.url!
    }

    private func buildRequest(
        path: String,
        method: RequestMethod
    ) -> URLRequest {
        let url = buildUrl(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        return request
    }
}

class FakeScreenRepository: ScreenRepositoryProtocol {
    func getOnboardingScreen() -> AnyPublisher<Screen, Error> {
        return Just(Screen(id: 1, name: "Test", content: ScreenContent(time: 1, blocks: [], version: "")))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func logConversion(screenId: Int) {
        // no op
    }
}
