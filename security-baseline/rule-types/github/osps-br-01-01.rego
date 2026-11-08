# METADATA
#
# title: Prevent untrusted input in continuous integration
# name: osps-br-01-01
# description: |
#   This check determines whether the project's GitHub Action workflows
#   have dangerous code patterns. Some examples of these patterns are
#   use of potentially untrusted inputs in scripts or unquoted branch
#   names. The following patterns are checked:
#
#   * Script Injection with Untrusted Context Variables: This pattern
#   detects whether a workflow's inline script may execute untrusted
#   input from attackers. Attackers can add their own content to
#   certain github context variables that are considered untrusted,
#   for example, github.event.issue.title.
#
#   * Unquoted or unvalidated branch names: Git branch names can contain
#   special characters such as space or semicolon which may be used to
#   execute malicious code with permissions of the continuous integration
#   workflow.
# custom:
#   short_failure_message: Untrusted input can subvert workflows
#   severity:
#     value: critical
#   release_phase: alpha
#   guidance: |
#     [Quote or escape untrusted context variables](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#understanding-the-risk-of-script-injections)
#     before using them in scripts.
#   def:
#     provider_traits: ["git", "github"]
#     in_entity: repository
#     ingest:
#       type: git
#     eval:
#       rego:
#         type: constraints

package minder

import rego.v1

# Match both .yml and .yaml files
workflows := array.concat(file.ls_glob("./.github/workflows/*.yml"), file.ls_glob("./.github/workflows/*.yaml"))

# Look for possible script injections
violations contains {"msg": msg} if {
	some w
	contents := file.read(workflows[w])
	workflow := parse_yaml(contents)

	some job
	some step
	stepDef := workflow.jobs[job].steps[step]
	stepDef.run # Only applies to steps with a run command

	regexp := "\\${{(.*?)}}"
	expansions := regex.find_all_string_submatch_n(regexp, stepDef.run, -1)

	some expr in expansions
	vulnerable_expansion(expr[1])

	msg := sprintf("Workflow %s has possible event script injection in step %d of job '%s'", [workflows[w], step, job])
}

# Patterns from https://securitylab.github.com/resources/github-actions-untrusted-input/
vulnerable_patterns := {
	"github.event.issue.title",
	"github.event.issue.body",
	"github.event.pull_request.title",
	"github.event.pull_request.body",
	"github.event.comment.body",
	"github.event.review.body",
	"github.event.pages.*.page_name",
	"github.event.commits.*.message",
	"github.event.head_commit.message",
	"github.event.head_commit.author.email",
	"github.event.head_commit.author.name",
	"github.event.commits.*.author.email",
	"github.event.commits.*.author.name",
	"github.event.pull_request.head.ref",
	"github.event.pull_request.head.label",
	"github.event.pull_request.head.repo.default_branch",
	"github.head_ref",
}

vulnerable_expansion(exp) if {
	some match in vulnerable_patterns
	matcher := concat("", ["*", match, "*"])
	glob.match(matcher, null, exp)
}
