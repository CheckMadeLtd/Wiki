# I) CheckMade vs. Telegram.Bot Namespace - Disambiguation / Conventions

It is important to disambiguate types in the `Telegram.Bot` namespace from types in the `CheckMade.Core` namespace. Some have overlapping names e.g. `ChatId`, denoting equivalent concepts. Ultimately, types in the `CheckMade.Core` namespace are meant to be agnostic to the specific choice of the underlying Bot technology choice (Telegram for now). The overlap happens where no abstraction from the Telegram implementation to the CheckMade domain seemed useful. 

Furthermore, `Telegram.Bot`'s name for an incoming message from the user to the bot is `Update`. Once we converted it to our model representation, we call it `Input` (analogous to the response our function returns which is an `Output`). 

# II) I/O & Authentication Model

To understand the I/O between our software and Telegram (and thus our Bot's user interaction model), some mapping needs to take place between concepts/types on both ends. [This diagram](https://github.com/CheckMadeOrga/CheckMade/issues/60#issuecomment-2156138217) is an early attempt at visualising the mapping relationship and interface. While somewhat outdated, it serves to highlight two central ideas:

1. It's helpful distinguishing between these three spheres:  
- 'Telegram Client' (e.g. the mobile app our users use)
- 'Telegram Server' (where the Bot(s) are hosted, which are accessed from our software via the `BotClient` object)
- 'CheckMade' (i.e. our cloud-based business logic and database)

2. There is mapping that needs to happen between concepts or entities in the three spheres.

## Current Implementation

### 1) The Agent Type
`Agent` encapsulates
- `UserId` (uniquely identifying the Telegram Client user)
- `ChatId` (identifying the current chat on the Telegram Client, in which the user sent a message)
- `InteractionMode` (specifies which of the three Bots (Operations, Communications, Notifications) is present in the chat)

The unique combination of all three constitute a `Agent` because they allow our software the simultaneous and unambiguous resolution of two things:  
a) a ('physical') destination on the user's device's Telegram Client for outputs / responses and  
b) a real-world actor who can be held to account (e.g. for completing a task) or gain access-privileges, all by being assigned a `Role`.

Note: most normal users (workers) will have a direct, private chat with each Bot, and in that case `UserId == ChatId`, however that doesn't mean these two can be conflated, otherwise the system breaks down for group-chats that include the bot (with one or more users).

Group-chats with a Bot included can serve at least these two purposes:
- Allowing more senior users to operate as multiple Agents i.e. in multiple Roles simultaneously. The groups would be given corresponding, meaningful titles. 
- In the future potentially enabling actual direct chats between users, where the `CommunicationsBot` may act as a facilitator, participant and moderator (including possibly invite needed group members e.g. via `CreateChatInviteLinkAsync`).

### 2) Agent to Role Binding

**Fact-1**: An `Agent` exists independent of any connection to the CheckMade Setup.  
=> Anyone in the world can publicly find one of our bots and start a chat with it. 

**Fact-2**: A CheckMade `Role` (uniquely linked to a particular `User` and `LiveEvent`) exists independently of any `Agent`.  
=> These entities can be created as part of the CheckMade Setup without ever 'coming alive' via a real user.

In order for a `Role` to come alive, a real user on a real device in an actual chat (i.e. a `Agent`) needs to authenticate themselves with a token that is unique to a `Role` and that represents a secret held in the CheckMade Setup data. The secret token is passed to a real user via a secure channel (e.g. via a known communications link or orally on the venue).

The successful authentication with this token uniquely binds the `Agent` to a `Role` and this binding is saved as a `AgentRoleBind` in the corresponding `agent_role_bindings` table. Each `AgentRoleBind`'s history is documented via an activation and deactivation date and a current status, which is important e.g. for later interpretation of raw input data.

This model implies that one and the same `User` can act in different capacities at the same time, by having more than one `Role` and operating via more than one `Agent`. E.g. user 'Lukas' can be the `Sanitary_Admin` for `LiveEvent` 'Hurricane 2024' via a group-chat (e.g. with id `-45213698`) while at the same time acting as `SiteCleaning_Admin` in another group-chat (e.g. with id `-75863214`) at the same (or even at a different) `LiveEvent`!

### 3) LogicalPort to Agent Mapping

- `Role` (e.g. John as the `RoleType.Sanitary_Inspector` at `LiveEvent` 'Parookaville 2024')
- `InteractionMode` (Operations, Communications or Notifications)

It makes sense for the workflow/business/domain logic to determine these two dimensions only, when specifying an output's destination. It shouldn't know or care about specifics of the communication channel (in this case Telegram).

Note: a `LogicalPort` is only explicitly defined by the business logic when it deviates from the default which is simply sending the bot's response back exactly to where the `Input`, to which we are responding, came from in the first place. An example for the need of a deviating, explicit `LogicalPort` is a notification about a reported issue to another user, e.g. a supervisor. 

The `OutputSender` class (in `CheckMade.Bot.Telegram`) finally does the actual mapping from the `LogicalPort` it receives from the `CheckMade.Bot.Workflows` into the `Agent` it needs to resolve the right Telegram `BotClient` and send the `Output` to the correct chat on that client.  

# III) Telegram's MessageId Counter Logic

- Super-Groups and Channels have their own `MessageId` counter, but are likely of no relevance to CheckMade.
- For private chats and small groups, every Telegram account has its own counter.
- This per-account counter increments sequentially for both, `Input` (Telegram's `Update`, except callback-queries, see below) as well as `Output` messages. 
- Callback-queries (i.e. a user clicking on an `InlineKeyboardButton`) do NOT increment the `Messageid` but instead use the original one associated with the bot message containing the `InlineKeyboard`. Callback-queries have their own, separate unique id (a string) but our model currently doesn't work with it. 
- A Telegram account can be that of a real user or that of a Bot.
- In our code, we ONLY have access to the `MessageId` counters of our Bots. We can never access or know the `MessageIds` of the Telegram accounts of our human users. 

- --> Each CheckMade Bot therefore has its own counter that represents both, `Inputs` and `Outputs`.
- --> To uniquely identify a message sent by a Bot and seen by a particular user, we need the combination of `ChatId` and `MessageId` (as reflected in our `WorkflowBridge` record). 

**Careful:** if we will ever have groups with more than one of our Bots in them: in that case the SAME message would be represented by two different `MessageIds`, depending on which Bot's perspective we choose. It's an unlikely scenario for us though.

# IV) Guide to Telegram Bot UI Elements

## ReplyKeyboard vs. InlineKeyboard

Initially, we used InlineKeyboard only for statically determined commands and options (`ControlPrompts` and `DomainTerms`) and ReplyKeyboard for reply options determined dynamically (i.e. at runtime) e.g. sanitary camp selection. We then realised this distinction is very programmer-centric and meaningless for the user. Therefore the new guidance as follows:

**In general, [`InlineKeyboard`](https://core.telegram.org/bots/features#inline-keyboards) is preferable and should be the default.**

It's a better U.I. experience, stays attached to the prompt message, can be edited in-place (very fast) and allows parallel actions (if desired). For long list of options (e.g. sanitary camp selection), it offers the entire vertical screen space for scrolling (inside the chat window). 

[`ReplyKeyboard`](https://core.telegram.org/bots/features#keyboards) should only be used as an exception in the following very special/rare cases which are not covered by the `InlineKeyboard`:
- When the user should be able to do both: 
  - choose from predefined options AND 
  - type in their own answer which is different from the options
- [ForceReply](https://core.telegram.org/bots/api#forcereply), which forces the user to reply to a specific message from the Bot
  - Keeps the user focused on that reply, he can't do anything else
  - From a processing POW: allows us parsing out the message to which user replied (but not relevant when anyway saving dialogue state as CheckMade does)
