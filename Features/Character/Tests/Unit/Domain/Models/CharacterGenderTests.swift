import Testing

@testable import ChallengeCharacter

struct CharacterGenderTests {
    @Test
    func initFromFemaleStringReturnsFemale() {
        // Given
        let string = "Female"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .female)
    }

    @Test
    func initFromMaleStringReturnsMale() {
        // Given
        let string = "Male"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .male)
    }

    @Test
    func initFromGenderlessStringReturnsGenderless() {
        // Given
        let string = "Genderless"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .genderless)
    }

    @Test
    func initFromUnknownStringReturnsUnknown() {
        // Given
        let string = "InvalidGender"

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .unknown)
    }

    @Test
    func initFromEmptyStringReturnsUnknown() {
        // Given
        let string = ""

        // When
        let sut = CharacterGender(from: string)

        // Then
        #expect(sut == .unknown)
    }
}
