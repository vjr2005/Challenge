import ChallengeCore
import SwiftUI

struct CharacterDetailView<ViewModel: CharacterDetailViewModelContract>: View {
	@State private var viewModel: ViewModel

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		content
			.task {
				await viewModel.load()
			}
			.background(Color(.systemGroupedBackground))
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					backButton
				}
			}
			.accessibilityIdentifier(AccessibilityIdentifier.view)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.state {
		case .idle:
			Color.clear
		case .loading:
			loadingView
		case .loaded(let character):
			characterContent(character)
		case .error:
			errorView
		}
	}
}

// MARK: - Subviews

private extension CharacterDetailView {
	var backButton: some View {
		Button {
			viewModel.didTapOnBack()
		} label: {
			HStack(spacing: 4) {
				Image(systemName: "chevron.left")
					.font(.system(.body, weight: .semibold))
				Text("Back")
					.font(.system(.body, design: .rounded))
			}
		}
		.accessibilityIdentifier(AccessibilityIdentifier.backButton)
	}

	var loadingView: some View {
		VStack(spacing: 16) {
			ProgressView()
				.scaleEffect(1.5)
			Text("Loading character...")
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	func characterContent(_ character: Character) -> some View {
		ScrollView {
			VStack(spacing: 20) {
				headerSection(character)
				infoCard(character)
				locationCard(character)
			}
			.padding(.horizontal)
			.padding(.top, 8)
			.padding(.bottom, 24)
		}
	}

	func headerSection(_ character: Character) -> some View {
		VStack(spacing: 16) {
			characterImage(character)
			nameAndStatus(character)
		}
		.padding(20)
		.frame(maxWidth: .infinity)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
	}

	func characterImage(_ character: Character) -> some View {
		CachedAsyncImage(url: character.imageURL) { image in
			image
				.resizable()
				.scaledToFill()
		} placeholder: {
			ProgressView()
		}
		.frame(width: 150, height: 150)
		.clipShape(RoundedRectangle(cornerRadius: 20))
		.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
	}

	func nameAndStatus(_ character: Character) -> some View {
		VStack(spacing: 8) {
			Text(character.name)
				.font(.system(.title, design: .rounded, weight: .bold))
				.foregroundStyle(.primary)
				.multilineTextAlignment(.center)

			HStack(spacing: 8) {
				Circle()
					.fill(statusColor(for: character.status))
					.frame(width: 10, height: 10)

				Text(character.status.rawValue)
					.font(.system(.subheadline, design: .rounded, weight: .medium))
					.foregroundStyle(.secondary)

				Text("•")
					.foregroundStyle(.tertiary)

				Text(character.species)
					.font(.system(.subheadline, design: .serif))
					.foregroundStyle(.secondary)
					.italic()
			}
		}
	}

	func infoCard(_ character: Character) -> some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Information")
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.primary)

			VStack(spacing: 12) {
				infoRow(icon: "person.fill", label: "Gender", value: character.gender)
				Divider()
				infoRow(icon: "leaf.fill", label: "Species", value: character.species)
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
	}

	func locationCard(_ character: Character) -> some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Locations")
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.primary)

			VStack(spacing: 12) {
				locationRow(icon: "star.fill", label: "Origin", value: character.origin.name)
				Divider()
				locationRow(icon: "mappin.circle.fill", label: "Last Known", value: character.location.name)
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
	}

	func infoRow(icon: String, label: String, value: String) -> some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(.body))
				.foregroundStyle(Color.accentColor)
				.frame(width: 24)

			VStack(alignment: .leading, spacing: 2) {
				Text(label)
					.font(.system(.caption, design: .rounded))
					.foregroundStyle(.tertiary)
				Text(value)
					.font(.system(.body, design: .rounded))
					.foregroundStyle(.primary)
			}

			Spacer()
		}
	}

	func locationRow(icon: String, label: String, value: String) -> some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(.body))
				.foregroundStyle(Color.accentColor)
				.frame(width: 24)

			VStack(alignment: .leading, spacing: 2) {
				Text(label)
					.font(.system(.caption, design: .rounded))
					.foregroundStyle(.tertiary)
				Text(value)
					.font(.system(.callout, design: .monospaced))
					.foregroundStyle(.primary)
					.lineLimit(2)
			}

			Spacer()
		}
	}

	var errorView: some View {
		VStack(spacing: 20) {
			Image(systemName: "exclamationmark.triangle.fill")
				.font(.system(size: 50))
				.foregroundStyle(.orange)

			VStack(spacing: 8) {
				Text("Something went wrong")
					.font(.system(.title3, design: .rounded, weight: .semibold))
					.foregroundStyle(.primary)

				Text("Unable to load character details")
					.font(.system(.subheadline, design: .serif))
					.foregroundStyle(.secondary)
					.italic()
			}

			Button {
				Task {
					await viewModel.load()
				}
			} label: {
				HStack(spacing: 8) {
					Image(systemName: "arrow.clockwise")
					Text("Try Again")
				}
				.font(.system(.body, design: .rounded, weight: .semibold))
				.frame(maxWidth: .infinity)
				.padding(.vertical, 14)
				.background(Color.accentColor.opacity(0.1))
				.foregroundStyle(Color.accentColor)
				.clipShape(RoundedRectangle(cornerRadius: 12))
			}
			.padding(.horizontal, 40)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	func statusColor(for status: CharacterStatus) -> Color {
		switch status {
		case .alive:
			.green
		case .dead:
			.red
		case .unknown:
			.gray
		}
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let view = "characterDetail.view"
    static let backButton = "characterDetail.backButton"
}

// MARK: - Previews

#Preview("Loading") {
	NavigationStack {
		CharacterDetailView(
			viewModel: CharacterDetailViewModel(
				identifier: 1,
				getCharacterUseCase: GetCharacterUseCasePreviewMock(delay: true),
				router: RouterPreviewMock()
			)
		)
	}
}

#Preview("Loaded") {
	NavigationStack {
		CharacterDetailView(
			viewModel: CharacterDetailViewModel(
				identifier: 1,
				getCharacterUseCase: GetCharacterUseCasePreviewMock(),
				router: RouterPreviewMock()
			)
		)
	}
}

#Preview("Error") {
	NavigationStack {
		CharacterDetailView(
			viewModel: CharacterDetailViewModel(
				identifier: 1,
				getCharacterUseCase: GetCharacterUseCasePreviewMock(shouldFail: true),
				router: RouterPreviewMock()
			)
		)
	}
}

// MARK: - Preview Mocks

private final class GetCharacterUseCasePreviewMock: GetCharacterUseCaseContract {
	private let delay: Bool
	private let shouldFail: Bool

	init(delay: Bool = false, shouldFail: Bool = false) {
		self.delay = delay
		self.shouldFail = shouldFail
	}

	func execute(identifier: Int) async throws -> Character {
		if delay {
			try? await Task.sleep(for: .seconds(100))
		}
		if shouldFail {
			throw PreviewError.failed
		}
		return Character(
			id: 1,
			name: "Rick Sanchez",
			status: .alive,
			species: "Human",
			gender: "Male",
			origin: Location(name: "Earth (C-137)", url: nil),
			location: Location(name: "Citadel of Ricks", url: nil),
			imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
		)
	}
}

private enum PreviewError: Error {
	case failed
}

private final class RouterPreviewMock: RouterContract {
	func navigate(to destination: any Navigation) {}
	func goBack() {}
}
