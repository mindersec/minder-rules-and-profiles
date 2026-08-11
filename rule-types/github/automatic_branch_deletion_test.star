ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main"
}

RULE = "automatic_branch_deletion"

def build_mock_http(delete_branch_on_merge):
    return {
        "/repos/mindersec/minder": body('{"delete_branch_on_merge": ' + ("true" if delete_branch_on_merge else "false") + '}')
    }

def test_automatic_branch_deletion_enabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        mock_http=build_mock_http(True)
    )
    assert.eq(res["status"], "pass")

def test_automatic_branch_deletion_disabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        mock_http=build_mock_http(False)
    )
    assert.eq(res["status"], "fail")
