# Promoting a commit to the marketplace listing

How a widget change gets back onto [plugins.omarchy.org](https://plugins.omarchy.org). The marketplace will not do this on its own.

Verification is bound to one exact commit. The listing is `Snapshot verified` only for the `listingValidatedCommit` recorded when it was approved. As soon as a catalog check observes a newer commit upstream, the public status becomes `Update unverified`. Nothing warns us. Push a one-line fix and the listing degrades quietly until someone files a promotion.

`Update unverified` means uncovered, not unsafe. The marketplace is saying the newer code has no evidence behind it yet, not that anything is wrong with it. Do not rerun the old approval to fix it: only a new promotion moves the recorded commit.

## Procedure

**1. Land every change first.** Promotion targets one commit. Anything merged after the one you submit reopens the gap, so promote when `master` is where you want it, not mid-stack.

**2. Read the full SHA.** The form needs all 40 characters.

```sh
git fetch origin && git rev-parse origin/master
```

**3. Open the [Plugin verification form](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=verify-plugin.yml)** on `omacom/omarchy-plugin-marketplace` and select **Verify and publish a newer upstream commit**. The other two options only accept the commit already recorded, so they cannot carry an update.

| Field | Value |
| ----- | ----- |
| Verification action | `Verify and publish a newer upstream commit` |
| Plugin ID | `espadat.tagwerk` |
| Repository URL | `https://github.com/espadat-studio/omarchy-tagwerk` |
| Target commit | the SHA from step 2 |

Tick the verification acknowledgment. The standard-installation checkbox does not apply — this listing has no manual-install override.

**4. Wait for the bot.** Opening or editing the issue runs compatibility validation and the Automated Security Baseline against that exact commit, without executing our code. Expect `passed` with no findings and no capabilities. Editing the issue retries a failed or corrected request.

**5. Wait for a maintainer** to apply `approved-and-verified`. It is the only label that publishes. Approval atomically replaces the validated commit, the catalog entry and the previews, keeping the superseded snapshot in `listingValidationHistory`.

## What "done" looks like

```sh
curl -sL https://plugins.omarchy.org/catalog.json |
  jq -r '.plugins[] | select(.id == "espadat.tagwerk")
         | "\(.verificationStatus) \(.verificationCoverage) \(.verificationCommit)"'
```

Done reads `verified snapshot-verified <your SHA>`. The detail page reads `Snapshot verified` and its snapshot link points at your commit.

| | Before | After |
| - | ------ | ----- |
| Detail page | `Update unverified` | `Snapshot verified` |
| Card | `Unverified` | `Verified` |
| `verificationCoverage` | `update-unverified` | `snapshot-verified` |
| `verificationCommit` | the older snapshot | your commit |

Filing is safe. The existing snapshot stays live and authoritative for as long as the update is pending or blocked, so a listing never goes dark while you wait.

## Traps

**The baseline reruns on every promotion.** A routine widget change can turn `passed` into `review-required`, which drops automatic verification and waits on a maintainer reading the evidence instead. The scan covers the root README plus every `.sh`, `.qml`, `.py`, `.service` and similar file outside `docs/`, `test/` and `spec/`. In the README, only fenced `sh` blocks count, and a block is exempt when its heading or the paragraph above it mentions development, contributing or testing. A documented package install such as `paru -S` registers a `package-manager` capability — that is what PR #3 removed from the README, and it is the easiest way to lose automatic verification again.

**Do not rerun a workflow to resolve an ambiguous approval.** Their docs are explicit: review the current evidence and create a fresh approval event in a later second. A retained label is not proof of publication.

**Installation is not commit-bound.** `omarchy plugin add` clones current upstream `HEAD` whatever the verified snapshot says. Users are already getting the new code, which is why `Update unverified` is about evidence and never about what is installed.

**The public page lags.** Status reflects the last catalog check, not this second. A freshly pushed commit still reads `Snapshot verified` until a check observes it — and that check is what flips it. Trust `catalog.json` over the rendered page.

The marketplace's own reference is [`VERIFICATION.md`](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/VERIFICATION.md).
