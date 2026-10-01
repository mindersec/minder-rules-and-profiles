# OpenSSF Security Baseline

This directory contains Minder rules implementing the [OpenSSF Security Baseline version **2026-08-28**](https://baseline.openssf.org/versions/2026-08-28).  The Security Baseline defines security practices for open source projects. For the full definition and details, see the [OpenSSF Security Baseline site](https://baseline.openssf.org/).

The `security-baseline-level-1` profile (alongside the ruletypes and datasources in this directory) can be used to check _GitHub_ repositories for compliance with Baseline Level.  Support for GitLab repositories will be available shortly.  You can install the `security-baseline-level-1` profile in your project with:

```bash
minder apply -f $THIS_DIRECTORY
```

If you are using [Privateer](https://github.com/ossf/pvtr-github-repo-scanner) to check Baseline compliance, you may want to also automatically [generate a security insights file using the `autofill-insights` profile](../autofill-insights/).

## Roadmap

Expect updates to the rules to address the following (roughly in the described order):

* [ ] Coverage for GitLab equivalents of GitHub-only rules in the `security-baseline-level-1` profile.
* [ ] Additional test coverage for ruletypes in the level 1 ruleset.  (Aiming for positive and negative scenario coverage for all ruletypes)
* [ ] Remediations for at least 80% of the level 1 ruletypes.
* [ ] Additional rules to measure level 2 and level 3 controls.

## Changelog

### Updates from 2025-10-10

* The `osbps-br-01-02` ruletype has been retired from the baseline.  This rule duplicated some of the checks in the `opsps-br-01-01` ruletype, so there is no loss of coverage.  The ruletype is no longer referenced by the `security-baseline-level-1` profile, so it should be unused and safe to delete in your project.