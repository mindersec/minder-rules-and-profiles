# METADATA
#
# name: osps-qa-01-01-gitlab
# title: The project's source code is publicly readable
# description: |
#   Enable users to access and review the project's source code and
#   history, promoting transparency and collaboration within the project
#   community.
# custom:
#   short_failure_message: The project's source code is not publicly readable.
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Change repository visibility via the
#     [Settings](https://docs.gitlab.com/user/public_access/)
#     page on GitLab.
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

allow if {
	input.ingested.visibility == "public"
	input.ingested.http_url_to_repo != ""
}
