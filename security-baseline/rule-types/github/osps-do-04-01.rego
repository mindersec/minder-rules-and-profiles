# METADATA
#
# name: osps-do-04-01
# title: Support scope and duration is documented
# description: |
#   Ensure that either a a “Support” header is present in the README,
#   a SUPPORT.md file present in the repo root, or a SUPPORT.eox file
#   is present in the project.
# custom:
#   short_failure_message: No documentation for support was found
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Source code must have a “Support” header in the README, a SUPPORT.md 
#     file present in the repo root, or a SUPPORT.eox file in the OpenEOX format 
#     describing the scope and duration of support for the project’s released 
#     software assets.
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

readme_pattern := "./[Rr][Ee][Aa][Dd][Mm][Ee]*"

# Check if the file contains "support"
has_support_header(file_path) if {
  file_path != null
  content := file.read(file_path)
  contains(lower(content), "support")
}

default allow := false

# Check if the repository has a SUPPORT.md file at the root
allow if {
  files := file.ls_glob("./SUPPORT.md")

  some name
  content := file.read(files[name])
  "" != content
}

# Check if the repository has a README file with a support header
allow if {
  files := file.ls_glob(readme_pattern)

  some name
  has_support_header(files[name])
}

# Check if the repository has a SUPPORT.eox file
allow if {
  files := file.ls_glob("/**/SUPPORT.eox")

  some name
  content := file.read(files[name])
  "" != content
}
