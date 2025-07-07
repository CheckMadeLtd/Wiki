# Guide to Testing

- [Guide to Testing](#guide-to-testing)
  - [Introduction](#introduction)
  - [1. Unit Tests](#1-unit-tests)
    - [1.1 Logic-Unit Tests](#11-logic-unit-tests)
    - [1.2 Component-Unit Tests](#12-component-unit-tests)
    - [1.3 Workflow-Unit Tests](#13-workflow-unit-tests)
    - [1.4 Contract-Unit Tests](#14-contract-unit-tests)
    - [1.5 Verification/Exploration-Unit Tests](#15-verificationexploration-unit-tests)
  - [2. Integration Tests](#2-integration-tests)
    - [2.1 Targeted-Integration Tests](#21-targeted-integration-tests)
    - [2.2 System-Integration Tests](#22-system-integration-tests)
  - [3. Acceptance Tests](#3-acceptance-tests)
  - [4. Focus on Potential Failures](#4-focus-on-potential-failures)
  - [Why no test-coverage tools?](#why-no-test-coverage-tools)
  - [Why no TDD?](#why-no-tdd)


## Introduction

My overriding goal is fearless continuous deployment and fearless continuous refactoring.
  
To achieve this goal, I take testing very seriously, which also leads to simpler design, and more modular, decoupled code. 

I have come to the view that the test code (a first-class citizen in terms of coding standards) becomes the *full* specification, *executable* documentation and even a fairly good proxy for *the user*!

The following sections describe my refined approach to the 'test pyramid' - with more nuanced categories of tests that better reflect how I actually think about and structure testing in practice. I end with a few words on why I don't use test coverage tools and my stance on TDD.

## 1. Unit Tests

I try to decouple unit tests from implementation details, but I've refined my thinking to distinguish between different types of unit tests based on their scope and purpose. All unit tests share the characteristic that they're fast and don't hit external systems, but they vary significantly in their internal dependency handling.

### 1.1 Logic-Unit Tests

These are fast tests of pure logic with minimal dependencies. Following the imperative shell / functional core architecture, these test classes focused on pure functionality with any I/O or side-effects separated out. These tests are the fastest, don't rely on mocks or dependencies, and can offer large or even full path and edge-case coverage since they're testing deterministic, pure logic.

### 1.2 Component-Unit Tests

These are essentially large unit tests that resolve entire internal dependency graphs to test collaboration, but exclude database and external services. Any unit will typically be represented by a single test class testing a cluster of closely interrelated methods that, taken together, represent some logical 'chunk' of end-to-end functionality.

These tests make use of a modified D.I. services container that inherits from the app's main container but replaces external dependencies (e.g. repositories with database access) with their mocks or stubs. Overall it would seem then, that I intuitively have subscribed to the classic (rather than mockist) [school of thought](https://martinfowler.com/articles/mocksArentStubs.html#ClassicalAndMockistTesting). I feel this makes my unit tests more realistic and less brittle in the face of continuous refactoring, thus better supporting the two overriding goals stated at the outset.

I aim for high path coverage but with no claim to comprehensive coverage. The various forms of code coverage criteria can be sources of inspiration for boundary cases:

- line/statement coverage vs.
- branch coverage vs.
- condition + branch coverage (a good default?) vs.
- path coverage (beware of the combinatorial explosion!) vs. 
- [MC/DC](https://en.wikipedia.org/wiki/Modified_condition/decision_coverage) (thorough but doable - the smart/optimised choice for high-stakes / mission-critical code)

While the emphasis is on testing interfaces and return values, I selectively also use verifications of the behaviour of mocks of important external dependencies with visible side effects. In this context, one of my [tech mentors](tech_advisory_board.html), [Paul Butcher](https://www.linkedin.com/in/paulbutcher/), likes to jokingly bring up the "launching of ICBMs" as an example for a side-effect, for which the verification of behaviour might be worthwhile.

### 1.3 Workflow-Unit Tests

A set of tests that replace my frequent manual click-through testing, simulating a sequence of user inputs and verifying the expected outputs for all common workflows. These test entire input/output sequences that represent typical user journeys with the workflow under test, but with external boundaries mocked (e.g., using a mocked `IBotClientWrapper` rather than hitting actual Telegram servers).

Each test validates an end-to-end user journey to confirm workflows still function as intended after changes.

### 1.4 Contract-Unit Tests

Probably overkill for most projects since we typically control all components in our modular monoliths. Contract tests add most value when different teams own different services, you have microservices communicating over networks, or you integrate with third-party APIs where you want to verify your assumptions.

### 1.5 Verification/Exploration-Unit Tests

These exist to verify assumptions or to learn/discover/document 3rd party dependencies. Examples include verifying that structural equality for a nested record works recursively (making it fit to serve as a dictionary key), or documenting the behaviour of external libraries.

In terms of terminology, I make a clear distinction when naming variables and types between mocks and stubs (more on that, see [Mocks Aren't Stubs (Martin Fowler)](https://martinfowler.com/articles/mocksArentStubs.html)):  

- **Mocks** allow the setting up of expected return values, verification of behaviour etc. via the [Moq](https://github.com/devlooped/moq) mocking framework  
- **Stubs** are the actual objects used by the code under test, with reduced/modified behaviour, and are often obtained by calling `.Object` on mocks.

## 2. Integration Tests

### 2.1 Targeted-Integration Tests

These test that specific pairs or small groups of components work together correctly. They're focused on particular integration points rather than testing the whole system at once:

- Our application + real database (but mocked external APIs)
- Our application + real external API (but mocked database)
- Domain logic + real file system operations (but mocked APIs)

This is more about testing data flow and orchestration between specific boundaries than about covering a large percentage of logic, code branches, or edge cases. No claim to comprehensive path coverage.

### 2.2 System-Integration Tests

These are few, end-to-end tests covering the most common use-cases to establish the correct interplay of the complete, integrated system as a whole, including real database, real external APIs (or staging equivalents), real file systems, real network calls, and all components working together simultaneously.

For these tests, I rely on the main app's D.I. services container for resolution of all dependencies.

## 3. Acceptance Tests

The main purpose of these tests is to ensure the application meets end-user requirements, simulating real-world usage to validate the complete functionality and integration of all features. To avoid the overhead of introducing BDD frameworks/syntax (like SpecFlow, Gherkin etc.), the combination of Workflow-Unit Tests and System-Integration Tests should provide sufficient coverage here.

While important, these tests are far lower in number (in line with the typical test pyramid) and have been lower priority. In some cases, like projects based on Telegram.Bot, they have been manual.

## 4. Focus on Potential Failures

A key refinement in my approach is making more deliberate attempts to explicitly cover edge-cases, error conditions, and boundary cases. I try harder to break the system, including working with broken assumptions to verify Design by Contract assertions throw where expected, invalid inputs are handled gracefully, and the system degrades predictably under stress.

This means thinking not just about the happy path, but systematically considering:
- What happens when dependencies are unavailable?
- How does the system behave with malformed inputs?
- Are error messages helpful and actionable?
- Do timeouts and retries work as expected?
- Are resource limits respected?

## Why no test-coverage tools?

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

## Why no TDD?

Notice that I am not following 'Test-Driven Development' despite advocacy by many of my programming heroes. This is one of the points where I side with John Ousterhout in his [epic debate](https://github.com/johnousterhout/aposd-vs-clean-code/blob/main/README.md?utm_source=substack&utm_medium=email) with Uncle Bob. In short, I found that the very tactical back- and forth between test code and production code, in seconds-long cycles as per true TDD, indeed distracted me from higher-level, design-oriented thinking in larger chunks. This style guide is neutral on the use of TDD as long as you otherwise take tests as seriously as I do.