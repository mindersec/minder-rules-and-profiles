ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"github/repo_owner": "me", "github/repo_name": "myrepo"}
}
REPO_URL = "/repos/me/myrepo"

def test_do_01_01_insights():
    res = eval(
        rule="osps-do-01-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "SECURITY-INSIGHTS.yaml": "documentation:\n- ./README.md"
        }
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_do_01_01_homepage():
    res = eval(
        rule="osps-do-01-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={},
        mock_http={
            REPO_URL: body('{"homepage": "https://example.com/"}')
        }
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_do_01_01_docs_dir():
    res = eval(
        rule="osps-do-01-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "docs/index.md": "Documentation",
            "docs/extra.rst": "Documentation",
            "docs/plain.txt": "Old School",
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_do_01_01_readme_usage():
    res = eval(
        rule="osps-do-01-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "README.md": "Example usage:\n```\nimport mylib\n...\n```"
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_do_01_01_readme_heading():
    res = eval(
        rule="osps-do-01-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "README.md": "# ProjectName \n## Usage\n\nHere is a helpful guide",
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_do_01_01_no_docs():
    res = eval(
        rule="osps-do-01-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "README.md": "I dunno, ask codex or something",
        },
    )
    assert.eq(res["status"], "fail")
    # Some versions of mindev don't expose "details" and combine it with "message"
    detail = res.get("details", res["message"])
    assert.true(detail.count("No user guides or project documentation found") > 0)

def test_do_02_01_issues_enabled():
    res = eval(
        rule="osps-do-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"has_issues": true, "has_discussions": false}')
        }
    )
    assert.eq(res["status"], "pass")

def test_do_02_01_discussions_enabled():
    res = eval(
        rule="osps-do-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"has_issues": false, "has_discussions": true}')
        }
    )
    assert.eq(res["status"], "pass")

def test_do_02_01_no_feedback():
    res = eval(
        rule="osps-do-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"has_issues": false, "has_discussions": false}')
        }
    )
    assert.eq(res["status"], "fail")

def test_do_02_01_does_not_exist():
    res = eval(
        rule="osps-do-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('').code(404)
        }
    )
    assert.eq(res["status"], "error")
