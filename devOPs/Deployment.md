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
