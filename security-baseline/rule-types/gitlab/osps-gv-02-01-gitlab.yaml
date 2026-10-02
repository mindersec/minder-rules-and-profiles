# METADATA
#
# name: osps-gv-02-01-gitlab
# title: The project has mechanisms for public discussion
# description: |
#   Projects should encourage open communication and collaboration
#   within their community, enabling users to provide feedback and
#   discuss proposed changes or usage challenges.
# custom:
#   short_failure_message: The project does not publicize mechanisms for public discussion.
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Enable "Issues" via the
#     [Settings](https://docs.gitlab.com/user/project/settings/)
#     page on GitLab.
#
#     Note: GitLab does not have a standalone "Discussions" feature
#     equivalent to GitHub. Issue tracker availability is used as the
#     proxy for public discussion mechanisms.
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
