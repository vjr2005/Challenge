import ChallengeDesignSystem
import ChallengeResources
import SwiftUI

struct AdvancedSearchView<ViewModel: AdvancedSearchViewModelContract>: View {
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

private extension AdvancedSearchView {
    var statusChipGroup: some View {
        DSChipGroup(
            LocalizedStrings.status,
            options: CharacterStatus.allCases.map { (id: $0, label: $0.localizedName) },
            selectedID: viewModel.localFilterState.status,
            accessibilityIdentifier: AccessibilityIdentifier.statusGroup
        ) { selected in
            viewModel.localFilterState.status = selected
        }
    }

    var genderChipGroup: some View {
        DSChipGroup(
            LocalizedStrings.gender,
            options: CharacterGender.allCases.map { (id: $0, label: $0.localizedName) },
            selectedID: viewModel.localFilterState.gender,
            accessibilityIdentifier: AccessibilityIdentifier.genderGroup
        ) { selected in
            viewModel.localFilterState.gender = selected
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
                    get: { viewModel.localFilterState.species ?? "" },
                    set: { viewModel.localFilterState.species = $0.isEmpty ? nil : $0 }
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
                    get: { viewModel.localFilterState.type ?? "" },
                    set: { viewModel.localFilterState.type = $0.isEmpty ? nil : $0 }
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
    static var title: String { "advancedSearch.title".localized() }
    static var status: String { "advancedSearch.status".localized() }
    static var gender: String { "advancedSearch.gender".localized() }
    static var species: String { "advancedSearch.species".localized() }
    static var speciesPlaceholder: String { "advancedSearch.speciesPlaceholder".localized() }
    static var type: String { "advancedSearch.type".localized() }
    static var typePlaceholder: String { "advancedSearch.typePlaceholder".localized() }
    static var apply: String { "advancedSearch.apply".localized() }
    static var reset: String { "advancedSearch.reset".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let closeButton = "advancedSearch.close.button"
    static let resetButton = "advancedSearch.reset.button"
    static let applyButton = "advancedSearch.apply.button"
    static let statusGroup = "advancedSearch.status"
    static let genderGroup = "advancedSearch.gender"
    static let speciesTextField = "advancedSearch.species.textField"
    static let typeTextField = "advancedSearch.type.textField"
}
