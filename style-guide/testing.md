# Guide to Testing

- [Guide to Testing](#guide-to-testing)
  - [Introduction](#introduction)
  - [CheckMade Test Types Taxonomy](#checkmade-test-types-taxonomy)
    - [1. Unit Tests](#1-unit-tests)
      - [1.1 Functional-Unit Tests](#11-functional-unit-tests)
      - [1.2 Component-Unit Tests](#12-component-unit-tests)
      - [1.3 Contract-Unit Tests](#13-contract-unit-tests)
      - [1.4 Verification/Exploration-Unit Tests](#14-verificationexploration-unit-tests)
    - [2. Use-Case/Workflow Tests](#2-use-caseworkflow-tests)
    - [3. Integration Tests](#3-integration-tests)
      - [3.1 Targeted-Integration Tests](#31-targeted-integration-tests)
      - [3.2 System-Integration Tests](#32-system-integration-tests)
    - [4. Acceptance Tests](#4-acceptance-tests)
  - [Test Implementation Guide](#test-implementation-guide)
    - [Focus on Potential Failures](#focus-on-potential-failures)
    - [Why no test-coverage tools?](#why-no-test-coverage-tools)
    - [What about TDD?](#what-about-tdd)
    - [DI/IoC Container](#diioc-container)
    - [Mocking framework / performance](#mocking-framework--performance)
    - [Organisation of Test Project](#organisation-of-test-project)

## Introduction

Our overriding goal is fearless continuous deployment and fearless continuous refactoring.
  
To achieve this goal, let's take testing very seriously, which should also leads to simpler design, and more modular, decoupled code. This also means treating our test code as a first-class citizen in terms of coding standards and recognise it as a kind of *executable* documentation.

At the same time, we explicitly avoid any Cargo Culting on tests: We will not blindly follow any of the standard patterns or methodologies expressed in concepts like 'test pyramids' / 'code coverage' / 'TDD' / 'Mockist vs. Classic Schools' etc. 

For example, we believe a handful of intelligently and carefully crafted use-case and integration tests (covering most of the common workflows) will probably do more for our goal of fearless continuous deployment than thousands of very small unit tests with all their dependencies mocked. These are brittle and represent a huge amount of additional code that needs to be maintained, i.e. probably have an unfavourable cost/benefit ratio. 

The following sections contain our nuanced categories of tests - these distinctions will give us a shared vocabulary and help guide in the intelligent and selective implementation of tests. This is followed by a more general Test Implementation Guide.

## CheckMade Test Types Taxonomy

### 1. Unit Tests

We decouple unit tests from implementation details, but distinguish between different types of unit tests based on their scope and purpose. All unit tests share the characteristic that they're fast and don't hit external systems, but they vary significantly in their internal dependency handling.

In terms of terminology, I make a clear distinction when naming variables and types between mocks and stubs (more on that, see [Mocks Aren't Stubs (Martin Fowler)](https://martinfowler.com/articles/mocksArentStubs.html)):  

- **Mocks** allow the setting up of expected return values, verification of behaviour etc. via the [Moq](https://github.com/devlooped/moq) mocking framework  
- **Stubs** are the actual objects used by the code under test, with reduced/modified behaviour, and are often obtained by calling `.Object` on mocks.

In those unit tests that we do choose to implement, we aim for high path coverage but with no claim to comprehensive coverage. The various forms of code coverage criteria can be sources of inspiration for boundary cases:

- line/statement coverage vs.
- branch coverage vs.
- condition + branch coverage (a good default?) vs.
- path coverage (beware of the combinatorial explosion!) vs. 
- [MC/DC](https://en.wikipedia.org/wiki/Modified_condition/decision_coverage) (thorough but doable - the smart/optimised choice for high-stakes / mission-critical code)

#### 1.1 Functional-Unit Tests

These are fast tests of pure functions with minimal dependencies (see '[imperative shell / functional core](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell)' architecture and ['The values are the boundaries'](https://www.destroyallsoftware.com/talks/boundaries)). These tests are the fastest, don't rely on mocks or dependencies, and can offer large or even full path and edge-case coverage. We use them for classes / functions with complex and mission-critical logic or those that benefit from executable documentation.

#### 1.2 Component-Unit Tests

These are larger unit tests that (partially) resolve their dependency graphs to test collaboration between classes (but always mocking database and external services). The 'unit' is represented by a single test class that represents some logical 'chunk' of end-to-end functionality which, in the production code, would involve multiple classes.

In the classic vs. mockist [schools of thought](https://martinfowler.com/articles/mocksArentStubs.html#ClassicalAndMockistTesting) this represents the classic approach, making such unit tests more realistic and less brittle in the face of continuous refactoring.

While the emphasis should usually be on testing interfaces and return values, we selectively (!) also use verifications of the behaviour of mocks of important external dependencies with visible side effects. In this context, one of Daniel's [tech mentors](tech_advisory_board.html), [Paul Butcher](https://www.linkedin.com/in/paulbutcher/), likes to jokingly bring up the "launching of ICBMs" as an example for a side-effect, for which the verification of behaviour might be worthwhile.

#### 1.3 Contract-Unit Tests

Probably overkill for CheckMade since we control all components in our modular monoliths.

Contract tests add most value when different teams own different services, or in case of microservices communicating over networks, or verifying assumptions about third-party APIs.

#### 1.4 Verification/Exploration-Unit Tests

These exist to verify assumptions or to learn/discover/document 3rd party dependencies.

One example from our code base is the `Agent_NestedStructuralEquality_WorksAsDictionaryKey` test, verifying the assumption that structural equality for a nested record like `Agent` works recursively (thus making `Agent` fit-for-purpose as a dictionary key).

Another example is the internal learning/documentation process of the behaviour of external libraries (e.g. ReactiveUi).

### 2. Use-Case/Workflow Tests

A set of tests that replace frequent manual click-through testing of our Telegram Bot, simulating a sequence of user inputs and verifying the expected outputs for all common workflows. They test entire input/output sequences that represent typical end-to-end user journeys with the workflow under test, but with external boundaries mocked (e.g. using a mocked `IBotClientWrapper` rather than hitting actual Telegram servers).

One could also describe such tests as "Offline Integration Tests"

### 3. Integration Tests

#### 3.1 Targeted-Integration Tests

These test that specific pairs or small groups of components work together correctly. They're focused on particular integration points rather than testing the whole system at once:

- Our application + real database (but mocked external APIs)
- Our application + real external API (but mocked database)
- Domain logic + real file system operations (but mocked APIs)

The aim merely is testing data flow and orchestration between specific boundaries, not covering a large percentage of logic, code branches, or edge cases.

#### 3.2 System-Integration Tests

These are select few, end-to-end tests covering only a small selection of common use-cases to establish the correct interplay of the complete, integrated system as a whole, including real database, real external APIs, real file systems, real network calls, and all components working together simultaneously in our production (or at least staging) environment.

### 4. Acceptance Tests

The main purpose of these kind of tests is to ensure the application meets end-user requirements, simulating real-world usage to validate the complete functionality and integration of all features.

We want to avoid the overhead of introducing dedicated BDD frameworks/syntax (like SpecFlow, Gherkin etc.), and thus aim at getting sufficient coverage on this front from the combination of our Workflow-Unit and System-Integration Tests plus manual click-throughs.

## Test Implementation Guide

### Focus on Potential Failures

Let's make deliberate attempts to explicitly cover edge-cases, error conditions, and boundary cases. We shall try hard to break the system, including working with broken assumptions to verify Design by Contract assertions throw where expected, invalid inputs are handled gracefully, and the system degrades predictably under stress.

This means thinking not just about the happy path, but systematically considering:

- What happens when dependencies are unavailable?
- How does the system behave with malformed inputs?
- Are error messages helpful and actionable?
- Do timeouts and retries work as expected?
- Are resource limits respected?

### Why no test-coverage tools?

On a project created by 'test-infected' developers, where coverage will by default already be large, they don't add much value but create considerable overhead and distraction.
  
The crux is that '100%' test coverage is a totally meaningless measurement target!

1 - When sticking to a coarse measurement like 'statement coverage', then the '100%' is easy to attain but doesn't actually lead to sufficient coverage of branches / conditions / decisions! This is the case, for instance, with JetBrain's dotCover.   
  
Consider this C# statement:
```csharp
var userId = telegramInputMessage.From?.Id 
              ?? throw new ArgumentNullException(nameof(telegramInputMessage),
                  "From.Id in the input message must not be null");        
```

A happy-path test that never touches the `throw` branch of this statement still causes dotCover to report a 100% coverage. This is misleading and perversely incentivises use of a less terse `if` statement syntax (which works as expected). Tail wagging the dog!

2 - When using real coverage (i.e. path-coverage), 100% is unattainable anyway due to the combinatorial explosion (for any code with a fair amount of complexity). 

3 - One thus ends up obsessing about and fiddling with:
- code coverage methodologies
- coverage statistics (invariably aiming for the meaningless 100% for lack of any other sensible target)
- coverage filter settings
- etc.
  
... time and attention that would be better spent thinking deeply about important boundary cases!

### What about TDD?

Developers can decide for themselves whether they follow Test-Driven Development or whether they develop the tests after the production code. 

Daniel's personal perspective:

> "Despite advocacy by many of my programming heroes. This is one of the points where I side with John Ousterhout in his [epic debate](https://github.com/johnousterhout/aposd-vs-clean-code/blob/main/README.md?utm_source=substack&utm_medium=email) with Uncle Bob. In short, I found that the very tactical back- and forth between test code and production code, in seconds-long cycles as per true TDD, indeed distracted me from higher-level, design-oriented thinking in larger chunks."

### DI/IoC Container

We don't use a DI/IoC Container for the resolution of dependencies in unit tests due to the measured performance overhead of ca. 100ms per test, which becomes prohibitive with hundreds or even thousands of unit tests. Instead, pure DI and test factories. 

For integration tests we do reuse the main app's DI/IoC Container because the way dependencies are resolved is part of the System Under Test (SUT). 

### Mocking framework / performance

Using `Moq` for its superior performance (e.g 3x to 10x faster than `NSubstitute` on initialisation, as measured by tests in July 2025).

Be aware of test overheads, and avoid recreating instances of stateless objects for each test. Instead, make them global per test run. E.g. DomainGlossary. Since these are stateless dependencies, they don't interfere with the strict requirement for test isolation.

### Organisation of Test Project

Only the top-level of our Test Type Taxonomy (Unit, Workflow, Integration, Acceptance) shall be represented in the directory structure of the Test Project (the boundaries between the test types on the second level are probably too fluid).
