# Promoting a commit to the marketplace listing

How a widget change gets back onto [plugins.omarchy.org](https://plugins.omarchy.org). The marketplace will not do it on its own.

Verification is bound to one exact commit. The listing reads `Snapshot verified` only for the `listingValidatedCommit` recorded when it was approved. Once a catalog check observes a newer commit upstream, the status becomes `Update unverified`. Nothing warns us, so a one-line fix degrades the listing quietly until someone files a promotion.

`Update unverified` means uncovered, not unsafe. The marketplace is saying the newer code has no evidence behind it yet. Rerunning the old approval does not fix it, because only a promotion moves the recorded commit.

## Procedure

1. Land every change first. A promotion targets one commit, so anything merged afterwards reopens the gap. Promote when `master` is where you want it.

2. Read the full SHA. The form needs all 40 characters.

   ```sh
   git fetch origin && git rev-parse origin/master
   ```

3. Open the [Plugin verification form](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=verify-plugin.yml) and select `Verify and publish a newer upstream commit`. The other two options only accept the commit already recorded, so neither can carry an update.

   | Field | Value |
   | ----- | ----- |
   | Plugin ID | `espadat.tagwerk` |
   | Repository URL | `https://github.com/espadat-studio/omarchy-tagwerk` |
   | Target commit | the SHA from step 2 |

   Tick the verification acknowledgment. The standard-installation checkbox does not apply, because this listing has no manual-install override.

4. Wait for the bot. Opening or editing the issue runs compatibility validation and the Automated Security Baseline against that exact commit, without executing our code. Expect `passed` with no findings and no capabilities. Editing the issue retries a failed or corrected request.

5. Wait for a maintainer to apply `approved-and-verified`. It is the only label that publishes an update. Approval replaces the validated commit, the catalog entry and the previews in one step, and keeps the superseded evidence in the registry's history.

## What "done" looks like

```sh
curl -sL https://plugins.omarchy.org/catalog.json |
  jq -r '.plugins[] | select(.id == "espadat.tagwerk")
         | "\(.verificationStatus) \(.verificationCoverage) \(.verificationCommit)"'
```

Done reads `verified snapshot-verified <your SHA>`, and the detail page's snapshot link points at your commit. Publication writes the registry, the catalog and the page in one workflow, so this answers as soon as the label lands.

| | Before | After |
| - | ------ | ----- |
| Detail page | `Update unverified` | `Snapshot verified` |
| Card | `Unverified` | `Verified` |
| `verificationCoverage` | `update-unverified` | `snapshot-verified` |
| `verificationCommit` | the older snapshot | your commit |

Filing is safe. The existing snapshot stays live for as long as the update is pending or blocked, so the listing never goes dark while you wait.

## Traps

**The baseline reruns on every promotion.** A routine change can turn `passed` into `review-required`, which drops automatic verification and waits on a maintainer reading the evidence instead. Four files here are in scan scope: `README.md`, `BarWidget.qml`, `preview/render.sh` and `preview/shell.qml`.

**A package manager named in the README costs verification.** Any `paru`, `pacman`, `yay`, `pip`, `npm`, `cargo` or `brew` command anywhere in the root README registers a `package-manager` capability. Prose, an inline code span and a fenced block all count, whatever the fence says, and no heading exempts any of them. Removing one such line from the README is what PR #3 was for. Describe an install or link to it; never write the command.

**Do not rerun a workflow to resolve an ambiguous approval.** Their docs are explicit: review the current evidence and create a fresh approval event in a later second. A label left in place is not proof of publication.

**Installation was never commit-bound.** `omarchy plugin add` clones current upstream `HEAD` whatever the verified snapshot says. Users already have the new code, which is why `Update unverified` is about evidence and never about what is installed.

**Status reflects the last catalog check, not this second.** A freshly pushed commit still reads `Snapshot verified` until a refresh observes it, and that refresh is what flips it. Reading `Snapshot verified` is not proof the snapshot is current, so compare `verificationCommit` against `git rev-parse origin/master` yourself.

The marketplace's own reference is [`VERIFICATION.md`](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/VERIFICATION.md).
