ENTITY = {
    "owner": "me",
    "name": "myrepo",
    "type": "repository",
    "default_branch": "main",
}

def test_br_03_02_https_only():
    res = eval(
        rule="osps-br-03-02",
        entity=ENTITY,
        mock_fs={
            "README.md": "Download releases from https://example.com/releases",
        },
    )
    assert.eq(res["status"], "pass")

def test_br_03_02_localhost_only():
    res = eval(
        rule="osps-br-03-02",
        entity=ENTITY,
        mock_fs={
            "README.md": "Development mirror: http://localhost:8080/releases",
        },
    )
    assert.eq(res["status"], "pass")

def test_br_03_02_checks_all_http_urls():
    res = eval(
        rule="osps-br-03-02",
        entity=ENTITY,
        mock_fs={
            "README.md": "Development mirror: http://localhost:8080/releases\nPublic release: http://example.com/releases",
        },
    )
    assert.eq(res["status"], "fail")
