ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}

# Various support documentation file scenarios
support_files = txtar(read_file("testdata/support.txtar"))

def filter_supports(filter):
    """Filter the support_files using a boolean filter function"""
    return {k:support_files[k] for k in support_files if filter(k)}

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
