import SwiftUI
import Combine

enum OnboardingScreenState {
    case loading
    case loaded(Screen)
    case error(Error)
}

enum ButtonAction: String {
    case onboardingComplete
}

class OnboardingViewModel: ObservableObject {
    let screenRepository: ScreenRepositoryProtocol
    @Published var state: OnboardingScreenState = .loading
    @Binding var isOnboarding: Bool

    private var cancelBag = Set<AnyCancellable>()

    init(
        screenRepository: ScreenRepositoryProtocol,
        isOnboarding: Binding<Bool>
    ) {
        self.screenRepository = screenRepository
        self._isOnboarding = isOnboarding

        self.screenRepository.getOnboardingScreen()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        self?.state = .error(error)
                    }
                },
                receiveValue: { [weak self] screen in
                    self?.state = .loaded(screen)
                }
            )
            .store(in: &cancelBag)
    }

    func showAppMain() {
        self.isOnboarding = false
    }

    func buttonAction(screenId: Int, action: String) {
        if let action = ButtonAction(rawValue: action) {
            switch action {
            case .onboardingComplete:
                self.screenRepository.logConversion(screenId: screenId)
                self.showAppMain()
            }
        }
    }
}

struct OnboardingScreen: View {
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let screen):
            ScrollView {
                renderScreen(screen)
            }
        case .error:
            errorOnboardingView
        }
    }

    private func renderScreen(_ screen: Screen) -> some View {
        VStack(spacing: 30) {
            ForEach(screen.content.blocks) { block in
                switch block.data {
                case .button(let data):
                    Button(action: {
                        viewModel.buttonAction(screenId: screen.id, action: data.link)
                    }) {
                        Text(data.text)
                    }
                    .buttonStyle(.borderedProminent)
                case .header(let data):
                    Text(data.text)
                        .font(.largeTitle)
                        .bold()
                case .paragraph(let data):
                    Text(data.text)
                        .font(.body)
                case .list(let data):
                    ForEach(data.items, id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                            Text(item)
                                .font(.headline)
                                .bold()
                                .foregroundColor(.blue)
                        }
                    }
                case .image(let data):
                    AsyncImage(url: URL(string: data.url)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
    }

    private var errorOnboardingView: some View {
        VStack {
            Image("Logo")
                .cornerRadius(20)
            Text("OnBorder App")
                .font(.largeTitle)
                .bold()
            Button(action: viewModel.showAppMain) {
                Text("Lets Go →")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen(
            viewModel: .init(
                screenRepository: FakeScreenRepository(),
                isOnboarding: .constant(true)
            )
        )
    }
}
