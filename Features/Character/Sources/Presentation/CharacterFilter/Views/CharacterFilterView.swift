import ChallengeDesignSystem
import ChallengeResources
import SwiftUI

struct CharacterFilterView<ViewModel: CharacterFilterViewModelContract>: View {
    @State private var viewModel: ViewModel
    @Environment(\.dsTheme) private var theme

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    statusChipGroup
                    genderChipGroup
                    speciesField
                    typeField
                }
                .padding(theme.spacing.lg)
            }
            applyButton
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.lg)
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(LocalizedStrings.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.didTapClose()
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityIdentifier(AccessibilityIdentifier.closeButton)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(LocalizedStrings.reset) {
                    viewModel.didTapReset()
                }
                .disabled(!viewModel.hasActiveFilters)
                .accessibilityIdentifier(AccessibilityIdentifier.resetButton)
            }
        }
        .onAppear {
            viewModel.didAppear()
        }
    }
}

// MARK: - Subviews

private extension CharacterFilterView {
    var statusChipGroup: some View {
        DSChipGroup(
            LocalizedStrings.status,
            options: CharacterStatus.allCases.map { (id: $0, label: $0.localizedName) },
            selectedID: viewModel.filter.status,
            accessibilityIdentifier: AccessibilityIdentifier.statusGroup
        ) { selected in
            viewModel.filter.status = selected
        }
    }

    var genderChipGroup: some View {
        DSChipGroup(
            LocalizedStrings.gender,
            options: CharacterGender.allCases.map { (id: $0, label: $0.localizedName) },
            selectedID: viewModel.filter.gender,
            accessibilityIdentifier: AccessibilityIdentifier.genderGroup
        ) { selected in
            viewModel.filter.gender = selected
        }
    }

    var speciesField: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(LocalizedStrings.species)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)
            DSTextField(
                placeholder: LocalizedStrings.speciesPlaceholder,
                text: Binding(
                    get: { viewModel.filter.species ?? "" },
                    set: { viewModel.filter.species = $0.isEmpty ? nil : $0 }
                ),
                accessibilityIdentifier: AccessibilityIdentifier.speciesTextField
            )
        }
    }

    var typeField: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(LocalizedStrings.type)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)
            DSTextField(
                placeholder: LocalizedStrings.typePlaceholder,
                text: Binding(
                    get: { viewModel.filter.type ?? "" },
                    set: { viewModel.filter.type = $0.isEmpty ? nil : $0 }
                ),
                accessibilityIdentifier: AccessibilityIdentifier.typeTextField
            )
        }
    }

    var applyButton: some View {
        DSButton(
            LocalizedStrings.apply,
            variant: .primary,
            accessibilityIdentifier: AccessibilityIdentifier.applyButton
        ) {
            viewModel.didTapApply()
        }
        .padding(.top, theme.spacing.md)
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "characterFilter.title".localized() }
    static var status: String { "characterFilter.status".localized() }
    static var gender: String { "characterFilter.gender".localized() }
    static var species: String { "characterFilter.species".localized() }
    static var speciesPlaceholder: String { "characterFilter.speciesPlaceholder".localized() }
    static var type: String { "characterFilter.type".localized() }
    static var typePlaceholder: String { "characterFilter.typePlaceholder".localized() }
    static var apply: String { "characterFilter.apply".localized() }
    static var reset: String { "characterFilter.reset".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let closeButton = "characterFilter.close.button"
    static let resetButton = "characterFilter.reset.button"
    static let applyButton = "characterFilter.apply.button"
    static let statusGroup = "characterFilter.status"
    static let genderGroup = "characterFilter.gender"
    static let speciesTextField = "characterFilter.species.textField"
    static let typeTextField = "characterFilter.type.textField"
}
