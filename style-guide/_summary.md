# Style Guide Summary

The set of approaches and paradigms described below help guide our development process towards elegant and maintainable code. We are hoping/attempting to thereby avoid the complexity trap that so easily besets software projects.

- OOP and SOLID for the organisation of the system but with functional style code (i.e. avoiding imperative code where possible)
- Custom Result<T> monadic wrapper to enable treatment of errors and exceptions as "just another return value"
- Continuous Refactoring and Simple Design
- Domain-Driven Design
- Clean Architecture (modular monolith / dependency inversion / dependency injection...)
- Vertical Slicing
- Design by Contract (DbC) mostly on the outer edges of modules
- C# Nullable Reference Types enabled
- Explicitness over conciseness
- Composition over inheritance
- Very limited use of Aspect-Oriented Programming (AOP)
- Avoiding premature optimisation & pessimisation
- Comprehensive test coverage (unit & integration tests)

## Sources of Inspiration 

### Engineering Practices

- [The Agile Manifesto](https://agilemanifesto.org)
    - As fully explained in: [Clean Agile](https://www.goodreads.com/book/show/45280021-clean-agile)
- [Manifesto for Software Craftsmanship](http://manifesto.softwarecraftsmanship.org)
    - As fully explained in: [The Software Craftsman](https://www.goodreads.com/book/show/23215733-software-craftsman-the)
- [Extreme Programming (XP)](https://www.goodreads.com/book/show/67833.Extreme_Programming_Explained)

### General Programming Principles & Patterns

- [The Pragmatic Programmer](https://www.goodreads.com/book/show/4099.The_Pragmatic_Programmer)
- [Domain-Driven Design](https://www.goodreads.com/book/show/179133.Domain_Driven_Design)
- [Effective Software Testing: A developer's guide](https://www.goodreads.com/book/show/59796908-effective-software-testing)
- [Trunk Based Development](https://trunkbaseddevelopment.com/5-min-overview/)
- [Mocks Aren't Stubs (Martin Fowler)](https://martinfowler.com/articles/mocksArentStubs.html)
- [Public vs. Published Interfaces (Martin Fowler)](https://martinfowler.com/ieeeSoftware/published.pdf)
- [Clean Code](https://www.goodreads.com/book/show/3735293-clean-code)
- Clean Architecture
    - [Summary](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
    - [Full Book](https://www.goodreads.com/book/show/18043011-clean-architecture)
- [The Pragmatic Programmer](https://www.goodreads.com/book/show/4099.The_Pragmatic_Programmer)
- [A Philosophy of Software Design vs Clean Code](https://github.com/johnousterhout/aposd-vs-clean-code/blob/main/README.md?utm_source=substack&utm_medium=email)
- [C# in a Nutshell](https://www.goodreads.com/book/show/195616085-c-12-in-a-nutshell)
- [Dependency Injection in .NET](https://www.goodreads.com/book/show/35055958-dependency-injection-in-net)
- [Destroy All Software (Gary Bernhardt)](https://www.destroyallsoftware.com)

### Functional Programming 

- [Functional Programming in C#](https://www.goodreads.com/book/show/31550964-functional-programming-in-c)
- [Functional Programming with C#](https://www.goodreads.com/book/show/79735449-functional-programming-with-c)
- [Domain Modeling Made Functional: Tackle Software Complexity with Domain-Driven Design and F#](https://www.goodreads.com/book/show/34921689-domain-modeling-made-functional)
- [FP vs. OO (by Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2018/04/13/FPvsOO.html)
- [John Carmack on Functional Programming in C++](http://sevangelatos.com/john-carmack-on/)
- [Railway Oriented Programming (by Scott Wlaschin)](https://fsharpforfunandprofit.com/rop/)
