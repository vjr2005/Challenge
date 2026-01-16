import SwiftUI

struct CharacterView: View {
    let viewModel: CharacterViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                ProgressView()
            case .loaded(let character):
                characterContent(character)
            case .error:
                errorContent
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Atrás") {
                    viewModel.didTapOnBack()
                }
            }
        }
    }

    private func characterContent(_ character: Character) -> some View {
        VStack(spacing: 16) {
            if let imageURL = character.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            }

            Text(character.name)
                .font(.title)

            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Status", value: character.status.rawValue)
                LabeledContent("Species", value: character.species)
                LabeledContent("Gender", value: character.gender)
                LabeledContent("Origin", value: character.origin.name)
                LabeledContent("Location", value: character.location.name)
            }
            .padding()
        }
    }

    private var errorContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.red)

            Text("Error loading character")

            Button("Retry") {
                Task {
                    await viewModel.load()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
