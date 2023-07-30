import SwiftUI

@main
struct OnBorderApp: App {
    let screenRepository = ScreenRepository()
    @State var isOnboarding: Bool = true

    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingScreen(viewModel: .init(
                    screenRepository: screenRepository,
                    isOnboarding: $isOnboarding
                ))
            } else {
                ContentView()
            }
        }
    }
}
