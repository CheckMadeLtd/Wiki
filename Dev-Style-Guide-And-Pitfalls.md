# Dev Style Guide

We follow Daniel's general development style guides:
- [Practices](https://dgor82.github.io/style_guide_practices.html)
- [Coding Style](https://dgor82.github.io/style_guide_code.html)

Here a short summary, details and additional aspects, see links above:
- OOP and SOLID for the organisation of the system but with functional style code (i.e. avoiding imperative code where possible)
- To support our functional style we make use of monadic wrappers: Option<T> and Result<T>. Each of these custom monadic wrappers has custom Select and Where implemented; all needed overloads for SelectMany are also implemented; this means we can chain them in LINQ queries.
- Continuous Refactoring and Simple Design
- Domain-Driven Design (with selective, intelligent, non-dogmatic use of e.g. GoF Design Patterns and Fowler's Analysis Patterns). 
- Following Clean Code and Clean Architecture principles inspired e.g. by the writings of Uncle Bob
- Vertical Slicing
- Design by Contract (DbC) but only on the outer edges of our modules, where they interact with other modules or 3rd party libraries
- Enabled C# Nullable Reference Types (but using Option<T> for explicitly optional values). 

# Pitfalls

We have encountered the following pitfalls in our project and document them to help avoid the team falling into them repeatedly.

## General

### Change code-inspection severity setting for missing enums in switch expressions

```
public enum BotType
{
    Operations = 1,
    Communications = 2,
    Notifications = 3,
    NewValue = 4
}
        
var botCommandMenuForCurrentBotType = botType switch
{
    BotType.Operations => allBotCommandMenus.OperationsBotCommandMenu.Values,
    BotType.Communications => allBotCommandMenus.CommunicationsBotCommandMenu.Values,
    BotType.Notifications => allBotCommandMenus.NotificationsBotCommandMenu.Values,
    _ => throw new ArgumentOutOfRangeException(nameof(botType))
};

```

In code like the above, by default, Rider/Roslyn is set up to only hint at the missing explicit handling of 'NewValue'. In order to rule out such ArgumentOutOfRangeException being thrown, we change the code-inspection severity setting to 'Warning'. Coupled with the convention that we never deploy code with compiler warnings, this means that we do NOT need to wrap such Exceptions in `Attempt<T>`. 

The exact wording of the relevant code-inspection setting is: `Some values of the enum are not processed inside switch expression and fall into default arm. This might indicate unintentional handling of all enum values added after the switch was introduced, consider handling missing enum values explicitly`

### Avoid too general coverage in RetryPolicy

This
```
Policy = Polly.Policy
    .Handle<HttpRequestException>()
    .Or<TimeoutException>()
```
is much better than just
```
Policy = Polly.Policy
    .Handle<Exception>()
```
Too general coverage can lead to inappropriate exceptions being retried, as was the case with `Telegram.Bot.Exceptions.ApiRequestException` because of faulty SendOut attempt being retried as if they were a transient network issue. This uses unnecessary resources, delays meaningful logs or error messages and can even change the nature of the returned exception if the state changes between retries. Bad on all counts! The `ApiRequestException` should have never been retried in the first place. 

Actual implementation for NetworkRetryPolicy uses recursive matching of inner exceptions against `Type[] ExceptionTypesToHandle` to ensure handling also when the main/outer exception is of a non-targeted third-party type (e.g. `Telegram.Bot.Exceptions.RequestException`).

### Use DateTimeOffset for TimeStamps

This is about preventing confusion between relative local time and an absolute, actual moment in time. To represent the latter, which is usually what we want to do:

1. Use `DateTimeOffset` instead of `DateTime` in code
2. Use `timestamptz` instead of `timestamp` in the Postgresql DB

Example where this went wrong before switching from `DateTime` to `DateTimeOffset`:

```
var allCurrentInteractive = 
    allInteractiveIncludingNewInput
        .Where(i => i.TimeStamp > cutOffDate)
        .ToList();

```
  
Bug would have also been fixed by adding `.ToUniversalTime()` to both `DateTime` instances, but switching entire code base to use `DateTimeOffset` instead is the more universal solution.

### Avoid Singletons that hold on to Scoped Services

**Lesson from the following subtle bug!**

The following factory was originally registered as a Singleton, out of habit for factories:

```
internal class ToModelConverterFactory(
        IBlobLoader blobLoader,
        IHttpDownloader downloader,
        IAgentRoleBindingsRepository roleBindingsRepo,
        ILogger<ToModelConverter> logger) 
    : IToModelConverterFactory
{
    public IToModelConverter Create(ITelegramFilePathResolver filePathResolver) =>
        new ToModelConverter(filePathResolver, blobLoader, downloader, roleBindingsRepo, logger);
}
```

However, it is constructed with the `roleBindingsRepo`, a scoped repository service including a cache.

Symptom:  
a user's initial authentication was not recognised by subsequent inputs, the bot kept asking for an auth token.

Cause:  
even on new input i.e. new bot invocation, but on the same function lifecycle, the factory created a `ToModelConverter` using an outdated repository with an outdated cache.

Insight:  
a concrete instance of a Scoped Service will survive a new scope if its referenced by a Singleton!!

Open Question:  
Avoid all Singletons in a FunctionApp as a pattern/habit to minimise chances for accidentally falling into this trap?
After all, our Singletons are very simple and probably reconstitute in nanoseconds on each new function invocation, so the overhead probably minimal at the gain of improved code quality and consistency? 

Answer:  
Probably not! Singletons can be very useful and have their place. See:
- https://github.com/CheckMadeOrga/CheckMade/issues/114
- [Interesting A.I. Recommendation](https://github.com/CheckMadeOrga/CheckMade/blob/28376aee076ed0f1f023ed970ac60df40ab45e3c/SavedAiAssistantConvos/2024-06-26%20Singletons%20vs%20Scoped%20Revisited.md)

### Equality Operators

Context:  
`==` vs. `x.Equals(y)` vs. `object.Equals(x, y)` in the context of value (rather than reference) comparison on reference types.

Despite the fact that `==` with records does value comparison by default, this quickly breaks down for records that contain collections or that implement custom equality comparisons, as is (both) the case for our `ILiveEventInfo` and similar model records. 

Furthermore, if one of the operands is at risk of being `null` in runtime (without knowing so during compile time), then we need to use `object.Equals(x, y)` instead, because this static version of Equals() handles null values correctly.

**Example from `TestRepositoryUtils`:**

```
mockInputsRepo
    .Setup(repo => repo.GetAllAsync(It.IsAny<ILiveEventInfo>()))
    .ReturnsAsync((ILiveEventInfo liveEvent) => inputs
        **.Where(i => i.LiveEventContext.GetValueOrDefault() == liveEvent)**
        .ToImmutableReadOnlyCollection());
```
This code would lead to a wrong `false` on `==` in case `LiveEventContext` and `liveEvent` are of differing concrete `ILiveEventInfo` types (e.g. `LiveEvent` on the left and `LiveEventInfo` on the right). To allow comparison across these record types we have custom equality comparison logic in place.

**Furthermore:**

`.Where(i => i.LiveEventContext.GetValueOrDefault().Equals(liveEvent))`

This code could lead to a NullReferenceException during runtime in case .GetValueOrDefault() returns `null`, which it might. After all, if we were sure that it couldn't, then we'd use `.GetValueOrThrow()` instead.  

**So to address both possible failures...**

The solution in this case is usage of the static version of `Equals()`:

`.Where(i => Equals(i.LiveEventContext.GetValueOrDefault(), liveEvent))`

**Finally,**

compared to `==`, `.Equals()` covers custom equality conversions and allows for parameters e.g. when used with strings e.g. to determine the case sensitivity of the comparison.

**Having said that,**

`==` has its place for simple, safe and highly performant usage, e.g. on value types or booleans, and should thus be the overall default.

### Avoid switch expressions for instance creation based on runtime type parameter

For instance creation depending on a type parameter only known at runtime (e.g. the 'last selected facility' when construction an issue), the initially obvious, static, type-safe approach would be to switch on the type and return a corresponding instance. The problem with that: the clauses in the switch expression would need to be maintained across the codebase whenever a new sub-type is added. This is error-prone and will lead to exceptions thrown from the default clause.  

Instead, use `Activator.CreateInstance()` which works as long as the sub-types all either have a parameterless constructor or constructors with the same parameters (these can then be added to CreateInstance())!

This is the canonical case where the use of reflection is well justified.


## Telegram Bot

### Avoid Telegram Bot API endless retry loop

When sending anything but a `OK 200` response (e.g. `400` or `500`) Telegram's server / bot API goes into retry mode in a never-ending loop which paralyses the bot's normal operation. 

A comment in the code explains why it makes sense for `OK 200` to always be the response, even when our app throws an exception.

### When stuck on `502 Bad Gateway` endless loop in ngrok

When stuck in ngrok, during dev, on a never-ending stream of `502 Bad Gateway` responses, like on 17/08/2024 (see https://t.me/c/1142631927/131880), then understand:
 
1. What is happening is: the Telegram Server keeps trying to reach our bot, via the webhook settings, but can't reach it. 
2. I.e. the issue is NOT that it reaches the Bot and it returns this exception, because our bot only ever returns Status 200!
3. One likely source is a wrong local port, on which the Azure Function launches (i.e. not the default 7071, to which ngrok forwards requests from Telegram Server). In the past, major version Rider update caused change in local port setting. 

If something like this is NOT the cause, one way to allegedly interrupt Telegram Server's never-ending re-attempts is to reset the WebHook. I have now added this option to the Telegram Webhooks script. 

### Medium Length Instruction

- Short instructions followed by an InlineKeyboardMarkup are fine, the buttons will take the length they need, also beyond the length of the instruction.
- Long instructions followed by an InlineKeyboardMarkup are fine, the buttons will be as long as the instruction i.e. fill almost the width of the screen.
- But with 'medium length' instructions we are screwed: the buttons will be narrow, trying to fit into the width of the instruction text. 

It's not quite clear what 'medium' means, at which length it starts and at which it ends. This is a known quirk of the official Telegram Client.

Solution for now: only one button per row. 

## Newtonsoft Json

### Serializer assigns default values

1. I have added the `BotType RecipientBotType` prop to MessageDetails
2. I expected the strict Serializer to fail b/c current db-data doesn't have such a field
3. BUT: The serializer happily serialized, simply assigning the default value ('0') to this Enum prop!

=> Be aware that adding new fields won't cause tests for serializability of old data to fail, and reflect on whether assigning the default value (in-memory) to a new prop in the details of historic data is the intended behaviour (which it might well be).

The newly added `ValidateNoNullProperties()` method in `JsonHelper` class should now throw for any deserialization attempt with missing properties in DB data, forcing us to migrate data and use explicit DBNull values rather than blanks in jsonb details. 

### Custom Conversions (Simple vs. ContractResolver)

For custom serialisation and deserialisation logic, we need to distinguish between two scenarios:

1) Normal types (example: `DomainTerm`)
=> Use a simple converter class

2) Generic types (example: `Option<T>`)
=> Requires use of a `ContractResolver`

See code in `JsonHelper` and related types.

## FluentAssertion (vs. xUnit Assert)

### Should().ThrowAsync()

Forgetting to add an `await` ahead of `myAction.Should().ThrowAsync<ExceptionType>()` does NOT result in any warning but will compile and pass the test wrongly and silently (e.g. even if another type of exception has actually been thrown)!

### Lack of deep comparison with .BeEquivalentTo()

With actual / expectedReplyMarkup of type `Option<IReplyMarkup>`:

This (wrongly and silently!) passes:
```
actualReplyMarkup.GetValueOrThrow().Should()
.BeEquivalentTo(expectedReplyMarkup.GetValueOrThrow());
```

While this (correctly!) fails:
```
Assert.Equivalent(expectedReplyMarkup.GetValueOrThrow(),
actualReplyMarkup.GetValueOrThrow());
```

Turns out, unlike xUnit's `Assert.Equivalent()`, FluentAssertion's `.BeEquivalentTo()` does NOT perform a deep, recursive comparison of the two objects, instead, it expects (allows) fine-grained configuration of comparison behaviour (but again, without any warning to the developer)!

However, even xUnit's `Assert.Equivalent()` (wrongly and silently!) passes this:

```
Assert.Equivalent(expectedReplyMarkup, actualReplyMarkup);
```

Turns out, it only does its deep, recursive comparison on `public` members: when I temporarily change the `Value` member in `Option<T>` from its usual `internal` to `public`, it works as expected!

### Conclusion

Given the above two pitfalls, and despite FluentAssertion's more readable output:

**==> 1. Use xUnit's `Assert` class by default!**  
(and only revert to `FluentAssertion` where fine-grained customisation is needed, if ever)
  
**==> 2. But don't forget to call `.GetValueOrThrow()` when the objects of comparison are monadic wrappers!**

