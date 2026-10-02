# METADATA
#
# name: osps-ac-03-02-gitlab
# title: Prevent permanent branch deletion
# description: Requires the default branch to be protected
# custom:
#   short_failure_message: Default branch is not protected
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Ensure that the default branch is protected.
#
#     GitLab has no separate "allow deletions" setting for a protected branch.
#     A protected branch cannot be deleted with `git push` or any third-party
#     Git client, regardless of role. Deleting a protected branch is only
#     possible through the GitLab UI or API, and only by users with at least
#     the Maintainer role.
#
#     Protecting the default branch is therefore what prevents it from being
#     casually or accidentally deleted.
#
#     For more information, see GitLab's documentation on
#     protected branches: https://docs.gitlab.com/user/project/protected_branches/
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

msg := "The default branch is not protected"

allow if {
  input.ingested.id
}
