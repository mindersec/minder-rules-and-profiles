# METADATA
#
# name: osps-br-03-01-gitlab
# title: Development resources use secure channels
# description: Verifies that websites and version control systems for development use secure channels.
# custom:
#   short_failure_message: Insecure access to VCS
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Any websites and version control systems involved in the project
#     development MUST be delivered using SSH, HTTPS, or other encrypted
#     channels.
#
#     GitLab does this by default.
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

allow if startswith(input.ingested.http_url_to_repo, "https://")
