# METADATA
#
# name: osps-qa-01-02
# title: Maintain publicly readable change history
# description: |
#   Ensure that the project's change history is publicly readable and 
#   cannot be overwritten, maintaining transparency and trust in the 
#   development process. This helps maintain a complete and accurate history of all
#   changes made to the codebase.
# custom:
#   short_failure_message: Repository must be public and prevent force pushes
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     1. Make sure the repository is public via the
#       [Repository Settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility) page.
#     2. Ensure force pushes are disabled in branch protection rules via the
#       [Branch protection settings](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule).
#   def:
#     provider_traits: ["rest", "github"]
#     in_entity: repository
#     ingest:
#       type: rest
#       rest:
#         endpoint: '/repos/{{.Entity.Owner}}/{{.Entity.Name}}/branches/{{.Entity.DefaultBranch}}/protection'
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
  not input.ingested.allow_force_pushes.enabled 
}
