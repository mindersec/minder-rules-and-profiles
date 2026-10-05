# METADATA
#
# name: osps-le-02-01
# title: License meets the OSI or the FSF definition
# description: |
#   Ensure that the project's source code is distributed under a
#   recognized and legally enforceable open source software license.
# custom:
#   short_failure_message: License does not meet OSI or FSF definition
#   severity:
#     value: info
#   release_phase: alpha
#   guidance: |
#     Ensure that the project's source code is distributed under a
#     recognized and legally enforceable open source software license,
#     providing clarity on how the code can be used and shared by others.
#   def:
#     provider_traits: ["rest", "github"]
#     in_entity: repository
#     ingest:
#       type: rest
#       rest:
#         endpoint: '/repos/{{.Entity.Owner}}/{{.Entity.Name}}/license'
#         parse: json
#         fallback:
#           - http_code: 404
#             body: |
#               {"http_status": 404, "message": "License details not found"}
#     eval:
#       data_sources:
#         - name: spdx
#       rego:
#         type: constraints

package minder

import rego.v1

violations contains {"msg": msg} if {
	not input.ingested.license
	msg := "License details not found"
}

violations contains {"msg": msg} if {
	input.ingested.license
	license := input.ingested.license.spdx_id

	resp2 := minder.datasource.spdx.licenses({})
	licenses := resp2.body.licenses
	osi := {l.licenseId | l := licenses[_]; l.isOsiApproved}
	fsf := {l.licenseId | l := licenses[_]; l.isFsfLibre}
	approved_licenses := osi | fsf

	count(approved_licenses) != 0
	license != null
	not license in approved_licenses
	msg := sprintf("License %s is not OSI/FSF approved", [license])
}
