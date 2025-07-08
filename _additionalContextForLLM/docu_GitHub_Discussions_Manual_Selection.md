# GitHub Discussions Current Snapshot for Claude CheckMadeDev Project Knowledge

## Instruction

- Today 23/03/2025 manually copying relevant bits from all historic GitHub Discussions.
- I’m skipping those discussions where the details that matter are already fully represented in our Wiki or my Dev Style Guide
- Subsequently, manually append new discussions here for now, and export into .md file and copy into CLaude Project Knowledge Master Folder (“project_basics”) and into Claude. 

## 2024-07-21 How to track identity: GUID vs. Props #158

### Conclusion
* Use an artificial GUID to track all raw inputs related to a particular domain entity (e.g. an Issue).
* This way I get a convenient way to query for all records that are related to an entity, e.g. to easily constitute it in its current state (--> make GUID an indexed column!)
* Consider the GUID more like essential meta-data rather than temporary/deletable derived data
* This doesn't free me from defining which non-meta/real-world-props constitute identity for each type of domain entity!


## 2024-07-21 State vs. Cache / Potential Concurrency Issues #155

### Summary

#### 1) State vs. Cache
We only want state in the db or file-system, i.e. where it's unlikely to get lost. Keeping data in-memory for efficiency (e.g. reduced db queries) is called cache, not state. In-memory state is a legacy idea from the time of Desktop applications.
* In our ChatBot, we currently use a very simple form of caching inside repositories, with defensive invalidation and with a lifetime bound to the function invocation / scope. For the future, introduce Singleton caches: => see **~[Singleton \(instead of Scoped\) caches / repositories \#127](https://github.com/CheckMadeLtd/CheckMade/issues/127)~**

#### 2) In-Memory vs. DB Concurrency
Two possible types of concurrency issues with our current ChatBot architecture:

1 Certainly an issue: Our DB (esp. tlg_inputs table) represents shared state for workflows running in parallel => see **~[Defend against DB shared state / workflow concurrency issue \#156](https://github.com/CheckMadeLtd/CheckMade/issues/156)~**

2 Maybe an issue: Two users invoking bot/function at the same time: how is that handled? => see **~[Investigate Azure FunctionApp Concurrency Handling \#157](https://github.com/CheckMadeLtd/CheckMade/issues/157)~**

## 2024-07-08 Storing Last Workflow and State in DB #147

Based on [[2024-07-08 Paul - EventSourcing vs. Intermediary Results]] 

Decision: will start storing Workflow and State that an Input led to in a SEPARATE db table.

The table is separate from tlg_inputs to document that this is ephemeral / derived facts (i.e. reflecting implementation) which a) should be re-derived in future replays (e.g. for reporting) b) probably discarded e.g. after a LiveEvent is over c) in the future possibly handled by Memcache e.g. Redis rather than DB (but only when I get into the millions...)


## 2024-07-04 Using Generics for multi-dimensional Domain Modelling #146

See call notes: [[2024-07-04 Paul Call - Curiously recurring generic pattern]] 

Decided to proceed with using generics (e.g. where T : ITrade) for adding a cross-dimension to entities like SphereOfAction<T> or ITradeIssue<T>.

Originally this idea came about because I wanted compile-time type-safety for the TradeType of SphereOfAction with TradeType member of type Type without ability to restrain it to be a derived type of ITrade except at runtime in the constructor of SphereOfAction. Generics now allows compile-time restraint via where T : ITrade.

Of interest / related to: ~[The Curiously Recurring Generic Pattern](https://blog.stephencleary.com/2022/09/modern-csharp-techniques-1-curiously-recurring-generic-pattern.html)~


## 2024-06-21 Minimising DB Queries vs In-Memory Data for LINQ #145

### Original Issue / Thought

It’s about a trade off between minimising queries to the DB vs minimising the amount of ‘unnecessary’ records in-memory.

I am assuming that a db query is several orders of magnitude slower than in-memory LINQ queries but my basic question is, very roughly, how many orders of magnitude.
This will give me a general sense at how many zeros (for the number of records returned) I should start thinking of querying only for the data I need in each case (vs. a simpler query for everything as currently)

I think this ties back to a more general issue that I mentioned in the Google Doc about the book idea: I lack a good intuition about orders of magnitude.
Given my context of a single-instance serverless functionapp used in human time by a few dozen concurrent users:

When do I even need to start thinking about using more specific DB queries, to avoid loading too many historic, text-only input records in-memory: when that number reaches 1000? or 1 Million? Or 1 Billion?? No idea !! My guesstimate would be ca. 100 Thousand.

The implication is that my code is easier to read/maintain when I only have a single DB query that loads the entire history (for the current LiveEvent only of course) rather than more specialised queries. I.e. this is probably more about code simplicity than about a performance trade-off as implied in my initial text message, though performance is of course a secondary consideration here too, but I’m not too worried.

### Summary/Decision

I think I’ll just stick to loading the entire input/message history of the current LiveEvent into memory every time. It will be thousands at most, at this time…

And only if there are symptoms like slow bot response or strangely high Azure invoice, I’ll investigate… otherwise, deferred until a later year

## 2024-06-13 No use of ORM (Dapper) #143

### Decision

Decided not to use any O/RM (originally planned was Micro O/RM Dapper) based on 2024-06-13 Paul chat - ORM and Impedance Mismatch Revisited

### Summary of above mentioned convo with Paul:

The dialogue with mentor Paul clarifies several key points about ORM usage in the project. Paul distinguishes between two ORM functions: SQL generation (preventing injection attacks) and object-relational mapping. He affirms that using PostgreSQL with parameter injection is sufficient for security without needing a full ORM. 

For the project's relatively small data scale (thousands to hundreds of thousands of records), a manual approach to loading aggregates provides transparency and control without significant performance concerns.

Paul explains that the object-relational impedance mismatch primarily stems from different representation forms (object graphs versus relational tables), but becomes less problematic when starting from the domain model and deriving the database structure from it.

He endorses the decision to denormalize certain data (storing LiveEventId and Role redundantly) to simplify LINQ queries, noting this approach is especially safe with immutable data.

Regarding circular references, Paul advises avoiding them where possible to reduce complexity, though they're not inherently problematic if handled properly.

## 2024-05-16 Monadic Composition Limits in C# #140

### Daniel:

Quote ChatGPT:

“Yes, you're correct. The type mismatch is due to the fact that LINQ query comprehension syntax (the from ... in ... syntax) is designed to work with a single monadic type. It becomes more complex when we try to chain monadic operations of different types together.
In your example, you're starting with an Attempt<User> and then trying to chain it to a Validation<User>. The LINQ syntax will expect UserService.ValidateUser(userAttempt) to return Attempt<Something> but instead encounters Validation<User> and throws a type mismatch error.

This is a common issue when dealing with monads in languages like C#, where language-level support for chaining different monad types is not built-in.
A common solution to this "nested monads" problem would be to utilize monad transformers, a specific kind of monad that can encapsulate another monad, allowing for the chaining of operations across multiple different monads. However, monad transformers are not natively available in C#, and their implementation can be quite complex.”
——— 
==> Seems like I’ve hit the limits already Hilarious. GPT Just told me I need to switch to F# !! 🤣😭. And hitting this wall I have now understood for the first time why this actually might be a good idea haha. But not in the next 8 weeks ….

### Paul
I’m not sure whether to give that a 👍 or a 😟. But sounds like good learning in any case.

### Daniel
It’s def. both! I’m glad I hit that wall and now understand much better the boundaries. I’m sticking to C# obviously, it’s already a tight deadline.

Within the same monadic type (I only have Attempt<T>, Result<T>, Option<T>) I can compose to my heart’s delight with LINQ query syntax, thanks to my under-the-hood custom SelectMany (Bind) implementations, which LINQ can utilise.

**But as soon as my workflow involves pipelines with various monadic types, as most real ones will do, I simply need to do the translations manually and/or use nested .Match calls to stay functional. Whatever is more readable in the end.*** 
Note to self: for examples, see my public class MonadicCompositionTests


## 2024-05-12 Paul chat on - Automated Tests for Db Migrations? #139

Based on the conversation between Daniel and Paul, here are the key insights and decisions about database migrations and testing approach:

### Database Migration Strategy
**1** **SQL Schema Migrations**:
	* These are technically "run once" in production but may be run again if setting up a new database from scratch
	* The current process is:
		* Use AI to help generate SQL changes
		* Test on development database
		* Apply to production if successful
**2** **JSON Data Migrations**:
	* C# code is used to migrate historic serialized JSON data when schema changes
	* This ensures backward compatibility with existing data
**3** **Schema Design Philosophy**:
	* Using a very flat database structure
	* Most operational details that might evolve are serialized into JSONB fields
	* Actual database fields represent fundamental entity properties unlikely to change
	* This approach minimizes schema migration complexity

### Testing Approach for Migrations
**1** **Decision on Testing**:
	* For truly run-once code, automated tests are optional and only useful if they help get the code right initially
	* For repeatedly run code, automated tests are recommended
	* Daniel decided not to invest time in automated testing for migrations given project constraints and timeline
**2** **Potential Testing Approach for C# Migrations**:
	* Could seed dev DB with fake old-schema data
	* Run migration
	* Test whether updated data can be deserialized into current models

### Future Considerations
**1** **Production-Safe Migrations**:
	* Should create database structures compatible with pre-migration code
	* Avoid locking database or tables for too long periods
	* Adding indexes can be particularly problematic for locking
**2** **Object Graph Deserialization**:
	* Daniel expressed concern about custom deserialization when object connections are encoded in JSON details
	* Circular references should be avoided in the domain model (DDD principle)
**3** **Database Restoration**:
	* Azure automatic backups/snapshots provide a fallback mechanism if migrations fail
**4** **Future Schema Evolution**:
	* Primarily expected to add new entity types (tables)
	* New foreign keys might be added between new and existing tables
	* Most relationships will be maintained at the object graph level via references in JSON details

⠀The approach reflects a pragmatic balance between best practices and project constraints, with a focus on simplicity and safety.


## 2024-04-26 DI Service Lifetime - My Defaults #136

**1** **Transient** should be used when you need a fresh instance every time you request it during a single function invocation or request processing. This is especially useful for operations where a clean state is essential for each operation within the scope of a single request or function invocation.

**2** **Scoped** should indeed be your default for dependencies that are specific to a single request or function invocation. This ensures that a single instance per request is used, maintaining consistency across operations performed during that request while still providing isolation between different requests.

**3** **Singleton** is perfect for stateless, request-agnostic services like utilities and factories. These services do not maintain any state between requests and provide a consistent behavior regardless of the request context.


## 2024-04-24 Test with real DB #135

Debating with myself whether to use InMemory DB or real Postgres DB for my integration / DAL tests.

~[This](https://github.com/npgsql/efcore.pg/issues/774)~ is a debate with the maintainer of Npgsql library who argues strongly for testing against the real database.

And ~[this](https://dev.to/davidkudera/creating-new-postgresql-db-for-every-xunit-test-2h73)~ is an article how to create a new database copied from a template quickly for each test run. Though I don't think I need this, as I can reconstruct my entire DB from Migration scripts for each test run quickly enough I believe? Also is it for each test, or for each test-run??

Based on these two links, and to have tests that are as realistic as possible, I'm leaning towards running all integration tests against real DB. There will still be plenty of Business Logic / Unit / Functional tests which will run against mocked repository objects without a real DB behind it.

**==> Decision after call with Paul: test against the real DB instead of InMemory for as long as it's convenient!**


## 2024-02 Multi-tenancy (Q5AIP) #133

GPT Summary:

Paul emphasized that true multi-tenancy, where all customer data is housed in a single database stack, is the optimal architecture over any mixed or single tenancy models. He outlined that single tenancy, characterized by separate stacks for each customer, offers complete data isolation at the cost of significant management overhead for developers, including maintenance, updates, and monitoring of multiple instances. This approach dilutes the attention a developer can give to each customer's system. On the other hand, true multi-tenancy flips these strengths and weaknesses, presenting potential risks in data privacy and system performance but significantly reducing operational complexities and ensuring uniform application updates and maintenance. Intermediate steps, such as shared servers with separate databases or separate schemas within a single database, inherit the downsides of single tenancy without realizing the full benefits of multi-tenancy. Paul argues that these models do not constitute multi-tenancy in a meaningful way, as they do not simplify the developer's workload or improve scalability and manageability significantly. He concludes that except for cases involving highly paranoid customers or those in heavily regulated industries, opting for anything other than full multi-tenancy is a misguided choice, often seen as a negative indicator in due diligence processes.


## 2023-Q4 Persistence Strategy (WUTZ4) #132

### **Avoid these event sourcing pitfalls:**

1 Migrate old events to new formats to avoid multi-year build-up of backwards comp. code (--> i.e. 'immutability' of data only holds for current business logic)

2 Don't couple higher level services to the low-level events directly, use abstractions (to retain flexibility of changing core events)

3 Ensure monotonicity (e.g. between events and stored snapshots) --> only ever in one direction

4 Avoid forcing the use of event-sourcing to use-cases where it's not natural (see Luke **~[@griffin](https://github.com/griffin)~** Bank.) - mixing classic and event-sourcing in a single DB is no problem.

### Orthogonality of these 3 dimensions:
- SQL vs. NoSQL
- Tight vs. loose coupling of domain model to storage structure (--> 'flatness' of database)
- Classic vs. event-sourced persistence strategy (is state stored or reconstructed?)


#_typ/logs #prj/biz/cm/dev