# Engineering & Team-Work Practices

- [Engineering \& Team-Work Practices](#engineering--team-work-practices)
  - [Vertical Slicing](#vertical-slicing)
  - [Domain-Driven Design (DDD)](#domain-driven-design-ddd)
  - [Comments](#comments)
  - [Continuous Refactoring \& Simple Design](#continuous-refactoring--simple-design)
  - [Continuous Integration (CI)](#continuous-integration-ci)
    - [CI Workflow Summary](#ci-workflow-summary)

 
## Vertical Slicing

My motivation for adopting Vertical Slicing is to ensure that any development efforts are focused on delivering small, incremental pieces of functionality that span all the architectural layers from the UI to the backend and/or all components and platforms. This translates to quicker iterations and feedback loops, which in turn guarantees tighter alignment of development with user feedback and  requirements.

## Domain-Driven Design (DDD)
(replaces 'Metaphor' from XP)

DDD emphasises a deep understanding of the domain to inform our software design. The central concept here is developing a 'ubiquitous language' which domain experts and coders share. This language is reflected in the naming and choice of abstractions in the code, making it partially comprehensible to non-technical stakeholders (eventually with a goal of moving towards an internal Domain-Specific Language (DSL)). DDD ensures our code stays closely aligned with business needs and the real-world subtleties of the domain. It also facilitates a common language and thus improved communication with non-technical domain experts. 

## Comments

The code is the primary source of project documentation (with documentation related to DevOps and architecture a possible exception). I avoid explanatory comments inside the code-base. In most cases when I catch myself feeling the need to add a comment, it turns out there was an underlying naming or design issue. On this issue I side with Uncle Bob in his [epic debate](https://github.com/johnousterhout/aposd-vs-clean-code/blob/main/README.md?utm_source=substack&utm_medium=email) with John Ousterhout. 

However, there are important exceptions:
- Cases where non-obvious or unusual externalities are involved (e.g. in config-related code)
- Explanatory `XML doc comments` on deep *public* methods (and even more important on *published* methods, see distinction in [Fowler](https://martinfowler.com/ieeeSoftware/published.pdf)) i.e. those that are non-obvious and hide a good amount of complexity. I usually stick to the `summary` tag: it's redundant to specify the `params` or `return` values, they are already visible in the signature.

## Continuous Refactoring & Simple Design

As described in great detail by authors like Robert C. Martin (Uncle Bob), Martin Fowler, Kent Beck etc.

## Continuous Integration (CI)

For my solo or small-team projects I like to set up the following CI workflow, supported by local shell scripts for productivity / automation.

### CI Workflow Summary

Inspired and informed, among others, by [Trunk Based Development](https://trunkbaseddevelopment.com/5-min-overview/)

1. The main branch is protected from direct mergers, it only accepts mergers through PRs.

2. Developers work locally on short-lived feature branches.

3. When ready for merging...  
a) They run build & test locally for the entire solution for the relevant `Debug_*` configuration(s).  
b) On pass, they push their working branch to GitHub which triggers automated PR-creation.  
c) The subsequent merger into main then triggers a build, test & deploy run for the Release configuration of each **assembly** marked for deployment.  
d) In case of conflicts, these need to be resolved manually, followed by a renewed PR merger attempt.

1. This means, the PRs are merged into main **before** reviews: reviews shall be conducted post-merger and a corresponding GitHub project-task is generated automatically. 

This approach to CI supports a truly _continuous_ integration without delays from waiting for manual PR reviews.
Full test-coverage should ensure well-enough that no breaking changes are introduced into main. The entire workflow should be automated with project-specific shell scripts designed to run on dev's machines.
