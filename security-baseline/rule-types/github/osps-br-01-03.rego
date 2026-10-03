# METADATA
#
# name: osps-br-01-03
# title: Prevent access to to privileged assets from untrusted workflows
# description: |
#   This check determines whether the project's GitHub Action workflows
#   have dangerous code patterns that could allow untrusted workflows
#   to access privileged assets. The following patterns are checked:
#
#   * Workflows triggered by pull_request_target or workflow_run that
#     check out untrusted code.
# custom:
#   short_failure_message: Untrusted workflows can access privileged assets
#   severity:
#     value: critical
#   release_phase: alpha
#   guidance: |
#     [Avoid checking out untrusted code in contexts which have access to secrets](https://docs.github.com/en/actions/reference/security/secure-use#mitigating-the-risks-of-untrusted-code-checkout).
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

dangerous_triggers := ["pull_request_target", "workflow_run"]

# Look for dangerous triggers combined with checkout of user-controlled code.
violations contains {"msg": msg} if {
	some w
	contents := file.read(workflows[w])
	workflow := parse_yaml(contents)

	events := events_set(workflow.on)
	some event in events
	event in dangerous_triggers

	some job
	some step
	stepDef := workflow.jobs[job].steps[step]
	startswith(stepDef.uses, "actions/checkout")

	# This action is only dangerous if we check out the attacker-controlled branch
	dangerous_ref(stepDef["with"].ref)

	msg := sprintf("Workflow %s has a dangerous trigger and checks out a pull request in job '%s'", [workflows[w], job])
}

events_set(events) := object.keys(events) if {
	is_object(events)
}

events_set(events) := events if {
	is_array(events)
}

dangerous_ref(ref) if {
	contains(ref, "github.event.pull_request")
}

dangerous_ref(ref) if {
	contains(ref, "github.event.workflow_run")
}
