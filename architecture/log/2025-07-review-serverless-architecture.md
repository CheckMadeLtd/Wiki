# Serverless Architecture Review - July 2025

## Background and Trigger

In July 2025, we discovered a critical issue with our caching strategy: our static/singleton caches (specifically in `InputsRepository` and `ILastOutputMessageIdCache`) would not be thread-safe across multiple Azure Function instances. While we had been operating with a single instance, Azure Functions can and will spin up multiple instances based on load, and we have limited control over this behaviour. This realization triggered a comprehensive review of our architecture, starting with [this discussion](https://github.com/CheckMadeLtd/CheckMade/discussions/388).  

This document summarises the concerns, options considered and final decision taken.

## Initial Investigation: Redis Cache

Our first instinct was to implement Redis Cache as a distributed caching solution. However, we quickly determined this would be over-engineering for our use case:

1. **Wrong problem**: Redis solves I/O bottlenecks by providing fast distributed cache access, but our actual bottleneck was CPU/memory pressure from repeated deserialization of complex domain objects
2. **Complexity overhead**: Introducing Redis would add another infrastructure component to manage, monitor, and pay for
3. **Limited benefit**: For our B2B scale (hundreds to thousands of users), the complexity wasn't justified

## The ASP.NET WebApp Alternative

Through discussions with @wiz0u, we explored a radically different approach: transitioning from serverless Azure Functions to a long-running ASP.NET WebApp instance. The key insights from this exploration were:

### Proposed Changes:
- **In-memory bot interactions**: Instead of persisting every bot interaction to the database, keep them in memory during the workflow
- **Single instance guarantee**: With ASP.NET, we could ensure a single long-running instance, eliminating cache synchronization issues
- **Simplified state management**: No need to reconstitute entire workflow state from database on each interaction
- **Persistence only on completion**: Save to database only when users complete meaningful actions (e.g., submit a new task)

### Perceived Benefits:
- Eliminate deserialization overhead
- Natural fit for our object-oriented domain (festivals, areas, facilities)
- Simpler debugging with traditional stack traces
- Potential for WebSocket/SignalR real-time features

## The Stateless Counterargument

However, after extensive discussions with Paul and Artem, we recognized the fundamental value of maintaining a stateless architecture:

### Key Insights:
1. **Resilience**: Stateless design provides automatic failover and scaling essentially for free
2. **Deployment flexibility**: Hot fixes can be deployed mid-festival without disrupting user workflows
3. **Technical due diligence**: "We deliberately chose a single-instance architecture" is harder to defend than "We haven't needed multi-instance yet"
4. **Architecture flexibility**: Statelessness allows us to switch between serverless functions, containers, or App Service without architectural changes

### Critical Realization:
The only compelling reason to move away from serverless functions is if we genuinely need statefulness. But do we? With just a bit of additional effort, we can make our current stateless bot workflow management work effectively while maintaining all the benefits of serverless.

## Addressing Specific Concerns

### 1. Background Tasks and Maintenance
**Concern**: Need for long-running background workers  
**Solution**: Timer-triggered Azure Functions can handle all scheduled maintenance tasks without requiring a persistent instance

### 2. Desktop App Backend
**Concern**: Future desktop dashboard needs stateful backend  
**Solution**: The desktop app can maintain its own local state while the backend remains stateless. For push notifications, Azure SignalR Service can bridge the gap without requiring stateful functions

### 3. Bot Interaction History
**Concern**: Current approach saves every interaction, causing performance issues  
**Solution**: 
- Optimize database by storing only inputs relevant to the current workflow (identified by workflow GUID)
- Focus actual persistence on higher level, meaningful domain events (task created, issue reported, etc.) rather than every button click
- To facilitate debugging, implement comprehensive logging of every bot-related input/output (with configurable retention, e.g., 90 days)

### 4. Cache Synchronization
**Concern**: The original trigger problem, see above.  
**Short-term solution**: Configured Azure Functions to use a single instance via settings ([#371](https://github.com/CheckMadeLtd/CheckMade/issues/371))  
**Medium-term solution**: Implement incremental cache updates by checking database for newer entries when cache might be stale (and accept the possibility that each instance will have a full duplication of the cache).

## Future Considerations: Streaming and Reactive Extensions

When we eventually need real-time processing of IoT sensor data or complex event streams using Rx.NET:
- This will require a long-running instance (ASP.NET or Container)
- Can be deployed in parallel to existing serverless functions
- Will likely utilize Azure Event Hub or Event Grid
- Timeline: 2-3 years away minimum (YAGNI principle applies)

## Final Decision

We will maintain and incrementally improve our current serverless architecture:

1. **Continue with Azure Functions** for all bot interactions and API endpoints
2. **Implement intelligent caching** with proper synchronization strategies
3. **Optimize database usage** by limiting stored inputs to current workflows
4. **Use domain events** for meaningful business operations (aligning with event sourcing principles)
5. **Add streaming infrastructure** only when actual requirements emerge

This approach balances pragmatism with architectural soundness, allowing us to deliver value now while keeping options open for future evolution. The stateless design ensures we can scale, deploy, and evolve our system without the complexities of distributed state management.

## Internal Meeting Note References

See diverse meeting notes from 2025-07-11 to 2025-07-14.
