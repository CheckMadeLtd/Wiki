# Semantic Versioning

The original [semantic versioning](https://semver.org):

Given a version number MAJOR.MINOR.PATCH, increment the:

1. MAJOR version when you make incompatible API changes
2. MINOR version when you add functionality in a backward compatible manner
3. PATCH version when you make backward compatible bug fixes

As of 2025, we don't offer a library or a public API that other, external developers depend on, so the original definition doesn't apply directly. However, we are defining an equivalent that comes close:

For CheckMade, we increment the:

1. MAJOR version for a significant and visible package of new functionality, typically released each year in the early summer, ahead of the main events season. Server-side changes will certainly break the functionality of any mobile/desktop clients that are not updated.
2. MINOR version for new functionality or visible, cosmetic improvements. New server-side features may require client updates in some cases to make them usable but are guaranteed to not break them.
3. PATCH version for invisible improvements and bug-fixes. Server-side changes are guaranteed not to break clients.

# Azure Services & Telegram & Db Setup

Entire setup from scratch is scripted in the spirit of 'executable documentation'.

See `setup_orchestrator.sh` (in DevOps/scripts/exe/setup/).

## Azure FunctionApp

### Pricing / Lifetime / Toggle

By default our function runs on the free Consumption Plan. 
During events when we need high performance and avoidance of cold-start delays, we toggle to a premium plan with the help of `toggle_plan.sh`

In July 2025 we tried using https://www.cron-job.org for a simple ping every 5 minutes to keep the Consumption Plan function alive, but this didn't work most likely due to Azure's aggressive and smart shut-down mechanism. So we will continue to toggle which is cleaner and fairer than starting to program fake activity per ping. 

See [current pricing details](https://azure.microsoft.com/en-gb/pricing/details/functions/)

### ScaleLimit setting across hosting plans

Until we haven't implemented [cache-safety with multiple instances](https://github.com/CheckMadeLtd/CheckMade/issues/394), we need to limit our function app to a single instance via the `functionAppScaleLimit` setting. 

**Beware this pitfall:**  
  
While this is a setting of the function app (and not the hosting plan) it applies (and persists) separately per type of hosting plan (i.e. separate settings for Consumption vs. Premium Plan). And the only way to set the setting for a hosting plan type appears to be to set it while being on that hosting plan.

Practically this means we need to set it the first time when creating a new function app in the setup script (which would apply to the Consumption Plan) and a second time the first time we toggle to a Premium Plan. 

For reasons of script simplicity, [we chose](https://github.com/CheckMadeLtd/CheckMade/issues/398#issuecomment-3092242991) to set it (redundantly) on every toggle to a Premium Plan, since it's a cheap operation and script simplicity thus is more important. 