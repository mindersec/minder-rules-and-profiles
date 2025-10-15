[![License: Apache 2.0](https://img.shields.io/badge/License-Apache2.0-brightgreen.svg)](https://opensource.org/licenses/Apache-2.0)

# Minder Rules and Profiles

A repository containing Minder rules and profiles describing security policies and various tool integrations.

## What are rule types, profiles, and data sources?

Minder is a tool that allows you to define security policies and integrate with various tools to enforce those policies.
Its engine is designed to be extensible through rule types, profiles and data sources, allowing you to integrate your own
logic and processes.

A profile defines your security policies that you want to apply to your software supply chain. Profiles contain rules
(or rule types) that query data in a provider, and specifies whether Minder will issue alerts or perform automatic
remediations when an entity is not in compliance with the policy.

Profiles in Minder allow you to group and manage rules for various entity types, such as `repositories`, `pull requests`,
`artifacts`, etc., across your registered GitHub repositories.

Data sources are designed to enrich the information available about an entity, allowing us to make more informed policy
evaluations.
Unlike providers, which create entities, a data source offers additional information about an existing entity or one of
its specific attributes.
The entity itself, however, always originates from a provider.

## How to get started with writing rules and profiles?

### Quick Start Guides

For comprehensive, repository-specific guides on writing rule types:
- **[Writing Rule Types: Comprehensive Guide](./docs/writing-rule-types.md)** - In-depth guide with examples and best practices
- **[Rule Type Quick Reference](./docs/rule-type-quick-reference.md)** - Concise syntax reference for quick lookup

### Official Minder Documentation

- [How to write a rule type](https://mindersec.github.io/how-to/custom-rules)
- [How to write a rule type using Rego](https://mindersec.github.io/how-to/writing-rules-in-rego)
- [How to use mindev to develop and debug rule types](https://mindersec.github.io/how-to/mindev)
- [How to write rules and profiles - YouTube](https://www.youtube.com/watch?v=eXp0nyd72d4)
- [Minder documentation](https://mindersec.github.io)
- [Rego language tutorial](https://www.openpolicyagent.org/docs/latest/policy-language/)

### Reference Examples

Apart from that, you can also check the reference rules and profiles in this repository to get an idea of how to write, structure, and organize them.

- Rule types: the reference rule types are available in the `rule-types` directory. To take these rule types
  into use, you'll need to instantiate them in a Minder instance. For example, to use the
  reference rules recommended for GitHub, use the following command - `minder ruletype create -f rule-types/github`.
- Profiles: the reference profiles are available in the `profiles` directory. To take a profile
  into use, you'll need to instantiate it in a Minder instance. For example, to use the
  reference profile recommended for GitHub, use the following command - `minder profile create -f profiles/github/profile.yaml`.
- Data sources: the reference data sources are available in the `data-sources` directory. To take a data source
  into use, you'll need to instantiate it in a Minder instance. For example, to instantiate the
  reference data source for using OSV as a data source, use the following command - `minder datasource create -f data-sources osv.yaml`.

## How to contribute?

We welcome contributions!
If you came across a rule type, profile, or data source that you think would be useful to others, please consider contributing it back to the community.

If you have questions or need help getting started, feel free to reach out on the [`#minder` channel on OpenSSF Slack](https://openssf.slack.com/archives/C07SP9RSM2L) or open an issue.

You can check our [CONTRIBUTING.md](CONTRIBUTING.md) guidelines for more information on how to contribute to this repository.

## License

This repository is licensed under the [Apache 2.0 License](./LICENSE).
