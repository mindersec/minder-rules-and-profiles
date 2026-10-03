# METADATA
#
# name: osps-qa-05-02
# title: Version control does not contain binary artifacts
# description: |
#   This rule ensures that the repository does not contain any unreviewable
#   binary artifacts.  It is difficult to review and ascertain the provenance
#   of binary artifacts such as application binaries or compressed archives.
#
#   This prohibition does not include files which are commonly used to store
#   images, sound, or other media assets, which can generally be reviewed
#   using standard tools.
# custom:
#   short_failure_message: Binary artifacts found in the repository
#   severity:
#     value: high
#   release_phase: alpha
#   guidance: |
#     Avoid storing artifacts for uncommon file types which cannot easily be
#     reviewed.
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

permitted_prefixes := [
	"image/",
	"audio/",
	"video/",
	"text/",
	"application/pdf",
]

permitted_type(http_type) if {
	some prefix in permitted_prefixes
	startswith(http_type, prefix)
}

# N.B. creating this test case in a test would cause this repo to fail the check,
# so we do not have this test case yet.
violations contains {"msg": msg} if {
	# Walk all files in the repo
	files_in_repo := file.walk(".")

	some current_file in files_in_repo

	http_type := file.http_type(current_file)
	not permitted_type(http_type)

	msg := sprintf("Unreviewable artifact found: %s of type %s", [current_file, http_type])
}
