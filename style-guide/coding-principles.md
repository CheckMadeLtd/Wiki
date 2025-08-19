# Coding Principles

- [Coding Principles](#coding-principles)
  - [Principled Code Design \& Implementation](#principled-code-design--implementation)
    - [SOLID Principles](#solid-principles)
    - [Design by Contract](#design-by-contract)
    - [Composition over Inheritance](#composition-over-inheritance)
      - [Problems with implementation-inheritance](#problems-with-implementation-inheritance)
      - [Solution](#solution)
    - [Explicitness over Conciseness](#explicitness-over-conciseness)
    - [Depth vs Shortness of Functions](#depth-vs-shortness-of-functions)
    - [Dependency Injection](#dependency-injection)
      - [DI Container Libraries](#di-container-libraries)
      - [A random collection of DI-related (anti-)patterns](#a-random-collection-of-di-related-anti-patterns)
    - [Aspect-Oriented Programming (AOP)](#aspect-oriented-programming-aop)


## Principled Code Design & Implementation

### SOLID Principles

The SOLID principles guide my overall system design & orchestration:

- S = Single Responsibility Principle
- O = Open/Closed Principle
- L = Liskov Substitution Principle
- I = Interface Segregation Principle
- D = Dependency Inversion Principle

### Design by Contract

I somewhat adhere to DbC (originally described by Bertrand Meyer and implemented in the Eiffel language). It ensures that software components interact based on clearly and formally defined agreements on expected inputs, outputs, invariants etc. It complements my testing strategy (see above) to achieve system robustness.

My pragmatic application of DbC means focusing on asserting pre-conditions mainly on the outer edges of modules/components (and especially when interfacing 3rd party libraries). 

**Note that this 'crashing fast and hard' approach represents the exact opposite of the 'defensive programming' anti-pattern**. 

### Composition over Inheritance

In OOP design, I prefer composition over inheritance. 

#### Problems with implementation-inheritance
1. OOP Languages are designed with the assumption that sub-typing (for polymorphic use) and implementation sharing (to avoid duplication) go hand-in-hand. That's often true but not always, which is where things break down. 
2. When starting to build class hierarchies, I don't usually have enough foresight to get it right. The deeper the hierarchies grow and the more other modules come to depend on its specifics, the harder it is to change.
3. Sub classes come to depend on specific ways base classes further up the hierarchy implement things, in a way this breaks encapsulation.

#### Solution
I avoid conflating sub-typing for polymorphism with implementation sharing for DRY!  
-> For polymorphism, I use interfaces (and avoid using default implementations)  
-> To achieve DRY, I compose objects that offer specific behaviour into the class requiring it.

Exceptions in the name of pragmatism are frequent though, especially in lower level code that other modules won't come to depend on, or when a very flat inheritance hierarchy (e.g. 1 level) is virtually guaranteed. 

### Explicitness over Conciseness

Examples:
1. Configure IDE to suggest or require the `sealed` keyword for classes without inheritors. This way we document the fact and are made aware when we change the design by being forced to remove the keyword. 

2. In the spirit of avoiding premature pessimisation, configure the IDE to require the `static` keyword for anonymous lambdas that don't use a closure over a variable outside of its scope. This allows the compiler to treat it in an optimised way (reducing the load on the GC). 

### Depth vs Shortness of Functions 

I once took the Clean Code position ("the shorter the better" and "do one thing") as gospel but have since realised that this often leads to entanglement of functions and thus increased cognitive load compared to a single, longer but coherent function. 

A more useful framework is John Ousterhout's 'depth' which represents the ratio between a function's complexity (probably correlated by its length) and its interface's complexity. The bigger the ratio in favour of a simple interface, the more complexity the function hides and the more useful it therefore is for the overall design of the system. Shortness, then, is not the actual end-goal. 

### Dependency Injection

I apply Dependency Injection selectively rather than universally. Before deciding how to handle any potential dependency, I apply a necessity test: Can this be a pure function? If yes, I make it a static method, extension method, or local function rather than a class. 

If it needs to be a class, is it an implementation detail (value objects, simple business entities, local utilities, short-lived objects) or an architectural dependency? 

Implementation details can be directly instantiated with `new()` as they're stable collaborators that are genuinely part of the consuming class's natural object model. 

I use constructor injection for architectural dependencies: 
- external systems (databases, APIs, file systems), 
- cross-cutting concerns (logging, caching), 
- complex domain services requiring abstraction, 
- components where I need multiple implementations, or 
- cases requiring mocking for testing. 

Interfaces are justified only when I actually have polymorphic behaviour or need to mock for testing or wrap implementations in Decorators, Virtual Proxies (etc.) — but never solely to enable injection! Thus, when there is no interface, I simply register the concrete type `.AsSelf()`.

Overall, my goal with this approach is maintaining loose coupling and testability where it adds genuine value while avoiding the complexity trap of over-abstraction, unnecessary indirection, and the ["noun bias" problem](https://steve-yegge.blogspot.com/2006/03/execution-in-kingdom-of-nouns.html) where simple actions become wrapped in artificial object hierarchies.

#### DI Container Libraries

The above discussion relates only to the *technique* of DI, not to the *technology* facilitating it (i.e. DI Container Libraries). Here, my library of choice is `Autofac` (see [Why Autofac](https://mattburke.dev/why-autofac/)). I avoid 'sophisticated use', where regular business logic can do the job. For example, stick to default lifestyles, details see: [2024-04-26 DI Service Lifetime - My Defaults](https://github.com/CheckMadeLtd/CheckMade/discussions/382)

The main motivation for the use of a DI Container is avoiding manual object graph compositions which represent a repetition of the information already contained in constructors. In large projects, I rely on auto-registration enabled by the `Convention over Configuration` pattern. 

#### A random collection of DI-related (anti-)patterns

Sometimes referring to [Dependency Injection in .NET](https://www.goodreads.com/book/show/35055958-dependency-injection-in-net) (= 'DI PPP')

- Avoid leaky abstraction into constructor parameters (pp. 273 in DI PPP), e.g. using IEnumerable<T> (or other collection type) or Func<> in constructor injection
  - Does not apply when T is a pure data structure
  - Possible remedy: composites
- Where object creation depends on a simple runtime value, avoid use of the factory pattern (instead use method injection). Only use factories to encapsulate complex object creation logic. For examples, see [Review my use of factories](https://github.com/CheckMadeLtd/CheckMade/issues/315)
- Constructors with more than 4 or 5 dependencies --> check for over-injection. 
  - Possible remedy: facades


### Aspect-Oriented Programming (AOP)

Sounds great in theory, but is prone to over-engineering in practice. For most typical cross-cutting concerns (like *logging*, *error handling*, *validation*, *security*...), I find it easier to stick to very specific and local/targeted implementations. *Auditing* usually comes 'for free' when using Event Sourcing for persistence, which is my default. 

Caching (e.g. for Repositories) has been one of the few examples, where AOP came in handy. I restrict myself to AOP by Design, i.e. no dynamic interception or compile-time weaving, which are mostly useful for legacy projects. 
