# METADATA
#
# name: osps-qa-01-01
# title: The project's source code is publicly readable
# description: |
#   Enable users to access and review the project’s source code and
#   history, promoting transparency and collaboration within the project
#   community.
# custom:
#   short_failure_message: The project's source code is not publicly readable.
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Change repository visibility via the
#     [Settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility#changing-a-repositorys-visibility)
#     page on GitHub.
#   def:
#     provider_traits: ["rest", "github"]
#     in_entity: repository
#     ingest:
#       type: rest
#       rest:
#         endpoint: "/repos/{{.Entity.Owner}}/{{.Entity.Name}}"
#         parse: json
#     eval:
#       rego:
#         type: deny-by-default

package minder

import rego.v1

default allow := false

allow if {
	# This rule checks whether the repository is private using
	# info tied to the entity itself.
	input.ingested.visibility == "public"
	input.ingested.clone_url != ""
}
