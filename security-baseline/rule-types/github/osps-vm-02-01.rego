# METADATA
#
# name: osps-vm-02-01
# title: Contacts and process for reporting vulnerabilities is published
# description: |
#   This rule ensures that the repository provides a clear process and contact information 
#   for reporting vulnerabilities. 
#   It checks for the presence of a SECURITY.md file containing relevant reporting 
#   details or verifies if GitHub's private vulnerability reporting feature is enabled.
# custom:
#   short_failure_message: No contacts or process for reporting vulnerabilities was found
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     To address this issue:
#     1. Add a `SECURITY.md` file to your repository:
#       - Ensure it includes instructions for reporting vulnerabilities, including contact details and a clear process.
#       - Refer to [GitHub's documentation on SECURITY.md](https://docs.github.com/en/code-security).
#     2. Alternatively, enable GitHub's private vulnerability reporting:
#       - Navigate to the repository's "Settings" - "Security and Analysis."
#       - Enable "Private vulnerability reporting."
#   def:
#     provider_traits: ["git", "rest", "github"]
#     in_entity: repository
#     ingest:
#       type: git
#     eval:
#       data_sources:
#         - name: baselineghapi
#       rego:
#         type: deny-by-default

package minder

import rego.v1

default allow := false

# Allow if SECURITY.md exists and contains "report"
allow if {
  # Search specifically for SECURITY.md
  files := file.ls_glob("./SECURITY*")
  count(files) > 0

  # Read the content of the file
  content := lower(file.read(files[0]))

  # Check if "report" exists in the content
  contains(content, "report")
}

# Allow if GitHub vulnerability reporting is enabled
allow if {
  # Query the GitHub API to check vulnerability reporting status
  out = minder.datasource.baselineghapi.private_vuln_reporting({
    "owner": input.properties["github/repo_owner"],
    "repo": input.properties["github/repo_name"],
  })

  # Ensure private vulnerability reporting is enabled
  out.body.enabled == true
}
