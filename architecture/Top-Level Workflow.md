Summary of the top-level main workflow (input-output roundtrip) for handling a Telegram bot update:

1. Request Ingestion:
   - One of the bot functions (`OperationsBot`, `CommunicationsBot`, or `NotificationsBot`) receives an `HTTP POST` request from Telegram.
   - These functions inherit from `BotFunctionBase`, which provides a common `ProcessRequestAsync` method.

2. Update Deserialization and Routing:
   - The incoming request body is deserialized into a `Telegram.Bot.Types.Update` object.
   - The `Update` is passed to the `BotUpdateSwitch.SwitchUpdateAsync` method along with the specific `InteractionMode`.

3. Update Handling:
   - `BotUpdateSwitch` determines the type of `Update` (e.g., `Message`, `EditedMessage`, `CallbackQuery`).
   - For supported types, it calls `UpdateHandler.HandleUpdateAsync` and passes the  `Update` in a custom Wrapper (`UpdateWrapper`) which improves/simplifies/unifies the Update's representation for the purposes of our subsequent code.

4. Conversion to Domain Model:
   - `UpdateHandler` uses `ToModelConverter` to transform the Telegram `Update` into a `Input` domain object.
   - This process includes resolving file paths, handling attachments, and identifying the originator's role.

5. Input Processing:
   - The converted `Input` is passed to an appropriate `InputProcessor` (based on the `InteractionMode`).
   - The `InputProcessor` generates a collection of `Output` objects and enriches the `Input`.

6. Output Generation:
   - `OutputSender` takes the `Output` collection and prepares it for sending back to Telegram.
   - It resolves the correct `BotClient` for each output based on the `InteractionMode` (and in non-default case uses `LogicalPort` to resolve destination Agent that is different from source of current Input).
   - `OutputToReplyMarkupConverter` is used to create appropriate Telegram reply markup (e.g., inline keyboards, reply keyboards).

7. Response Sending:
   - The prepared outputs are sent back to Telegram using the appropriate `BotClientWrapper` methods.
   - This may include sending text messages, documents, photos, voice messages, or locations.

8. Finally, save to DB
   - Based on actual message-send parameters returned from prev. step, now saves the enriched Input, any corresponding derived data and the actually sent Outputs to the DB.

9.  Error Handling:
   - Throughout this process, errors are captured using our custom `Result<T>` monad.
   - Errors are logged, but a `200 OK` response is always returned to Telegram to prevent endless retry loops.

This workflow represents a clean separation of concerns, with distinct steps for input processing, domain logic, and output generation, all wrapped in a functional-style error handling approach.

