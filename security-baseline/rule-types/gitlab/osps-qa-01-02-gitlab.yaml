# METADATA
#
# name: osps-qa-01-02-gitlab
# title: Maintain publicly readable change history
# description: |
#   Ensure that the project's change history is publicly readable and
#   cannot be overwritten, maintaining transparency and trust in the
#   development process.
# custom:
#   short_failure_message: Repository must be public and prevent force pushes
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     1. Make sure the repository is public via GitLab's
#       repository visibility settings.
#     2. Ensure force pushes are disabled via the protected branches
#       settings for the default branch.
#   def:
#     provider_traits: ["rest", "gitlab"]
#     in_entity: repository
#     ingest:
#       type: rest
#       rest:
#         endpoint: '/projects/{{.Entity.RepoId}}/protected_branches/{{.Entity.DefaultBranch}}'
#         parse: json
#         fallback:
#           - http_code: 404
#             body: |
#               {"http_status": 404, "message": "Not Protected"}
#     eval:
#       rego:
#         type: deny-by-default

package minder

import rego.v1

default allow := false

allow if {
  not input.properties.is_private
  input.ingested.allow_force_push == false
}
