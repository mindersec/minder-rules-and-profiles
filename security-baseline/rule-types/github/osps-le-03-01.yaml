# METADATA
#
# name: osps-le-03-01
# title: LICENSE or COPYING files are available
# description: |
#   Ensure that either LICENSE file, COPYING file, or LICENSE/ folder
#   are available.
# custom:
#   short_failure_message: No LICENSE or COPYING file found.
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Source code must be accompanied by a `LICENSE` or `COPYING` file, or
#     a `LICENSE/` folder at the root of the project source tree.
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
  files := file.ls_glob("./LICENSE*")

  some name
  content := file.read(files[name])
  "" != content
}

allow if {
  files := file.ls_glob("./COPYING*")

  some name
  content := file.read(files[name])
  "" != content
}

allow if {
  files := file.ls_glob("./LICENSE/*")

  some name
  content := file.read(files[name])
  "" != content
}
