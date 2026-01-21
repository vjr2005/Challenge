# Plan: Implementación de Sourcery para Mock Generation

## Resumen

| Aspecto | Detalle |
|---------|---------|
| Librería | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Estrellas | ⭐ 8,000 |
| Tipo | Code generation (pre-compilación) |
| Acoplamiento | Bajo (propiedades simples) |
| Setup | Build phase + template Stencil |

---

## Arquitectura de Mocks

### Dos tipos de mocks

| Tipo | Anotación | Ubicación | Visibilidad | Uso |
|------|-----------|-----------|-------------|-----|
| **Público** | `// sourcery: AutoMockable, public` | `Mocks/` | `public` | Otros módulos en sus tests |
| **Interno** | `// sourcery: AutoMockable` | `Tests/Mocks/` | `internal` | Solo tests del propio módulo |

### Ejemplos

```swift
// Libraries/Core/Sources/Navigation/RouterContract.swift
// sourcery: AutoMockable, public
public protocol RouterContract {
    func navigate(to destination: any Navigation)
    func goBack()
}
// → Genera: Libraries/Core/Mocks/RouterContractMock.swift (public)

// Libraries/Features/Character/Sources/Domain/Repositories/CharacterRepositoryContract.swift
// sourcery: AutoMockable
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(identifier: Int) async throws -> Character
}
// → Genera: Libraries/Features/Character/Tests/Mocks/CharacterRepositoryContractMock.swift (internal)
```

---

## Paso 1: Instalar Sourcery via Mise

### 1.1 Actualizar `.mise.toml`

```toml
[tools]
swiftlint = "0.58.0"
periphery = "2.21.0"
sourcery = "2.2.6"
```

### 1.2 Instalar

```bash
mise install
```

### 1.3 Verificar instalación

```bash
mise x -- sourcery --version
```

---

## Paso 2: Crear Template Unificado

### 2.1 Crear directorio de templates

```bash
mkdir -p Tuist/Templates
```

### 2.2 Crear `Tuist/Templates/AutoMockable.stencil`

```stencil
// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

{% for type in types.protocols where type.annotations["AutoMockable"] %}
{% set isPublic %}{% if type.annotations["public"] %}true{% endif %}{% endset %}
{% set accessModifier %}{% if isPublic %}public {% endif %}{% endset %}
{% set mockName %}{{ type.name }}Mock{% endset %}

// MARK: - {{ mockName }}

{{ accessModifier }}final class {{ mockName }}: {{ type.name }}, @unchecked Sendable {

    {{ accessModifier }}init() {}

    {% for variable in type.allVariables %}
    {% if variable.isOptional %}
    {{ accessModifier }}var {% call variableName variable %}: {{ variable.typeName }} = nil
    {% elif variable.isArray %}
    {{ accessModifier }}var {% call variableName variable %}: {{ variable.typeName }} = []
    {% elif variable.isDictionary %}
    {{ accessModifier }}var {% call variableName variable %}: {{ variable.typeName }} = [:]
    {% else %}
    {{ accessModifier }}var {% call variableName variable %}: {{ variable.typeName }}!
    {% endif %}
    {% endfor %}

    {% for method in type.allMethods %}
    {% set methodName %}{% call swiftifyMethodName method.selectorName %}{% endset %}
    // MARK: - {{ method.shortName }}

    {{ accessModifier }}private(set) var {{ methodName }}CallCount = 0
    {% if method.parameters.count == 1 %}
    {{ accessModifier }}private(set) var {{ methodName }}Received{% call capitalizeFirst method.parameters.first.name %}: {{ method.parameters.first.typeName }}?
    {% elif method.parameters.count > 1 %}
    {{ accessModifier }}private(set) var {{ methodName }}ReceivedArguments: ({% for param in method.parameters %}{{ param.name }}: {{ param.typeName }}{% if not forloop.last %}, {% endif %}{% endfor %})?
    {% endif %}
    {% if method.parameters.count > 0 %}
    {{ accessModifier }}private(set) var {{ methodName }}ReceivedInvocations: [{% if method.parameters.count == 1 %}{{ method.parameters.first.typeName }}{% else %}({% for param in method.parameters %}{{ param.name }}: {{ param.typeName }}{% if not forloop.last %}, {% endif %}{% endfor %}){% endif %}] = []
    {% endif %}
    {% if method.throws %}
    {{ accessModifier }}var {{ methodName }}ThrowableError: (any Error)?
    {% endif %}
    {% if not method.returnTypeName.isVoid %}
    {{ accessModifier }}var {{ methodName }}Result: Result<{{ method.returnTypeName }}, any Error>!
    {% endif %}

    {{ accessModifier }}func {{ method.name }}({% for param in method.parameters %}{% if param.argumentLabel != param.name %}{{ param.argumentLabel }} {% elif param.argumentLabel == param.name %}{{ param.name }} {% endif %}{{ param.name }}: {{ param.typeName }}{% if not forloop.last %}, {% endif %}{% endfor %}){% if method.isAsync %} async{% endif %}{% if method.throws %} throws{% endif %}{% if not method.returnTypeName.isVoid %} -> {{ method.returnTypeName }}{% endif %} {
        {{ methodName }}CallCount += 1
        {% if method.parameters.count == 1 %}
        {{ methodName }}Received{% call capitalizeFirst method.parameters.first.name %} = {{ method.parameters.first.name }}
        {{ methodName }}ReceivedInvocations.append({{ method.parameters.first.name }})
        {% elif method.parameters.count > 1 %}
        {{ methodName }}ReceivedArguments = ({% for param in method.parameters %}{{ param.name }}: {{ param.name }}{% if not forloop.last %}, {% endif %}{% endfor %})
        {{ methodName }}ReceivedInvocations.append(({% for param in method.parameters %}{{ param.name }}: {{ param.name }}{% if not forloop.last %}, {% endif %}{% endfor %}))
        {% endif %}
        {% if method.throws %}
        if let error = {{ methodName }}ThrowableError {
            throw error
        }
        {% endif %}
        {% if not method.returnTypeName.isVoid %}
        return try {{ methodName }}Result.get()
        {% endif %}
    }

    {% endfor %}
}

{% endfor %}

{% macro swiftifyMethodName name %}{{ name | replace:"(","_" | replace:")","" | replace:":","_" | replace:"`","" | snakeToCamelCase | lowerFirstWord }}{% endmacro %}
{% macro capitalizeFirst name %}{{ name | upperFirstLetter }}{% endmacro %}
{% macro variableName variable %}{{ variable.name }}{% endmacro %}
```

---

## Paso 3: Configurar Sourcery

### 3.1 Crear `.sourcery.yml` con dos configuraciones

```yaml
# Configuración para mocks públicos
# Genera en: Libraries/{Module}/Mocks/
sources:
  - path: Libraries/Core/Sources
    filter: ".*Contract\\.swift$"
  - path: Libraries/Networking/Sources
    filter: ".*Contract\\.swift$"

templates:
  - Tuist/Templates/AutoMockable.stencil

output:
  path: Libraries/Generated/PublicMocks/
  link:
    project: Challenge.xcodeproj
    target: ChallengeCoreMocks

args:
  autoMockableTestableImports: []
  autoMockableImports:
    - Foundation
    - ChallengeCore
    - ChallengeNetworking
```

### 3.2 Crear configuración separada `.sourcery-internal.yml`

```yaml
# Configuración para mocks internos (tests)
# Genera en: Libraries/{Feature}/Tests/Mocks/

sources:
  - path: Libraries/Features
    filter: ".*Contract\\.swift$"

templates:
  - Tuist/Templates/AutoMockable.stencil

output:
  path: Libraries/Generated/InternalMocks/

args:
  autoMockableTestableImports:
    - ChallengeCharacter
  autoMockableImports:
    - Foundation
```

### 3.3 Script de generación unificado

Crear `Scripts/generate-mocks.sh`:

```bash
#!/bin/bash
set -e

echo "🔧 Generating public mocks..."
mise x -- sourcery --config .sourcery.yml

echo "🔧 Generating internal mocks..."
mise x -- sourcery --config .sourcery-internal.yml

echo "✅ Mock generation complete"
```

```bash
chmod +x Scripts/generate-mocks.sh
```

---

## Paso 4: Estructura de Archivos Generados

### 4.1 Mocks públicos

```
Libraries/Generated/PublicMocks/
├── RouterContractMock.swift
├── ImageLoaderContractMock.swift
└── HTTPClientContractMock.swift
```

### 4.2 Mocks internos

```
Libraries/Generated/InternalMocks/
├── CharacterRepositoryContractMock.swift
├── CharacterRemoteDataSourceContractMock.swift
├── CharacterMemoryDataSourceContractMock.swift
├── GetCharacterUseCaseContractMock.swift
├── GetCharactersUseCaseContractMock.swift
├── CharacterListViewModelContractMock.swift
└── CharacterDetailViewModelContractMock.swift
```

---

## Paso 5: Integrar en Tuist

### 5.1 Crear módulo para mocks públicos generados

Crear `Tuist/ProjectDescriptionHelpers/Modules/GeneratedMocksModule.swift`:

```swift
import ProjectDescription

public enum GeneratedMocksModule {
    public static let publicMocks = FrameworkModule.create(
        name: "GeneratedMocks",
        path: "Generated/PublicMocks",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)Networking"),
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName)GeneratedMocks"),
    ]
}
```

### 5.2 Actualizar módulos para usar mocks generados

**CoreModule.swift:**
```swift
public static let module = FrameworkModule.create(
    name: "Core",
    testDependencies: [
        .target(name: "\(appName)GeneratedMocks"),
    ]
)
```

**CharacterModule.swift:**
```swift
public static let module = FrameworkModule.create(
    name: "Character",
    path: "Features/Character",
    dependencies: [
        .target(name: "\(appName)Core"),
        .target(name: "\(appName)Networking"),
    ],
    testDependencies: [
        .target(name: "\(appName)GeneratedMocks"),  // Mocks públicos
        // Mocks internos se incluyen automáticamente en Tests/
        .external(name: "SnapshotTesting"),
    ]
)
```

### 5.3 Añadir script pre-build en Project.swift

```swift
let sourceryScript = TargetScript.pre(
    script: """
    if which mise > /dev/null; then
        cd "${SRCROOT}"
        ./Scripts/generate-mocks.sh
    else
        echo "warning: Mise not installed, skipping Sourcery"
    fi
    """,
    name: "Generate Mocks (Sourcery)",
    basedOnDependencyAnalysis: false
)
```

---

## Paso 6: Anotar Protocols

### 6.1 Protocols públicos (generan mocks públicos)

```swift
// Libraries/Core/Sources/Navigation/RouterContract.swift
import Foundation

// sourcery: AutoMockable, public
public protocol RouterContract {
    func navigate(to destination: any Navigation)
    func goBack()
}
```

```swift
// Libraries/Core/Sources/ImageLoader/ImageLoaderContract.swift
import Foundation
import UIKit

// sourcery: AutoMockable, public
public protocol ImageLoaderContract: Sendable {
    func cachedImage(for url: URL) -> UIImage?
    func image(for url: URL) async -> UIImage?
}
```

```swift
// Libraries/Networking/Sources/HTTP/HTTPClientContract.swift
import Foundation

// sourcery: AutoMockable, public
public protocol HTTPClientContract: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}
```

### 6.2 Protocols internos (generan mocks internos)

```swift
// Libraries/Features/Character/Sources/Domain/Repositories/CharacterRepositoryContract.swift

// sourcery: AutoMockable
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(identifier: Int) async throws -> Character
    func getCharacters(page: Int) async throws -> CharactersPage
}
```

```swift
// Libraries/Features/Character/Sources/Data/DataSources/CharacterRemoteDataSourceContract.swift

// sourcery: AutoMockable
protocol CharacterRemoteDataSourceContract: Sendable {
    func getCharacter(identifier: Int) async throws -> CharacterDTO
    func getCharacters(page: Int) async throws -> CharactersResponseDTO
}
```

### 6.3 Lista completa de protocols a anotar

| Protocol | Módulo | Anotación | Tipo Mock |
|----------|--------|-----------|-----------|
| `RouterContract` | Core | `AutoMockable, public` | Público |
| `ImageLoaderContract` | Core | `AutoMockable, public` | Público |
| `HTTPClientContract` | Networking | `AutoMockable, public` | Público |
| `CharacterRepositoryContract` | Character | `AutoMockable` | Interno |
| `CharacterRemoteDataSourceContract` | Character | `AutoMockable` | Interno |
| `CharacterMemoryDataSourceContract` | Character | `AutoMockable` | Interno |
| `GetCharacterUseCaseContract` | Character | `AutoMockable` | Interno |
| `GetCharactersUseCaseContract` | Character | `AutoMockable` | Interno |
| `CharacterListViewModelContract` | Character | `AutoMockable` | Interno |
| `CharacterDetailViewModelContract` | Character | `AutoMockable` | Interno |

---

## Paso 7: Ejemplo de Mock Generado

### 7.1 Input: Protocol

```swift
// sourcery: AutoMockable
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(identifier: Int) async throws -> Character
    func getCharacters(page: Int) async throws -> CharactersPage
}
```

### 7.2 Output: Mock generado

```swift
// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - CharacterRepositoryContractMock

final class CharacterRepositoryContractMock: CharacterRepositoryContract, @unchecked Sendable {

    init() {}

    // MARK: - getCharacter

    private(set) var getCharacterCallCount = 0
    private(set) var getCharacterReceivedIdentifier: Int?
    private(set) var getCharacterReceivedInvocations: [Int] = []
    var getCharacterThrowableError: (any Error)?
    var getCharacterResult: Result<Character, any Error>!

    func getCharacter(identifier: Int) async throws -> Character {
        getCharacterCallCount += 1
        getCharacterReceivedIdentifier = identifier
        getCharacterReceivedInvocations.append(identifier)
        if let error = getCharacterThrowableError {
            throw error
        }
        return try getCharacterResult.get()
    }

    // MARK: - getCharacters

    private(set) var getCharactersCallCount = 0
    private(set) var getCharactersReceivedPage: Int?
    private(set) var getCharactersReceivedInvocations: [Int] = []
    var getCharactersThrowableError: (any Error)?
    var getCharactersResult: Result<CharactersPage, any Error>!

    func getCharacters(page: Int) async throws -> CharactersPage {
        getCharactersCallCount += 1
        getCharactersReceivedPage = page
        getCharactersReceivedInvocations.append(page)
        if let error = getCharactersThrowableError {
            throw error
        }
        return try getCharactersResult.get()
    }
}
```

---

## Paso 8: Migrar Tests

### 8.1 Antes (mock manual)

```swift
final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
    var result: Result<Character, Error> = .failure(NotConfiguredError.notConfigured)
    var charactersResult: Result<CharactersPage, Error> = .failure(NotConfiguredError.notConfigured)
    private(set) var getCharacterCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    func getCharacter(identifier: Int) async throws -> Character {
        getCharacterCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }

    func getCharacters(page: Int) async throws -> CharactersPage {
        return try charactersResult.get()
    }
}

// Test
@Test
func test() async throws {
    let mock = CharacterRepositoryMock()
    mock.result = .success(Character.stub())
    let sut = GetCharacterUseCase(repository: mock)

    let result = try await sut.execute(identifier: 1)

    #expect(mock.getCharacterCallCount == 1)
    #expect(mock.lastRequestedIdentifier == 1)
}
```

### 8.2 Después (mock generado)

```swift
// No necesita definir mock manual

// Test
@Test
func test() async throws {
    let mock = CharacterRepositoryContractMock()
    mock.getCharacterResult = .success(Character.stub())
    let sut = GetCharacterUseCase(repository: mock)

    let result = try await sut.execute(identifier: 1)

    #expect(mock.getCharacterCallCount == 1)
    #expect(mock.getCharacterReceivedIdentifier == 1)
}
```

### 8.3 Mapeo de propiedades

| Mock Manual | Mock Generado |
|-------------|---------------|
| `result` | `getCharacterResult` |
| `charactersResult` | `getCharactersResult` |
| `getCharacterCallCount` | `getCharacterCallCount` |
| `lastRequestedIdentifier` | `getCharacterReceivedIdentifier` |
| - | `getCharacterReceivedInvocations` |
| - | `getCharacterThrowableError` |

---

## Paso 9: Eliminar Mocks Manuales

### 9.1 Archivos a eliminar

```bash
# Mocks públicos manuales
rm Libraries/Core/Mocks/RouterMock.swift
rm Libraries/Core/Mocks/ImageLoaderMock.swift
rm Libraries/Networking/Mocks/HTTP/HTTPClientMock.swift

# Mocks internos manuales
rm Libraries/Features/Character/Tests/Mocks/CharacterRepositoryMock.swift
rm Libraries/Features/Character/Tests/Mocks/CharacterRemoteDataSourceMock.swift
rm Libraries/Features/Character/Tests/Mocks/GetCharacterUseCaseMock.swift
rm Libraries/Features/Character/Tests/Mocks/GetCharactersUseCaseMock.swift
rm Libraries/Features/Character/Tests/Mocks/CharacterMemoryDataSourceMock.swift
```

### 9.2 Mantener (no son mocks de protocols)

```
Libraries/Networking/Tests/Mocks/URLProtocolMock.swift  # Mock de clase URLProtocol
Libraries/Core/Mocks/Bundle+JSON.swift                  # Helper para cargar JSON
```

---

## Paso 10: Actualizar Documentación

### 10.1 Actualizar CLAUDE.md

Añadir en sección **Tools (via mise)**:

```markdown
| Tool | Purpose | Command |
|------|---------|---------|
| SwiftLint | Code linting | `mise x -- swiftlint` |
| Periphery | Dead code detection | `mise x -- periphery scan` |
| Sourcery | Mock generation | `mise x -- sourcery` |
```

Añadir nueva sección:

```markdown
## Mock Generation

Mocks are auto-generated using Sourcery. Annotate protocols with:

| Annotation | Generated Mock | Location |
|------------|---------------|----------|
| `// sourcery: AutoMockable, public` | Public | `Libraries/Generated/PublicMocks/` |
| `// sourcery: AutoMockable` | Internal | `Libraries/Generated/InternalMocks/` |

**Generate mocks manually:**
\`\`\`bash
./Scripts/generate-mocks.sh
\`\`\`

**Mocks are regenerated automatically** on each build via pre-build script.
```

### 10.2 Actualizar skill `/testing`

Añadir sección sobre mocks generados con ejemplos de uso.

---

## Paso 11: Verificar

```bash
# 1. Instalar Sourcery
mise install

# 2. Generar mocks
./Scripts/generate-mocks.sh

# 3. Generar proyecto
tuist generate

# 4. Ejecutar tests
tuist test
```

---

## Estructura Final

```
Challenge/
├── .mise.toml                          # + sourcery
├── .sourcery.yml                       # Config mocks públicos
├── .sourcery-internal.yml              # Config mocks internos
├── Scripts/
│   └── generate-mocks.sh               # Script unificado
├── Tuist/
│   ├── Templates/
│   │   └── AutoMockable.stencil        # Template único
│   └── ProjectDescriptionHelpers/
│       └── Modules/
│           └── GeneratedMocksModule.swift
├── Libraries/
│   ├── Generated/
│   │   ├── PublicMocks/                # Mocks públicos generados
│   │   │   ├── RouterContractMock.swift
│   │   │   ├── ImageLoaderContractMock.swift
│   │   │   └── HTTPClientContractMock.swift
│   │   └── InternalMocks/              # Mocks internos generados
│   │       ├── CharacterRepositoryContractMock.swift
│   │       └── ...
│   ├── Core/
│   │   ├── Sources/
│   │   │   └── Navigation/
│   │   │       └── RouterContract.swift  # // sourcery: AutoMockable, public
│   │   └── Mocks/                        # ELIMINADO
│   └── Features/
│       └── Character/
│           ├── Sources/
│           │   └── Domain/
│           │       └── Repositories/
│           │           └── CharacterRepositoryContract.swift  # // sourcery: AutoMockable
│           └── Tests/
│               └── Mocks/                # ELIMINADO
```

---

## Resumen de Cambios

| Tipo | Cantidad |
|------|----------|
| Archivos nuevos | 5 (configs, template, script, módulo) |
| Archivos modificados | ~12 (protocols + módulos Tuist) |
| Archivos eliminados | ~8 mocks manuales |
| Líneas de código eliminadas | ~500 (boilerplate) |

---

## Tareas de Implementación

- [ ] 1. Añadir sourcery a `.mise.toml`
- [ ] 2. Crear `Tuist/Templates/AutoMockable.stencil`
- [ ] 3. Crear `.sourcery.yml` y `.sourcery-internal.yml`
- [ ] 4. Crear `Scripts/generate-mocks.sh`
- [ ] 5. Crear `GeneratedMocksModule.swift`
- [ ] 6. Actualizar `Project.swift` con script pre-build
- [ ] 7. Anotar protocols públicos con `// sourcery: AutoMockable, public`
- [ ] 8. Anotar protocols internos con `// sourcery: AutoMockable`
- [ ] 9. Ejecutar generación de mocks
- [ ] 10. Actualizar imports en tests
- [ ] 11. Migrar tests a usar mocks generados
- [ ] 12. Eliminar mocks manuales
- [ ] 13. Actualizar CLAUDE.md
- [ ] 14. Actualizar skill `/testing`
- [ ] 15. Verificar con `tuist test`

---

## Pros y Contras

### Pros
- ✅ Elimina ~500 líneas de boilerplate
- ✅ Bajo acoplamiento (propiedades simples, sin DSL)
- ✅ Template 100% personalizable
- ✅ Separación clara: mocks públicos vs internos
- ✅ Muy maduro (8,000 estrellas, 9 años)
- ✅ Patrón consistente en todos los mocks
- ✅ Usa `Result<T, Error>` (igual que mocks manuales actuales)

### Contras
- ❌ Requiere build phase (script pre-build)
- ❌ Template Stencil que mantener
- ❌ Código generado en ficheros separados (no inline)
- ❌ Configuración inicial más compleja que Swift Macros
- ❌ Dependencia externa (aunque gestionada via mise)
