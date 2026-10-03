# METADATA
#
# name: osps-qa-05-01
# title: Version control does not contain generated executable artifacts
# description: |
#   This rule ensures that the repository does not contain any generated executable
#   artifacts.  It is difficult to review and ascertain the provenance of binary
#   artifacts; instead, they should be generated at build time or stored in a separate
#   store (such as a package repository) and fetched during specific well-documented
#   pipeline steps.
# custom:
#   short_failure_message: Binary artifacts found in the repository
#   severity:
#     value: high
#   release_phase: alpha
#   guidance: |
#     Replace executable binary artifacts in the repository with build pipeline scripts
#     which install the necessary commands after validating their authenticity (for
#     example, by verifying checksums or signatures).
#   def:
#     provider_traits: ["git"]
#     in_entity: repository
#     ingest:
#       type: git
#     eval:
#       rego:
#         type: constraints

package minder

import rego.v1

# N.B. creating this test case in a test would cause this repo to fail the check,
# so we do not have this test case yet.
violations contains {"msg": msg} if {
	# Walk all files in the repo
	files_in_repo := file.walk(".")

	some current_file in files_in_repo

	http_type := file.http_type(current_file)
	http_type == "application/octet-stream"

	msg := sprintf("Binary artifact found: %s", [current_file])
}
