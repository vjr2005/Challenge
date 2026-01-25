import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterStatusTests {
    @Test
    func initFromAliveStringReturnsAlive() {
        // Given
        let string = "Alive"

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .alive)
    }

    @Test
    func initFromDeadStringReturnsDead() {
        // Given
        let string = "Dead"

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .dead)
    }

    @Test
    func initFromUnknownStringReturnsUnknown() {
        // Given
        let string = "InvalidStatus"

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .unknown)
    }

    @Test
    func initFromEmptyStringReturnsUnknown() {
        // Given
        let string = ""

        // When
        let sut = CharacterStatus(from: string)

        // Then
        #expect(sut == .unknown)
    }
}
