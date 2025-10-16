# Minder Rule Type Quick Reference

## Rule Type Template

```yaml
---
version: v1
release_phase: alpha|beta|ga
type: rule-type
name: your_rule_name
display_name: Human Readable Name
short_failure_message: Brief error message
severity:
  value: high|medium|low
context:
  provider: github|gitlab  # or {} for provider-agnostic
description: |
  What this rule checks
guidance: |
  How to fix violations
def:
  in_entity: repository|pull_request|artifact
  param_schema: {}
  rule_schema: {}
  ingest: {}
  eval: {}
  remediate: {}  # Optional
  alert:
    type: security_advisory
    security_advisory: {}
```

## Ingestion Types

### REST

```yaml
ingest:
  type: rest
  rest:
    endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
    parse: json
    fallback:
      - http_code: 404
        body: '{"error": "Not found"}'
```

### Git

```yaml
ingest:
  type: git
  git: {}
```

### Diff

```yaml
ingest:
  type: diff
  diff:
    ecosystems:
      - name: npm
        depfile: package-lock.json
      - name: go
        depfile: go.mod
```

### Artifact

```yaml
ingest:
  type: artifact
  artifact: {}
```

## Evaluation Types

### Rego: Deny-by-Default

```yaml
eval:
  type: rego
  rego:
    type: deny-by-default
    def: |
      package minder

      import future.keywords.if

      default allow := false
      default skip := false
      default message := "Default failure message"

      allow if {
        # Condition for passing
      }

      skip if {
        # Condition for skipping
      }
```

### Rego: Constraints

```yaml
eval:
  type: rego
  rego:
    type: constraints
    def: |
      package minder

      violations[{"msg": msg}] {
        # Logic to find violations
        msg := "Violation description"
      }
```

### jq

```yaml
eval:
  type: jq
  jq:
    - ingested:
        def: ".path.to.value"
      profile:
        def: ".expected_value"
```

### Vulncheck

```yaml
eval:
  type: vulncheck
  vulncheck: {}
```

## Remediation Types

### REST

```yaml
remediate:
  type: rest
  rest:
    method: PATCH
    endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
    body: |
      {"setting": "value"}
```

### Pull Request

```yaml
remediate:
  type: pull_request
  pull_request:
    title: "Fix: {{.Profile.issue}}"
    body: |
      Automated fix by Minder
    contents:
      - path: path/to/file
        action: replace  # or append, prepend
        content: |
          File content here
```

### GitHub Branch Protection

```yaml
remediate:
  type: gh_branch_protection
  gh_branch_protection:
    patch: |
      {"required_pull_request_reviews":{"required_approving_review_count":2}}
```

## Template Variables

### Available in Endpoints and Remediation

```yaml
{{.Entity.Owner}}           # Repository owner
{{.Entity.Name}}            # Repository name
{{.Entity.DefaultBranch}}   # Default branch
{{.Entity.RepoId}}          # Repository ID (GitLab)
{{.Profile.property}}       # Profile configuration values
{{.Params.property}}        # Parameter values
```

### Accessing Parameters

```yaml
{{ $branch := index .Params "branch" }}
{{if ne $branch "" }}{{ $branch }}{{ else }}{{ .Entity.DefaultBranch }}{{ end }}
```

## Rego Built-in Functions

### File Operations

```rego
file.exists("path/to/file")           # Check existence
fileStr := file.read("path/to/file")  # Read content
files := file.ls("directory/path")    # List directory
```

### String Operations

```rego
contains(haystack, needle)            # String contains
startswith(string, prefix)            # String starts with
endswith(string, suffix)              # String ends with
lower(string)                         # Convert to lowercase
upper(string)                         # Convert to uppercase
trim_space(string)                    # Remove whitespace
```

### Parsing

```rego
yaml.unmarshal(yamlString)            # Parse YAML
json.unmarshal(jsonString)            # Parse JSON
```

### Regex

```rego
regex.match(pattern, string)          # Match pattern
```

### Collections

```rego
count(array)                          # Array length
some i; array[i]                      # Iterate array
some key; object[key]                 # Iterate object keys
```

### Formatting

```rego
sprintf("Format %v %v", [arg1, arg2]) # Format string
```

## Common Patterns

### Check Boolean Setting

```rego
allow if {
  input.ingested.setting == true
}
```

### Check Numeric Threshold

```rego
allow if {
  input.ingested.count >= input.profile.minimum
}
```

### Check File Exists

```rego
allow if {
  file.exists(input.profile.filename)
}
```

### Check File Contains Text

```rego
fileStr := file.read(input.profile.filename)

allow if {
  contains(fileStr, input.profile.required_text)
}
```

### Parse YAML Configuration

```rego
allow if {
  fileStr := file.read(".github/config.yml")
  config := yaml.unmarshal(fileStr)
  config.setting == input.profile.expected_value
}
```

### Check All Workflow Files

```rego
violations[{"msg": msg}] {
  workflows := file.ls("./.github/workflows")
  some w
  workflowstr := file.read(workflows[w])
  workflow := yaml.unmarshal(workflowstr)

  # Check workflow
  some job_name
  not workflow.jobs[job_name].permissions

  msg := sprintf("Workflow '%v' missing permissions", [workflows[w]])
}
```

### Skip Based on Condition

```rego
skip if {
  input.profile.skip_private_repos == true
  input.ingested.private == true
}

skip if {
  input.profile.apply_if_file != ""
  not file.exists(input.profile.apply_if_file)
}
```

### Multiple Allow Conditions

```rego
allow if {
  input.ingested.method_a == true
}

allow if {
  input.ingested.method_b == true
}
```

### Complex Conditions

```rego
allow if {
  input.ingested.security.enabled == true
  input.ingested.security.level >= input.profile.min_level
  not input.ingested.archived
}
```

## Schema Types

### String

```yaml
property_name:
  type: string
  description: "Description"
  default: "default_value"
```

### Integer

```yaml
property_name:
  type: integer
  description: "Description"
  default: 1
```

### Boolean

```yaml
property_name:
  type: boolean
  description: "Description"
  default: true
```

### Enum

```yaml
property_name:
  type: string
  description: "Description"
  enum:
    - option1
    - option2
    - option3
  default: option1
```

### Array

```yaml
property_name:
  type: array
  items:
    type: string
  description: "Description"
```

### Object

```yaml
property_name:
  type: object
  properties:
    sub_property:
      type: string
  description: "Description"
```

## CLI Commands

### Create Rule Type

```bash
minder ruletype create -f rule-types/github/my_rule.yaml
```

### List Rule Types

```bash
minder ruletype list
```

### Get Rule Type Details

```bash
minder ruletype get -n rule_name
```

### Delete Rule Type

```bash
minder ruletype delete -n rule_name
```

### Create Profile

```bash
minder profile create -f profile.yaml
```

### Check Profile Status

```bash
minder profile status list --name profile-name --detailed
```

## Testing

### Test File Format

```yaml
---
name: Test name
rule: rule_name
ingested:
  type: json
  value:
    # Mock ingested data
profile:
  # Mock profile configuration
expected:
  passed: true
```

### Run Tests

```bash
go test ./...
```

## Entity Types

### Repository

```yaml
def:
  in_entity: repository
```

Access:
- `{{.Entity.Owner}}`
- `{{.Entity.Name}}`
- `{{.Entity.DefaultBranch}}`

### Pull Request

```yaml
def:
  in_entity: pull_request
```

Use with `diff` ingestion for dependency checks.

### Artifact

```yaml
def:
  in_entity: artifact
```

Use with `artifact` ingestion for signature verification.

## Severity Levels

- **high**: Critical security issues
- **medium**: Important security practices
- **low**: Best practices and hygiene

## Release Phases

- **alpha**: Experimental
- **beta**: Stable API
- **ga**: Production-ready

## Alert Types

```yaml
alert:
  type: security_advisory
  security_advisory: {}
```

## Example: Complete Minimal Rule

```yaml
---
version: v1
release_phase: beta
type: rule-type
name: example_check
display_name: Example Security Check
short_failure_message: Check failed
severity:
  value: medium
context:
  provider: github
description: |
  Example rule description
guidance: |
  How to fix this issue
def:
  in_entity: repository
  rule_schema:
    type: object
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

        allow if {
          input.ingested.has_issues == true
        }
  alert:
    type: security_advisory
    security_advisory: {}
```

## Debugging Tips

1. Use `trace()` in Rego for debugging:
   ```rego
   trace(sprintf("Debug: %v", [variable]))
   ```

2. Check profile status for detailed errors:
   ```bash
   minder profile status list --name profile-name --detailed
   ```

3. Test ingestion separately:
   - Verify API endpoints manually
   - Check file paths in repository
   - Validate JSON/YAML parsing

4. Validate schema:
   - Test with different profile configurations
   - Check required vs optional fields
   - Verify default values

## Resources

- [Full Guide](./writing-rule-types.md)
- [Minder Docs](https://mindersec.github.io/)
- [Example Rules](https://github.com/mindersec/minder-rules-and-profiles/tree/main/rule-types)
- [Rego Docs](https://www.openpolicyagent.org/docs/latest/)
