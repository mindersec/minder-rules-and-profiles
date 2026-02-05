# Autofill Insights

This directory contains a Minder profile and rules to automatically populate `security-insights.yaml` (v2) from existing GitHub repository content.

## Overview

These rules extract security-related information from your GitHub repository and generate a compliant `security-insights.yaml` file, reducing manual configuration effort.

## How to Apply

1. **Install Minder**: Follow the [Minder documentation](https://docs.mindersec.dev/)
2. **Register your repository**: [Add your GitHub repository to Minder](https://docs.mindersec.dev/getting_started/register_repos)
3. **Apply the profile**: Apply the data sources, rules, and profile in this directory to your project with `minder apply -f autofill-insights` from the root of the repository.
4. **Review results**: Minder will generate pull requests to your repository to fill out `.github/security-insights.yaml`

## Content extracted (and where from):

* `header.last-reviewed` - can flag when this is older than a certain age
* `header.last-updated` - required to be set
* `header.schema-version` - verify this is 2.x.x
* `header.url` - points to the `.github/security-insights.yaml` file, depending on where it is found
* `header.project-si-source` - if set, verify that the linked YAML has `project.repositories[*].url` matching this repo.
* `project.administrators` - must be set, if not, try to fill with project admins
* `project.name` - verify this is set, if not try to set it to repo name (but can differ)
* `project.repositories[*]` - verify this is set, includes the current repo (if not, add the current repo)
* `project.vulnerability-reporting` - set `{bug-bounty-available: false, reports-accepted: ${{ SECURITY.md || private vuln reporting enabled }}, policy: "${{URL of SECURITY.md if present}}"}`
* `project.homepage` - set to project URL
* `project.documentation.code-of-conduct` - link to GitHub known locations
* `project.detailed-guide` - link to project docs (webpage, then wiki, then `./docs/` dir, then `README.md`)
* `repository.accepts-change-request` - `true` by default
* `repository.accepts-automated-change-request` - `true` by default
* `repository.core-team` - map to `project.administrators` unless `.github/CODEOWNERS` is present, then use those
* `repository.license.expression` - pull from GH API
* `repository.license.URL` - pull from GH API, or use same `./LICENSE{,.md,.txt}` logic
* `repository.security.assessments` - `{}`
* `repository.status` - "active" by default
* `repository.url` - URL of this repo (clone URL?)
* `repository.documentation.contributing-guide` - link to `CONTRIBUTING.md` if possible
* `repository.documentation.review-policy` - link to `CONTRIBUTING.md` if it has a "reviewers` section, or `REVIEWERS.md` if present(?)
* `repository.documentation.security-policy` - link to `SECURITY.md` if possible

## References

- [OpenSSF Security Insights Specification](https://github.com/ossf/security-insights-spec)
- [Security Insights v2 Schema](https://security-insights.openssf.org/schema.html#securityinsights)
- [Minder Documentation](https://docs.mindersec.dev/)
