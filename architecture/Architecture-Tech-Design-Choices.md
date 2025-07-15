# I) Solution Structure

## Monorepo

The entire system in a single .NET Solution as a modular monolith!

## Frontend Clients
- Telegram Bot
- Desktop-based app for reporting & admin/back-office dashboard

## Backend
- Shared backend code / domain model across all clients
- Azure as PaaS Provider
- Serverless Functions by Default
- Cloud-based relational (but fairly flat) database for all operational data (including IoT streams)

## Solution Configurations & Project Setup

While the Monorepo comes with huge advantages, the implication is that we need to work with different 'Solution Configurations' so that client-specific Debug_* configurations become possible. This allows for
* faster builds during development (e.g. avoiding rebuilding any Desktop projects when working on pure backend code or the Telegram Client) 
* selective builds during C.I. on the other hand are achieved by building the top-level project for each client / deployment rather than the entire solution (this automatically only builds the needed dependencies).

### Handling of new Projects

When adding new projects to the solution, take note of the following items to maintain consistency with our approach to Solution Configuration as well as clean project config. **Once we get custom project templates to work, this could replace some of the manual steps**

#### In the *.csproj file

1. Remove settings like 'Nullable' and 'ImplicitUsings' and 'TargetFramework' which are determined globally via Directory.Build.props
2. Make sure the 'Configurations' property in the .csproj contains exactly those configs that actually build this project (the IDE seems to mess this up) + the No_Build config. For better understanding, see [this ChatGPT chat](https://chat.openai.com/share/bb173a38-dd60-40bd-9df5-e992ab6ed86c).
3. Copy the Debug_ vs. Release compilation conditions from other Class Library projects (except for Test projects).  

#### Workflows & Scripts

* Verify the GH Actions main workflow is still accurate in terms of its reference to projects (this should only require updates when a new type of client is added or fundamental changes in naming scheme of existing projects)
* Verify the finish_work script, in terms of including / excluding Debug_ configurations for build&test is still accurate

# II) Choice of Application Frameworks & Libraries

The choice of frameworks and development tools reflects the idea to leverage the dotnet ecosystem to the fullest degree, minimising cross-ecosystem friction points. Yes, to a certain degree this means vendor lock-in with Microsoft. We believe, as a bootstrapping start-up, this is a pragmatic trade-off to make.

We also believe, sticking A single tech ecosystem (and even programming language) is an important business priority and a best practice. It helps reduce complexity and allows everyone on our future team to understand / work on / stand in for both, back- and frontend code. 

## Telegram.Bot

The primary, end-user/field-worker-facing application is the publicly available Telegram client. It allows users interaction with our software via Telegram Bots. We use the [.NET Telegram.Bot](https://github.com/TelegramBots/Telegram.Bot) library to program three bots that give users access to different types of interaction:

#### 1. Operations Bot
Allows users to proactively perform operations (like submitting a new issue or processing their tasks) without being interrupted by incoming messages.

#### 2. Communications Bot
Allows field-workers to contact and chat with other field-workers based on their role (i.e. without necessarily knowing their real-life contact details). The communications bot may, in the future, also participate in or help manage actual Telegram group chats set up by users for specific purposes (think 'channels').

#### 3. Notifications Bot
For a constant stream of relevant notifications that don't necessarily require a response. However, some notifications may offer actions via InlineKeyboards that may e.g. launch an operation or communication via the other bots.

Update 21/03/2025:
We will review whether the Operations and Notifications Bot can be merged such that non very-time-critical notifications get queued and only shown when the user has finished their current operation. This reflects the fact that many notifications will be actionable and show corresp. buttons and thus we'd avoid an unnatural switch from one bot to the other when responding (e.g. accepting a task). 

## Desktop Back-Office App

Here the main decision is between a web-browser vs. native-desktop app.

**Constraint-1:** Avoid using both (e.g. web for reporting and app for setup / custom map) to prevent proliferation of clients and technologies. 

**Constraint-2:** Expecting sophisticated U.I. and performance needs for the back-office to enable advanced features like drawing custom maps or multi-window, real-time tracking of operations.

**Constraint-3:** Deployment and updating needs to be fairly easy and convenient and as automated as possible.

**Constraint-4:** Availability of advanced, ready-made U.I. controls and components to accelerate front-end development.

- Overall: while a web-app would beat a native-desktop app on constraints no. 3 & 4, the latter far outperforms the former on the other two constraints, which are of higher priority. 

- Re constraint-3: with convenient deployment via Windows and macOS App Stores and automatic updating via install frameworks/tools like [Squirrel.Windows](https://github.com/Squirrel/Squirrel.Windows), [NSIS](https://nsis.sourceforge.io/Main_Page) or [Wix](https://wixtoolset.org) for Windows and [Sparkle](https://sparkle-project.org) for Mac, the deployability and updateability of native desktop apps is much better than in the past, mitigating the relative deficiency. 

- Re constraint-4: while HTML / JavaScript or Razor / Blazor have vastly more U.I. components available, AvaloniaUi / XAML have some and the ecosystem is growing fast. Besides, it's always possible to embed a web-view inside a desktop app if a particular web-U.I. component would be irresistibly convenient to use.
  
**--> Decision:** Native desktop app.

See [this detailed conversation](https://chat.openai.com/share/0b63fa31-cfca-44ca-9ce3-870c37257ac7) for more details.

# III) Persistence

## Paradigm

`From [WUTZ4]`
- We use a relational database (Azure Cosmos DB for PostgreSQL) but with a very flat schema:
  - Only the highest level domain aggregates / objects are represented in relational manner (e.g. festivals, camps, users, roles, messages) but all details are serialised into JSONB 'details' fields
  - This minimises the need for risky and complex SQL migrations as the schema evolves (see also [DevOps> Schema Evolution](/devOPs/Schema-Evolution.md))
  - Serialising details:
    - Potentially includes lower level domain entities within aggregates
    - Includes details of higher level domain entities (aggregates)
    - Includes data streams from IoT or external plug-ins
      - See [Azure Stream Analytics for PostgreSQL](https://learn.microsoft.com/en-gb/azure/cosmos-db/postgresql/howto-ingest-azure-stream-analytics)
    - When historic details data needs to catch up with the schema's evolution, write separate software to migrate existing data into the newer format to keep it compatible and to keep the need for handling backwards compatibility away from our Repository objects (again, see: [DevOps> Schema Evolution](https://github.com/CheckMadeOrga/CheckMade/wiki/DevOps--Schema-Evolution)). 
  - Leverage PostgreSQL's indexed, native and extensive support for JSONB queries
    - [How to query a JSON column in PostgreSQL](https://popsql.com/learn-sql/postgresql/how-to-query-a-json-column-in-postgresql)
    - [PostgreSQL Docs on JSONB Functions](https://www.postgresql.org/docs/9.4/functions-json.html)

- Event Sourcing for OPs and Updatable Details (favours functional programming compatibility)
  - Applicable to:
    - Data from everything normal users do as part of their operations
      - Example: the current state of a todo-task is derived from the history of all messages / updates to / transitions in relation to that task, rather than saved explicitly.
    - Updates of details  (e.g. value objects inside of domain entities)
      - Example: update to address of a vendor serialised into 'events' i.e. every update to address gets serialised and stored as a new JSON string update.
  - Not applicable to:
    - High-level, 'setup-related' entities like festivals, venues, trades, vendors, users etc. 

- For future data warehousing:
  - First, fully exploit analytic possibilities based on queries / views against the main OPs DB.
  - Only when hitting performance or cost limits with that approach we shall partially denormalise / consolidate / deserialise data for reporting purposes into a separate custom warehouse db - possibly in the [Microsoft Fabric](https://www.microsoft.com/en-us/microsoft-fabric) / Power BI ecosystem. 


## Multi-Tenancy

Do real multi-tenancy i.e. a single shared server instance AND single shared database! No in-between! See details in this [discussion](https://github.com/CheckMadeLtd/CheckMade/discussions/133).

## Implementation Notes

Last Updated 21/03/2025

### 1) No Data Access Layer (DAL)

`From [JHQ5T]`

Our `Repositories` now encapsulate all the actual DB-specifics. A further abstraction layer (DAL) would be considered in the future only when needed - but at this stage of the project it seems like over-engineering. It could well be that our current setup with PostgreSQL accessed directly via the [Npgsql](https://github.com/npgsql/npgsql) Library outlives most other aspects of our architecture and further abstraction won't be required anytime soon.

### 2) Entire Setup In-Memory

On every function invocation the entire set of 'setup data' (i.e. everything except the history of inputs or future IoT streams) will be loaded into memory and made available to our business logic for convenience, via a handful of aggregates: `LiveEventSeries` (containing `LiveEvents`, in turn containing `SpheresOfAction` etc.). 

Yes, this will contain a lot of setup data that won't be needed in every invocation, but since only stable, real-world entities are represented, this will be a miniscule amount of data for the function to handle on each call. Optimising this might only become necessary once we get into territory of huge commercial success. 

For a useful distinction of the different object-graphs that can be constituted in-memory, depending on code flow, see notes/diagram under [Domain Model](Domain-Model.md).

## Summary

This persistence strategy is designed to ensure our system remains scalable, flexible, and maintainable, leveraging generic and widely-used technologies and code-first patterns (like code-managed consistency, and LINQ for application-level queries). This will support our Vertical SaaS's USP while minimising risk of more exotic technologies (like event-sourcing-specific databases) or dead-ends one can manoeuvre into with frameworks (like sync frameworks or heavy O/RMs). Overall we seek to align with FP principles and avoid the SQL complexity-trap typically associated with schema / domain model evolution. 

# IV) Stateless Architecture

[This architectural review](2025-07-review-serverless-architecture.md) in July, 2025 has led to a reconfirmation of our stateless server-side architecture. 