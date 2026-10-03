ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"github/repo_owner": "me", "github/repo_name": "myrepo"}
}
REPO_URL = "/repos/me/myrepo"

# Various support documentation file scenarios
support_files = txtar(read_file("testdata/support.txtar"))

def filter_supports(filter):
    """Filter the support_files using a boolean filter function"""
    return {k:support_files[k] for k in support_files if filter(k)}

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
    assert.true(res["message"].count("No user guides or project documentation found") > 0)

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

def test_do_04_01_support_in_readme():
    res = eval(
        rule="osps-do-04-01",
        entity=ENTITY,
        mock_fs={
            "README.md": support_files["support-README.md"]
        }
    )
    assert.eq(res["status"], "pass")

def test_do_04_01_support_with_eox():
    # Note that this rule only supports a _nested_ eox file, not a top-level one
    res = eval(
        rule="osps-do-04-01",
        entity=ENTITY,
        mock_fs=filter_supports(lambda file: file.count(".eox") > 0 or file == "README.md")
    )
    assert.eq(res["status"], "pass")

def test_do_04_01_support_with_document():
    res = eval(
        rule="osps-do-04-01",
        entity=ENTITY,
        mock_fs=filter_supports(lambda file: file == "SUPPORT.md" or file == "README.md")
    )
    assert.eq(res["status"], "pass")

def test_do_04_01_no_support_policy():
    res = eval(
        rule="osps-do-04-01",
        entity=ENTITY,
        mock_fs=filter_supports(lambda file: file == "README.md")
    )
    assert.eq(res["status"], "fail")
