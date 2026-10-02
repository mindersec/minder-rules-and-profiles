# METADATA
#
# name: osps-do-02-01-gitlab
# title: Public feedback mechanism supported
# description: |
#   Ensures that public feedback via GitLab issues is available for users
#   of the software, allowing them to report bugs and suggest improvements.
# custom:
#   short_failure_message: No public feedback mechanism found
#   severity:
#     value: medium
#   release_phase: alpha
#   guidance: |
#     Ensure that issues are enabled on the repository, and that users can
#     view issues and find reports from other users.
#
#     Note: GitLab does not have a "Discussions" feature equivalent to
#     GitHub. Only issue tracker availability is checked here.
#
#     This rule will not currently detect the usage of an external feedback
#     system (for example, Jira or Trello).
#   def:
#     provider_traits: ["rest", "gitlab"]
#     in_entity: repository
#     ingest:
#       type: rest
#       rest:
#         endpoint: '/projects/{{.Entity.RepoId}}'
#         parse: json
#         fallback:
#           - http_code: 404
#             body: |
#               {"http_status": 404, "message": "Repo not found"}
#     eval:
#       rego:
#         type: deny-by-default

package minder

import rego.v1

default allow := false

allow if input.ingested.issues_enabled
