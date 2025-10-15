# Writing Minder Rule Types: A Comprehensive Guide

## Table of Contents

1. [Introduction](#introduction)
2. [What is a Rule Type?](#what-is-a-rule-type)
3. [Rule Type Anatomy](#rule-type-anatomy)
4. [Metadata Section](#metadata-section)
5. [Definition Section (def)](#definition-section-def)
6. [Ingestion](#ingestion)
7. [Evaluation](#evaluation)
8. [Remediation](#remediation)
9. [Alerting](#alerting)
10. [Complete Examples](#complete-examples)
11. [Best Practices](#best-practices)
12. [Testing Your Rule Types](#testing-your-rule-types)

## Introduction

This guide will help you create custom rule types for Minder. Rule types define specific security checks that can be applied to your software supply chain entities (repositories, pull requests, artifacts).

Minder is an open-source platform that helps development teams proactively manage their security posture across the software supply chain. Rule types are the building blocks that define what to check, how to check it, and how to fix issues.

## What is a Rule Type?

A rule type defines:
- **What to check**: Which entity (repository, pull request, artifact) and what aspect of it
- **How to check**: The evaluation logic (using Rego or jq)
- **How to fix**: Optional remediation steps
- **How to alert**: Notification configuration when issues are found

Rule types are used within profiles to enforce security policies across your projects.

## Rule Type Anatomy

Every rule type is a YAML file with the following major sections:

```yaml
version: v1
type: rule-type
name: my_rule_name
display_name: Human Readable Name
short_failure_message: Brief error message
severity:
  value: high|medium|low
context:
  provider: github|gitlab
release_phase: alpha|beta|ga
description: |
  Detailed description of what this rule checks
guidance: |
  Instructions on how to fix issues
def:
  # Rule definition (schema, ingestion, evaluation, remediation, alert)
```

## Metadata Section

### Required Fields

**version**: Always `v1` (the current Minder rule type schema version)

**type**: Always `rule-type`

**name**: A unique identifier for your rule (lowercase, underscores allowed)
```yaml
name: secret_scanning
```

**display_name**: Human-readable name shown in the UI
```yaml
display_name: Enable secret scanning to detect hardcoded secrets
```

**short_failure_message**: Brief message shown when the rule fails
```yaml
short_failure_message: Secret scanning is not enabled
```

**severity**: The severity level of violations
```yaml
severity:
  value: high  # Options: high, medium, low
```

**context**: Specifies which provider this rule applies to
```yaml
context:
  provider: github  # Options: github, gitlab, or {} for provider-agnostic
```

**release_phase**: Stability indicator for the rule
```yaml
release_phase: beta  # Options: alpha, beta, ga
```

### Optional Fields

**description**: Detailed explanation of what the rule checks
```yaml
description: |
  Verifies that secret scanning is enabled for a given repository.
  This helps prevent hardcoded secrets from being committed.
```

**guidance**: Instructions for users on how to fix violations
```yaml
guidance: |
  Ensure that secret scanning is enabled for the repository.

  For more information, see GitHub's documentation:
  https://docs.github.com/en/code-security/secret-scanning
```

## Definition Section (def)

The `def` section contains the core logic of your rule type:

```yaml
def:
  in_entity: repository|pull_request|artifact
  param_schema: {}      # Parameters passed to the rule instance
  rule_schema: {}       # Configuration for the rule in profiles
  ingest: {}           # How to fetch data
  eval: {}             # How to evaluate the data
  remediate: {}        # How to fix issues (optional)
  alert: {}            # How to alert on issues
```

### in_entity

Specifies which type of entity this rule applies to:

```yaml
def:
  in_entity: repository    # For repository rules
  # or
  in_entity: pull_request  # For PR rules
  # or
  in_entity: artifact      # For artifact rules
```

### param_schema

Parameters that can be passed when the rule is instantiated (e.g., which branch to check):

```yaml
def:
  param_schema:
    properties:
      branch:
        type: string
        description: "The name of the branch to check. If left empty, the default branch will be used."
        default: ""
```

### rule_schema

Configuration options that can be set in profiles when using this rule:

```yaml
def:
  rule_schema:
    type: object
    properties:
      skip_private_repos:
        type: boolean
        default: true
        description: "If true, this rule will be marked as skipped for private repositories"
      package_ecosystem:
        type: string
        description: "The package ecosystem that the rule applies to (pip, gomod, npm, etc.)"
    required:
      - package_ecosystem
```

## Ingestion

The `ingest` section defines how to fetch data needed for evaluation. Minder supports several ingestion types:

### REST Ingestion

Fetches data from a REST API endpoint:

```yaml
def:
  ingest:
    type: rest
    rest:
      endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
      parse: json
      fallback:
        - http_code: 404
          body: |
            {"http_status": 404, "message": "Not Protected"}
```

**Templating**: Use Go templates to reference entity properties:
- `{{.Entity.Owner}}` - Repository owner
- `{{.Entity.Name}}` - Repository name
- `{{.Entity.DefaultBranch}}` - Default branch
- `{{.Entity.RepoId}}` - Repository ID (GitLab)
- `{{ $branch_param := index .Params "branch" }}` - Access parameters

**Fallback**: Handle error cases gracefully (e.g., 404 when branch protection isn't configured)

### Git Ingestion

Clones the repository for file-based checks:

```yaml
def:
  ingest:
    type: git
    git: {}
```

Use this when you need to:
- Check for file presence
- Read file contents
- Parse configuration files
- Analyze repository structure

### Diff Ingestion

For pull request rules that need to examine changes:

```yaml
def:
  ingest:
    type: diff
    diff:
      ecosystems:
        - name: npm
          depfile: package-lock.json
        - name: go
          depfile: go.mod
        - name: pypi
          depfile: requirements.txt
```

### Artifact Ingestion

For artifact-related checks:

```yaml
def:
  ingest:
    type: artifact
    artifact: {}
```

## Evaluation

The `eval` section contains the logic to determine if the rule passes or fails. Minder supports multiple evaluation engines:

### Rego Evaluation

Rego is a powerful policy language from Open Policy Agent. Use it for complex logic.

#### Deny-by-Default Pattern

Most common pattern - rule fails unless explicitly allowed:

```yaml
def:
  eval:
    type: rego
    rego:
      type: deny-by-default
      def: |
        package minder

        import future.keywords.if

        default allow := false
        default skip := false
        default message := "Secret scanning is disabled"

        allow if {
          input.ingested.security_and_analysis.secret_scanning.status == "enabled"
        }

        skip if {
          input.profile.skip_private_repos == true
          input.ingested.private == true
        }
```

**Key variables**:
- `allow`: Set to `true` to pass the rule
- `skip`: Set to `true` to skip evaluation (rule marked as skipped, not failed)
- `message`: Custom failure message

**Input variables**:
- `input.ingested`: Data fetched during ingestion
- `input.profile`: Configuration from the profile's rule_schema

#### Constraints Pattern

For rules that can have multiple violations:

```yaml
def:
  eval:
    type: rego
    rego:
      type: constraints
      def: |
        package minder

        violations[{"msg": msg}] {
          # Check condition
          workflows := file.ls("./.github/workflows")
          some w
          workflowstr := file.read(workflows[w])
          workflow := yaml.unmarshal(workflowstr)

          # Detect violation
          some step_num
          s := workflow.jobs[job_name].steps[step_num]
          not is_null(s.uses)

          # Build violation message
          msg := sprintf("Workflow '%v' has issue in step '%v'", [workflows[w], step_num])
        }
```

**Key features**:
- Returns multiple violations
- Each violation has a `msg` field
- Rule fails if any violations exist

#### Rego Built-in Functions

Minder provides special functions for file operations:

```rego
# Check if file exists
file.exists("path/to/file")

# Read file contents
fileStr := file.read("path/to/file")

# List directory contents
files := file.ls("./.github/workflows")

# Parse YAML
config := yaml.unmarshal(fileStr)

# Parse JSON
data := json.unmarshal(jsonStr)
```

### jq Evaluation

For simple comparisons, jq is lighter and easier:

```yaml
def:
  eval:
    type: jq
    jq:
      - ingested:
          def: ".required_pull_request_reviews.required_approving_review_count"
        profile:
          def: ".required_approving_review_count"
```

This compares the value from `ingested` with the expected value from `profile`. The rule passes if they match.

### Vulncheck Evaluation

For vulnerability checking in pull requests:

```yaml
def:
  eval:
    type: vulncheck
    vulncheck: {}
```

Used with `diff` ingestion to check for vulnerable dependencies.

## Remediation

The `remediate` section defines how to automatically fix issues. Remediation is optional but highly recommended.

### REST Remediation

Make an API call to fix the issue:

```yaml
def:
  remediate:
    type: rest
    rest:
      method: PATCH
      endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
      body: |
        { "security_and_analysis": {"secret_scanning": { "status": "enabled" } } }
```

### Pull Request Remediation

Create a pull request with changes:

```yaml
def:
  remediate:
    type: pull_request
    pull_request:
      title: "Add Dependabot configuration for {{.Profile.package_ecosystem }}"
      body: |
        This is a Minder automated pull request.

        This pull request adds a Dependabot configuration to the repository.
      contents:
        - path: .github/dependabot.yml
          action: replace
          content: |
            version: 2
            updates:
              - package-ecosystem: "{{.Profile.package_ecosystem }}"
                directory: "/"
                schedule:
                  interval: "weekly"
```

**Actions**:
- `replace`: Replace entire file (creates if doesn't exist)
- `append`: Add content to end of file
- `prepend`: Add content to beginning of file

### GitHub Branch Protection Remediation

Special remediation for branch protection rules:

```yaml
def:
  remediate:
    type: gh_branch_protection
    gh_branch_protection:
      patch: |
        {"required_pull_request_reviews":{"required_approving_review_count":{{ .Profile.required_approving_review_count }}}}
```

### Custom Remediation Methods

For complex remediations:

```yaml
def:
  remediate:
    type: pull_request
    pull_request:
      title: "Replace unpinned actions with pinned action"
      body: |
        This PR pins GitHub Actions to specific SHA hashes.
      method: minder.actions.replace_tags_with_sha
```

## Alerting

The `alert` section configures how violations are reported:

```yaml
def:
  alert:
    type: security_advisory
    security_advisory: {}
```

Currently, `security_advisory` is the primary alert type, which creates security advisories in the provider (e.g., GitHub Security Advisories).

## Complete Examples

### Example 1: Simple REST-based Check

Check if repository issues are enabled:

```yaml
---
version: v1
release_phase: beta
type: rule-type
name: repo_issues_enabled
display_name: Ensure repository issues are enabled
short_failure_message: Repository issues are not enabled
severity:
  value: low
context:
  provider: github
description: |
  Verifies that GitHub Issues are enabled for the repository.
guidance: |
  Enable GitHub Issues in your repository settings to allow
  issue tracking and collaboration.
def:
  in_entity: repository
  rule_schema:
    type: object
    properties:
      enabled:
        type: boolean
        description: "Whether issues should be enabled"
        default: true
  ingest:
    type: rest
    rest:
      endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
      parse: json
  eval:
    type: rego
    rego:
      type: deny-by-default
      def: |
        package minder

        import future.keywords.if

        default allow := false
        default message := "Repository issues are not enabled"

        allow if {
          input.profile.enabled == input.ingested.has_issues
        }
  remediate:
    type: rest
    rest:
      method: PATCH
      endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
      body: |
        { "has_issues": {{ .Profile.enabled }} }
  alert:
    type: security_advisory
    security_advisory: {}
```

### Example 2: File-based Check with Git Ingestion

Check for license file:

```yaml
---
version: v1
release_phase: beta
type: rule-type
name: license_check
display_name: Ensure a license file is present
short_failure_message: License file not found or incorrect type
severity:
  value: medium
context: {}
description: |
  Verifies that a LICENSE file exists with the correct license type.
guidance: |
  Add a LICENSE file to your repository with the appropriate
  open source license.
def:
  in_entity: repository
  rule_schema:
    type: object
    properties:
      license_filename:
        type: string
        description: "The license filename to look for"
        default: "LICENSE"
      license_type:
        type: string
        description: "The license type (e.g., MIT, Apache-2.0)"
  ingest:
    type: git
    git: {}
  eval:
    type: rego
    rego:
      type: deny-by-default
      def: |
        package minder

        import future.keywords.if

        default allow := false
        fileStr := file.read(input.profile.license_filename)

        allow if {
          contains(fileStr, input.profile.license_type)
        }

        message := sprintf("License file %v does not contain %v",
          [input.profile.license_filename, input.profile.license_type])
  remediate:
    type: pull_request
    pull_request:
      title: "Add {{.Profile.license_type}} LICENSE file"
      body: |
        This PR adds a LICENSE file to the repository.
      contents:
        - path: "{{.Profile.license_filename}}"
          action: replace
          content: |
            {{.Profile.license_type}} License

            [Full license text here]
  alert:
    type: security_advisory
    security_advisory: {}
```

### Example 3: Pull Request Check

Check for vulnerable dependencies in PRs:

```yaml
---
version: v1
release_phase: alpha
type: rule-type
name: pr_vulnerability_check
display_name: Ensure PRs don't add vulnerable dependencies
short_failure_message: PR adds vulnerable dependencies
severity:
  value: high
context:
  provider: github
description: |
  Checks if a pull request introduces dependencies with known vulnerabilities.
guidance: |
  Remove or update the vulnerable dependencies before merging.
def:
  in_entity: pull_request
  rule_schema:
    type: object
    properties:
      action:
        type: string
        description: "Action to take: review, commit_status, comment, profile_only"
        enum:
          - review
          - commit_status
          - comment
          - profile_only
        default: review
  ingest:
    type: diff
    diff:
      ecosystems:
        - name: npm
          depfile: package-lock.json
        - name: go
          depfile: go.mod
  eval:
    type: vulncheck
    vulncheck: {}
  alert:
    type: security_advisory
    security_advisory: {}
```

### Example 4: Branch Protection with Parameters

Check branch protection with parameterized branch:

```yaml
---
version: v1
release_phase: beta
type: rule-type
name: branch_protection_enabled
display_name: Ensure branch protection is enabled
short_failure_message: Branch protection is not configured
severity:
  value: high
context:
  provider: github
description: |
  Verifies that branch protection is enabled for the specified branch.
guidance: |
  Configure branch protection rules in your repository settings.
def:
  in_entity: repository
  param_schema:
    properties:
      branch:
        type: string
        description: "Branch name (defaults to default branch)"
        default: ""
  rule_schema:
    type: object
  ingest:
    type: rest
    rest:
      endpoint: '{{ $branch_param := index .Params "branch" }}/repos/{{.Entity.Owner}}/{{.Entity.Name}}/branches/{{if ne $branch_param "" }}{{ $branch_param }}{{ else }}{{ .Entity.DefaultBranch }}{{ end }}/protection'
      parse: json
      fallback:
        - http_code: 404
          body: |
            {"http_status": 404, "message": "Not Protected"}
  eval:
    type: rego
    rego:
      type: deny-by-default
      def: |
        package minder

        import future.keywords.if

        default allow := false
        default message := "Branch protection is not enabled"

        allow if {
          input.ingested.http_status != 404
        }
  alert:
    type: security_advisory
    security_advisory: {}
```

## Best Practices

### 1. Naming Conventions

- **Rule name**: Use lowercase with underscores (e.g., `secret_scanning`, `branch_protection_enabled`)
- **Display name**: Use clear, action-oriented language (e.g., "Enable secret scanning")
- **Short failure message**: Be concise and specific (e.g., "Secret scanning is not enabled")

### 2. Error Handling

Always handle edge cases:

```yaml
# Handle 404s for optional features
fallback:
  - http_code: 404
    body: |
      {"http_status": 404, "message": "Feature not available"}
```

```rego
# Skip private repos if needed
skip if {
  input.profile.skip_private_repos == true
  input.ingested.private == true
}
```

### 3. Documentation

- Write clear **descriptions** explaining what is checked
- Provide actionable **guidance** with links to relevant documentation
- Include examples in comments

### 4. Rule Schema Design

Make rules configurable but provide sensible defaults:

```yaml
rule_schema:
  type: object
  properties:
    threshold:
      type: integer
      description: "Minimum required value"
      default: 1
    skip_archived:
      type: boolean
      description: "Skip archived repositories"
      default: true
```

### 5. Message Quality

Provide helpful failure messages:

```rego
message := sprintf("File %v does not exist", [input.profile.filename]) if {
  not file.exists(input.profile.filename)
} else := sprintf("File %v does not contain required content", [input.profile.filename]) if {
  not contains(fileStr, input.profile.content)
}
```

### 6. Remediation Guidelines

- Always include a clear title and body in pull request remediations
- Reference Minder in the PR body
- Link to relevant documentation
- Make remediations idempotent (safe to run multiple times)

### 7. Provider Context

Set appropriate context:

```yaml
# GitHub-specific rule
context:
  provider: github

# GitLab-specific rule
context:
  provider: gitlab

# Provider-agnostic rule
context: {}
```

### 8. Release Phases

Use appropriate release phases:

- **alpha**: Experimental, may change significantly
- **beta**: Stable API, but may have bugs
- **ga**: Production-ready

### 9. Severity Levels

Choose severity appropriately:

- **high**: Critical security issues (e.g., secrets exposed, no branch protection)
- **medium**: Important security practices (e.g., missing dependency scanning)
- **low**: Best practices and hygiene (e.g., missing documentation)

## Testing Your Rule Types

### 1. Create the Rule Type

```bash
minder ruletype create -f rule-types/github/my_rule.yaml
```

### 2. Create a Test Profile

```yaml
---
version: v1
type: profile
name: test-my-rule
context:
  provider: github
repository:
  - type: my_rule
    def:
      # Your rule configuration
```

```bash
minder profile create -f test-profile.yaml
```

### 3. Check Profile Status

```bash
minder profile status list --name test-my-rule --detailed
```

### 4. Test Remediation

Enable remediation in your profile:

```yaml
remediate: on
```

Then verify the remediation works as expected.

### 5. Unit Tests

Minder supports test files (`.test.yaml`) alongside rule types:

```yaml
---
name: secret_scanning test
rule: secret_scanning
ingested:
  type: json
  value:
    security_and_analysis:
      secret_scanning:
        status: enabled
    private: false
profile:
  skip_private_repos: true
expected:
  passed: true
```

Run tests:

```bash
go test ./...
```

## Advanced Topics

### Conditional Skip Logic

Skip rules based on repository characteristics:

```rego
skip if {
  input.profile.apply_if_file != ""
  not file.exists(input.profile.apply_if_file)
}
```

### Multiple Violations

Report multiple issues in one evaluation:

```rego
violations[{"msg": msg}] {
  # Iterate over items
  some i
  item := input.ingested[i]

  # Check condition
  not item.secure

  # Build message
  msg := sprintf("Item %v is not secure", [item.name])
}
```

### Complex Rego Queries

Use Rego's full power for complex checks:

```rego
import future.keywords.every
import future.keywords.if
import future.keywords.in

allow if {
  # All items must pass
  every item in input.ingested {
    item.secure == true
  }
}

allow if {
  # At least one item passes
  some item in input.ingested
  item.secure == true
}
```

### Template Variables in Remediation

Access profile and entity data in templates:

```yaml
remediate:
  type: pull_request
  pull_request:
    title: "Configure {{.Profile.tool_name}} for {{.Entity.Name}}"
    body: |
      Repository: {{.Entity.Owner}}/{{.Entity.Name}}
      Branch: {{.Entity.DefaultBranch}}
      Configuration: {{.Profile.config}}
```

Available template variables:
- `{{.Entity.*}}`: Entity properties
- `{{.Profile.*}}`: Rule configuration
- `{{.Params.*}}`: Parameters

## Common Patterns

### Pattern 1: File Existence Check

```rego
default allow := false

allow if {
  file.exists(input.profile.filename)
}
```

### Pattern 2: File Content Check

```rego
default allow := false
fileStr := file.read(input.profile.filename)

allow if {
  contains(fileStr, input.profile.required_text)
}
```

### Pattern 3: API Response Check

```rego
default allow := false

allow if {
  input.ingested.security_feature.enabled == true
}
```

### Pattern 4: Workflow File Analysis

```rego
violations[{"msg": msg}] {
  workflows := file.ls("./.github/workflows")
  some w
  workflowstr := file.read(workflows[w])
  workflow := yaml.unmarshal(workflowstr)

  # Check workflow content
  some job_name
  job := workflow.jobs[job_name]

  # Detect issue
  not job.permissions

  msg := sprintf("Workflow '%v' job '%v' missing permissions", [workflows[w], job_name])
}
```

### Pattern 5: Numeric Threshold Check

```rego
default allow := false

allow if {
  input.ingested.count >= input.profile.minimum_required
}
```

## Troubleshooting

### Common Issues

1. **Rule fails unexpectedly**
   - Check `minder profile status list --detailed` for error messages
   - Verify ingested data structure matches your eval logic
   - Add debug output: `trace(sprintf("Debug: %v", [variable]))`

2. **Remediation doesn't work**
   - Ensure remediate is enabled in profile (`remediate: on`)
   - Check API permissions
   - Verify endpoint and body format

3. **File operations fail**
   - Ensure `ingest.type: git` is configured
   - Check file paths (relative to repo root)
   - Verify file exists: `file.exists(path)`

4. **Template errors**
   - Use correct property names (check entity structure)
   - Test templates: `{{ $var := .Foo }}{{$var}}`
   - Escape special characters

## Resources

- [Minder Documentation](https://mindersec.github.io/)
- [Open Policy Agent (Rego) Documentation](https://www.openpolicyagent.org/docs/latest/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [Minder Rules Repository](https://github.com/mindersec/minder-rules-and-profiles)
- [GitHub REST API](https://docs.github.com/en/rest)
- [GitLab API](https://docs.gitlab.com/ee/api/)

## Contributing

When contributing rule types to the Minder community:

1. Follow the naming conventions
2. Include comprehensive tests
3. Document your rule thoroughly
4. Provide examples
5. Use appropriate severity and release phase
6. Test on real repositories
7. Submit a pull request to the minder-rules-and-profiles repository

## Conclusion

Writing rule types for Minder enables you to codify your organization's security policies and automatically enforce them across your software supply chain. Start with simple rules, test thoroughly, and gradually build more complex checks as needed.

Remember:
- Start simple, iterate
- Test extensively
- Document clearly
- Handle edge cases
- Provide good error messages
- Make rules configurable
- Include remediation when possible

Happy rule writing!
