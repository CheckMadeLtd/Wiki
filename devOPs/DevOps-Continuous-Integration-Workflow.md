- - - - - - - - - - - - - - - - - -  
First read my [high-level CI workflow summary](https://dgor82.github.io/style_guide_practices.html#continuous-integration-ci)  
- - - - - - - - - - - - - - - - - - 

# Scripts supporting the CI Workflow

The above CI workflow can be handled manually by the dev, but we have shell scripts to automate many of the manual/repetitive tasks associated with it:
- start_work.sh
- finish_work.sh
- clean_up_local_branches.sh

The scripts can be found in `DevOps/scripts/exe/ci_workflow/`

## Start Work Script
Do daily dev work on a `tmp/*` branch to allow for regular pushing to GitHub (for backup) without triggering the CI/CD workflow every time (to save GH Runner resources). To start developing on a new `tmp/*` branch, run the 'start_work.sh' script which does this:
* Checkouts to and updates the local `main` branch
* From `main`, checkouts into a new branch by name of `tmp/[randomly-generated-alphanumeric-string]` (the branch will get a meaningful, summarising name in the next step, when work on it was finished)

## Finish Work Script
When done developing on the current `tmp/*` working branch, run the 'finish_work.sh' script which does this:
* Updates local tracking branch `origin/main` with any new commits (e.g. those made by other devs) since you branched off from it in step-1.
* Checks whether your working branch still is a direct ancestor of `origin/main` 
    * if that's not the case, **rebases** (!) your working branch on the newly updated `main` branch. This essentially rewrites history, pretending that you have made your current local developments on top of the very latest developments of others.
* Restores dependencies, builds solution and runs tests for the configured Debug configuration. This step ensures that everything still builds and passes all tests - and is especially important in case your working branch was rebased on other devs' changes in the previous step. 
* Shows current (semantic) version and asks you for a new one. Then:
    * Updates version.txt in the solution root
    * Updates any relevant version tags in .csproj files 
* Checks out to a new branch, and asks you for its name, which should represent a meaningful summary of all your commits and will be used as the title for a new PR. 
    * The script automatically prefixes the branch name with `fb/` which, by my convention, is the required workflow trigger pattern. 
* Pushes the new branch to `origin` and thus triggers the fb_workflow in GitHub Actions which in turn creates the relevant PR.

### The triggered fb/* Workflow
GitHub Actions Workflow on the `fb/*` branch is triggered by the Finish Work Script. It
creates a corresponding PR from your feature branch.

**Note:**
This should also automatically generate a GitHub Project Todo for post-merger review. This can be set up in the 'default workflow' settings in the GitHub Project U.I. found under: https://github.com/orgs/YOUR_ORG/projects/YOUR_PROJECT_ID/workflows

### The main Workflow
GitHub Action Workflow on `main` branch is no longer triggered by the previous workflow, instead, given strict PR review rules and permissions, it is triggered by manual PR review and squash-merge. It does this:
* Based on version.txt (which was updated in the 'Finish Work Script' above), creates and pushes a new version tag to the latest commit
* Uses a matrix strategy to run build & test jobs for all Non-iOS deployment projects (for the future: iOS builds require 10 x more expensive, separate macOS GitHub Action Runners or local mac build machines)
* CD: Deploys any non mobile app code (e.g. cloud-based backend services or browser-based client software etc.). 

**Note:** The build & test run here obviously uses the 'Release' configuration (for testing with maximal realism) and runs for each top-level project (e.g. Bot / Functions) marked for deployment as per GitHub Runner strategy matrix. Earlier, as part of the 'Finish Work Script' (see above) build & test was run on the local dev machine for Debug_x configuration (for testing with maximal debuggability). This combination of both build & test cycles should give us redundancy and complete coverage.

## Clean-Up Branches
After several iterations of the above CI flow, multiple outdated `tmp/*` and `fb/*` branches will have accumulated in the local git repository. The 'clean_up_local_branches.sh' script iterates through all of them and allows you quick & easy force deletion. 

On remote/origin, there shouldn't be any `fb/*` branches left thanks to the configured auto branch deletion after PR mergers. There might be old `tmp/*` branches accumulating though from backup pushes during dev work. These should periodically be deleted (for now manually via GitHub U.I. or from the IDE).