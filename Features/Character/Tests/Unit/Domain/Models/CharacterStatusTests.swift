import Testing

@testable import ChallengeCharacter

struct CharacterStatusTests {
    @Test("Init from 'Alive' string returns alive status")
    func initFromAliveStringReturnsAlive() {
        // Given
        let string = "Alive"

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .alive)
    }

    @Test("Init from 'Dead' string returns dead status")
    func initFromDeadStringReturnsDead() {
        // Given
        let string = "Dead"

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .dead)
    }

    @Test("Init from invalid string returns unknown status")
    func initFromUnknownStringReturnsUnknown() {
        // Given
        let string = "InvalidStatus"

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .unknown)
    }

    @Test("Init from empty string returns unknown status")
    func initFromEmptyStringReturnsUnknown() {
        // Given
        let string = ""

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .unknown)
    }
}
