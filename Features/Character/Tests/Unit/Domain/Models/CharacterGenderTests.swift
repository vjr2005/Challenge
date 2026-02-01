import Testing

@testable import ChallengeCharacter

struct CharacterGenderTests {
    @Test("Init from 'Female' string returns female gender")
    func initFromFemaleStringReturnsFemale() {
        // Given
        let string = "Female"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .female)
    }

    @Test("Init from 'Male' string returns male gender")
    func initFromMaleStringReturnsMale() {
        // Given
        let string = "Male"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .male)
    }

    @Test("Init from 'Genderless' string returns genderless")
    func initFromGenderlessStringReturnsGenderless() {
        // Given
        let string = "Genderless"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .genderless)
    }

    @Test("Init from invalid string returns unknown gender")
    func initFromUnknownStringReturnsUnknown() {
        // Given
        let string = "InvalidGender"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .unknown)
    }

    @Test("Init from empty string returns unknown gender")
    func initFromEmptyStringReturnsUnknown() {
        // Given
        let string = ""

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .unknown)
    }
}
