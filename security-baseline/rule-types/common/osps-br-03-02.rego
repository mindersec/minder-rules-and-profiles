# METADATA
#
# name: osps-br-03-02
# title: Deliver releases via encrypted channels
# description: |
#   This check determines whether the release artifacts of the project
#   are delived via unsecured (unencrypted) channels.
#
#   Downloading release artifacts via unsecured channels is a supply
#   chain risk for consumers, as attackers could compromise the release
#   assets in-transit via a Machine-in-the-Middle (MitM) attack.
# custom:
#   short_failure_message: Releases available via unsecured channels
#   severity:
#     value: high
#   release_phase: alpha
#   guidance: |
#     Deliver artifacts using HTTPS URLs or package repositories.
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

# We only worry about links in e.g. the README, as artifacts
# distributed via GitHub releases or package repositories will already
# be encrypted.

# Currently, we assume that direct downloads are linked from a README
# file, and not elsewhere in the documentation.
readme_contents := file.read("./README.md")
http_urls := regex.find_all_string_submatch_n(`(http://\S*)`, readme_contents, -1)[0]

violations contains {"msg": msg} if {
	some url in http_urls
	not startswith(url, "http://localhost")

	msg := sprintf("README.md contains non-HTTPS URL '%s'", [url])
}
