## Overview & Examples

To support the complex logistics around and during festivals in the future, we (CheckMade, with input from eveCon GmbH) have developed a ChatBot workflow toolkit for programmers. This can be imagined as a Lego set for all kinds of workflows. Thanks to our innovative toolkit, each new workflow can be developed in just a few days.

The goal and purpose of this year's test deployment is to test the toolkit system with two concrete workflows in the trades of sanitary cleaning and site cleaning, and to gather detailed requirements for future workflows. By summer 2025, we should then cover all important workflows in several trades, which will include intra- and inter-trade coordination as well as comprehensive reporting to the overall festival production manager.

Here are a few examples of workflows, roughly divided into the types:
- Task Management
- Navigation/Localization
- Communication/Coordination
each either intra- or inter-trade related.

### Example-1

Type: Inter-trade Task Management
Trade: Sanitary, Sanitary Cleaning (sub-trade)
Involved Roles: Inspector (e.g., from Sanitary Cleaning), Engineer-1 (Sanitary), Engineer-2 (Sanitary), Trade Admin (Sanitary)

Example Workflow:
1. Inspector goes to inspect Sanitary Camp 3.1D
2. ChatBot automatically checks in the Inspector at 3.1D thanks to LiveLocation GPS tracking on mobile
3. Inspector finds a broken shower and reports it in the ChatBot in a few steps (each step is just a click on pre-made, sequential buttons - little to no typing necessary):
   [/new_issue]
   [🔧 Technical]
   [🚿 Shower]
   [Evidence photo(s)]
   [Optional problem description]
   [Submit]
4. A brief summary of the problem (including photo and request to take on this task) initially goes only to Engineer-1, who is currently very close to Sanitary Camp 3.1D.
5. Engineer-1 declines the task because he wants to start his lunch break.
6. The problem is now reported via ChatBot to all engineers, a kind of tender.
7. A pre-configured deadline (e.g., 5 min) expires and no other engineer has taken on this task. Engineer-2 is on duty and nearby, but has his phone on silent and misses the notifications.
8. The ChatBot now automatically escalates the matter to the Sanitary Trade Admin as a priority item with an urgency notice.
9. The Trade Admin asks the ChatBot to show which other engineers are currently available nearby, finds Engineer-2 on the list and contacts him via walkie-talkie (we continue to consider walkie-talkies irreplaceable, but plan future integration with the ChatBot).
10. Engineer-2 apologizes for the previously missed notifications in his ChatBot and now takes on the still open task (simply by pressing a button).
11. Engineer-2 repairs the shower and reports completion (optionally including evidence photo).

### Example-2

Type: Intra-trade Task Management
Trade: Sanitary Cleaning
Involved Roles: Inspector, Cleaning Supervisor, Trade Admin

Example Workflow (essentially a variation of Example-1):
- Instead of a broken shower, the Inspector reports insufficient cleaning performance.
- In this case, the Cleaning Supervisor assigned to Sanitary Camp 3.1D receives a corresponding task.
- If the Sanitary Camp is divided into sub-areas, the affected sub-area can be specified.
- Ditto for individual facilities (shower cubicles, toilets, etc.), if they have a designation (the sub-areas and facilities would be pre-entered in the ChatBot's database as part of the setup data).
- If the issue isn't resolved/cleaned within x minutes --> escalation to Trade Admin. Etc.

### Example-3

Type: Intra-trade Navigation/Localization
Trade: Site Cleaning
Involved Roles: Trade Admin, Various Site Cleaners / Subcontractors

Example Workflow:
1. The Trade Admin walks the grounds and defines various cleaning zones, which are designated and stored in the database with their GPS coordinates via ChatBot operations.
2. Later, the Trade Admin can assign the designated zones to individual subcontractors/employees.
3. Each employee receives the corresponding instruction on their ChatBot (including a pin on a small, displayed map) to go to their assigned zone.
4. The Trade Admin optionally receives notifications when employees arrive within a radius of x meters around their assigned zone and/or when they leave this radius.

### Example-4

Type: Inter-trade Communication/Coordination
Trades: Sanitary, Sanitary Cleaning
Involved Roles: Both Trade Admins

Example Workflow:
1. Sanitary Trade Admin reports completion (setup) of Sanitary Camp 1.6 to the Sanitary Cleaning Trade Admin.
2. In the future, this notification could also happen automatically, e.g., when certain tasks/milestones in the setup of the sanitary camp have been completed.
3. Sanitary Cleaning Trade Admin acknowledges the information and/or confirms the readiness of their subcontractors.
4. The ChatBot automatically notifies the cleaning subcontractor (or their cleaning Team Leader) responsible for Sanitary Camp 1.6 (according to stored setup data).
5. The Cleaning Team Leader can now move in with their team of cleaners to Sanitary Camp 1.6 for the initial cleaning. The pin on the map sent by the ChatBot helps with navigation (thanks to GPS coordinates of all sanitary camps stored in setup data).

### Example-5

Type: Inter-trade Communication/Coordination

General Use Case:
An employee E1 in role R1 in trade T1 needs to contact an employee E2 in role R2 in trade T2, whom they don't know by name, for a quick, direct, uncomplicated clarification without going through the trade hierarchies. However, they don't know each other and don't have each other's phone numbers. Now E1 can request a chat with "an R2", the ChatBot mediates and adds E2 to a chat group. E1 and E2 can now chat with each other and solve a problem without ever leaving anonymity.

Example:
Dirk (E1), an engineer (R1) from the Sanitary Trade (T1) has left some debris while repairing a shower. He wants to contact the responsible cleaning supervisor (R2) from the Sanitary Cleaning Trade (T2), but of course doesn't know that it's Patrick (E2). Dirk asks the ChatBot to forward a message and Patrick can confirm or even ask a follow-up question, e.g., request a photo (so he can better assess what cleaning equipment or how many people he needs to bring). Dirk and Patrick interact through their roles, mediated by the ChatBot, and never need to know their actual identities, let alone contact details. The exchange is recorded in the database (like everything else) and can be included in the evaluation later.

## Comprehensive Reporting

Each of the steps mentioned in the examples, i.e., every operation, every input to the ChatBot, is recorded in the database with all details, leading to thousands of data points per festival. Based on this, arbitrarily aggregated analyses and reports can be run after the festival (already this season) or in the future also in real-time during the festival (from 2025 onwards).

For example, the average response and problem resolution time of subcontractors could be compared, or long-term performance trends could be viewed (thanks to year-on-year comparisons), or the number of subcontractors' employees who actually showed up could be recorded, e.g., as a reality check against the invoiced service.

All this creates unprecedented transparency for all involved, especially for the overall festival production manager.

## CheckMade ChatBot - Current Technology

Thanks to the ChatBot-based CheckMade workflow toolkit, any conceivable combination of task management, categorized problem reporting, navigation/localization, communication/coordination, escalation, etc. within and between trades can be developed with relatively little effort, while guaranteeing that the ChatBot works smoothly on any type of smartphone (iPhone and Android). This flexibility and performance is due to our highly innovative combination of the latest technologies and programming techniques with the world's technologically leading ChatBot platform (Telegram, with 900 million active monthly users).

Details on the technology for those with a deeper technical interest:
- Our workflow logic is programmed in Microsoft .NET (C#) technology
- The CheckMade server-side software (Azure Serverless Function App) and the database (Cosmos DB for PostgreSQL) are hosted on Microsoft's Azure Cloud in Europe and benefit from Azure's high standard for security and scalability, and are accordingly subject to GDPR.
- The messages between users and the ChatBot are encrypted in transit (thanks to the Telegram platform), so they can neither be intercepted nor viewed by 'bad actors'.
- Minimal data volume required for communication between user and ChatBot (on average only a few kilobytes per operation), which is particularly important in the festival environment with often somewhat limited 4G/5G (employees can also switch to the WiFi available in the sanitary camps if necessary).
- Event-Sourcing (append-only) as an approach for data storage for very high system reliability. The chance that the state of the festival is incorrectly represented due to bugs is minimized thanks to Event-Sourcing. Specifically, this means:
  1. Every event, every message, every button press from every employee is stored as an immutable data point in the database, including millisecond-accurate timestamp.
  2. With each invocation of the Function App (e.g., when a message is sent to the ChatBot), the entire current state of the festival is recalculated based on the immutable history of all events up to that point.
- The entire CheckMade source code is publicly viewable and commentable thanks to the Source Available approach. We believe that all involved parties can only benefit from this 100% transparency.

## CheckMade ChatBot - Future Technology & Features

### 1. Guaranteed availability for the 2025 season

- All workflows mentioned in the 5 examples at the beginning, as well as many other workflows of this kind, depending on jointly developed requirements
- Integration of the OpenAI API (i.e., the AI behind ChatGPT) into our ChatBot, to enable features such as:
  - An employee simply sends a photo of a problem (e.g., broken fence) and the AI automatically recognizes the problem and assigns it to the responsible trade/employee as a task.
  - The AI generates mini-reports for trade admins and overall festival production managers, e.g., hourly summarized (a short paragraph), where the most important trends and events are briefly summarized.

### 2. Long-term plans

If technical integration with the walkie-talkie system proves feasible, the AI also enables the following features:
- Walkie-talkie messages are fed into our ChatBot and, thanks to AI, understood and transcribed, thus becoming part of the overall documented history.
- ChatBot can, if needed (e.g., in case of corresponding urgency), generate walkie-talkie messages and send them to a specific employee's walkie-talkie or to a corresponding channel.

Integration of the Azure IoT System (Internet of Things). Examples:
- Every shower has a temperature sensor and reports on its own when the water is cold 
  --> ChatBot generates corresponding task for corresponding engineer.
- Every rubbish bin has a fill level sensor, requests emptying on its own when 90% fill level is reached
- Dozens of other examples for process automation thanks to IoT & ChatBot combination are conceivable.

Accreditation of all employees, for many or all trades, as they need to be registered with us in some form for the ChatBot anyway. This saves the use of a separate accreditation system. Alternatively: Integration with existing systems.

Future integration of ThinkGeo, the leading provider of Geographic Information Systems (GIS), i.e., maps that can be filled with own data and logic.
- On GIS basis, e.g., visualized/localized reporting for trade admins and overall festival production manager.
- In the long term, the representation of every relevant zone and every relevant object on this festival map. The further you zoom in, the more details you see. All objects on the map know their current state, thanks to the previously described Event-Sourcing data strategy. This represents the fulfillment of our long-term vision: The complete digital twin of the festival comes to life!