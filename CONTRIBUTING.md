# Contributing to minder rules and profiles

Thank you for considering contributing to the Minder rules library! We welcome contributions from the community and are excited to work with you.

## How to Contribute

Minder rules need to pass the [`mindev` linter](https://github.com/mindersec/minder/tree/main/cmd/dev).  Updates to existing rules also need to pass an upgrade test which ensures compatibility between old instances of the rules and the new rules.

In general, both rule types and profiles should aim to "do one thing well" -- for example, rather than creating a rule which checks that all the files in a repo follow best practices, create one rule type for each best practice.  This has several benefits:

* It's easier for users to select which rules are important to them
* When reporting on rule status, it's easier to determine which guidelines are mostly-followed vs more difficult to achieve
* It can simplify debugging for future rule writers.

Frequent contributors who are interested in membership in the Minder organization and approval privileges should check out the [committer ladder and expectations](https://github.com/mindersec/community/tree/main/MAINTAINERS.md) in the `community` repo.

## Code of Conduct

Please adhere to the [Minder Code of Conduct](https://github.com/mindersec/community/blob/main/CODE_OF_CONDUCT.md) in all your interactions with the project.

## Reporting Issues

If you encounter any issues, please report them in the [issue tracker](https://github.com/mindersec/rules-and-profiles/issues). Provide as much detail as possible to help us resolve the issue quickly.

## Chat / Questions

If you have questions, feel free to reach out on the [`#minder` channel on OpenSSF Slack](https://openssf.slack.com/archives/C07SP9RSM2L).

Thank you for your contributions!