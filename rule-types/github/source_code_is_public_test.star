# source_code_is_public ingests via the "git" driver with the github
# provider, so the repository metadata must be provided through entity
# properties (the clone url is derived from github/repo_owner and
# github/repo_name). The rule's rego then checks input.properties.is_private.
ENTITY_PUBLIC = {
    "owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main",
    "properties": {
        "github/repo_owner": "coolhead",
        "github/repo_name": "haze-wave",
        "github/default_branch": "main",
        "is_private": False,
    },
}

ENTITY_PRIVATE = {
    "owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main",
    "properties": {
        "github/repo_owner": "coolhead",
        "github/repo_name": "haze-wave",
        "github/default_branch": "main",
        "is_private": True,
    },
}

def source_code_is_public(entity):
    """Helper to build eval result for the source_code_is_public rule."""
    return eval(
        rule="source_code_is_public",
        entity=entity,
        mock_fs={},
    )

def test_public_repo_passes():
    res = source_code_is_public(ENTITY_PUBLIC)
    assert.eq(res["status"], "pass")

def test_private_repo_fails():
    res = source_code_is_public(ENTITY_PRIVATE)
    assert.eq(res["status"], "fail")
