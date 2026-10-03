# METADATA
#
# name: osps-gv-02-01
# title: The project has mechanisms for public discussion
# description: |
#   Projects should encourage open communication and collaboration
#   within the their community, enabling users to provide feedback and
#   discuss proposed changes or usage challenges.
# custom:
#   short_failure_message: The project does not publicize mechanisms for public discussion.
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Enable "Issues" or "Discussions" via the
#     [Settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository)
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

allow if input.ingested.has_issues
allow if input.ingested.has_discussions
