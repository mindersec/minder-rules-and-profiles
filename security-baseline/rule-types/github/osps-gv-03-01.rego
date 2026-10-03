# METADATA
#
# name: osps-gv-03-01
# title: Contribution process is explained
# description: |
#   Ensure that either a CONTRIBUTING file or CONTRIBUTING/ folder is
#   available.
# custom:
#   short_failure_message: No CONTRIBUTING file or folder was found
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Source code must be accompanied by a `CONTRIBUTING` file or a
#     `CONTRIBUTING/` folder at the root of the project source tree.
#   def:
#     provider_traits: ["git"]
#     in_entity: repository
#     ingest:
#       type: git
#     eval:
#       rego:
#         type: deny-by-default

package minder

import rego.v1

default allow := false

allow if {
	files := file.ls_glob("./CONTRIBUTING*")

	some name
	content := file.read(files[name])
	"" != content
}

allow if {
	files := file.ls_glob("./CONTRIBUTING/*")

	some name
	content := file.read(files[name])
	"" != content
}
