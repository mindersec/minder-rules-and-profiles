ENTITY={"type": "repository", "default_branch": "main",
  "properties": {"github/repo_owner": "mindersec", "github/repo_name": "minder"}}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")


def read_scenario(filename):
    """read_scenario returns a filesystem and HTTP mock for the given file.
    
    HTTP content is indicated by filenames ending in .json, and all other content
    is considered git files.
    """
    content = txtar(read_file(filename))
    fs = {path: content[path] for path in content if not path.endswith(".json")}
    http = {path[:-len(".json")]: body(content[path]) for path in content if path.endswith(".json")}
    return fs, http



def test_empty_repo():
    fs, http = read_scenario("testdata/new_repo.txtar")
    exists_result = eval(
        rule="insights_exists",
        entity=ENTITY,
        data_sources=["../data-sources/insightsghapi.yaml"],
        mock_fs=fs,
        mock_http=http,
    )
    update_result = eval(
        rule="insights_up_to_date",
        entity=ENTITY,
        data_sources=["../data-sources/insightsghapi.yaml"],
        mock_fs=fs,
        mock_http=http,
    )
    assert.eq(exists_result["status"], "fail")
    # We don't try to update a file that isn't there.
    assert.eq(update_result["status"], "fail")
    # Assert on the actual security-insights.yml content (except dates) that would be created.
    expected_contents = """
project:
  administrators:
  - name: evankanderson
    primary: false
  name: minder
  repositories:
  - comment: null
    name: minder
    url: https://github.com/mindersec/minder
  vulnerability-reporting:
    bug-bounty-available: false
repository:
  accepts-automated-change-request: true
  accepts-change-request: true
  core-team:
  - name: evankanderson
    primary: false
  documentation: {}
  license:
    expression: Apache-2.0
    url: https://api.github.com/licenses/apache-2.0
  security:
    assessments:
      self:
        comment: Not yet performed
  status: active
  url: https://github.com/mindersec/minder
"""
    assert.true(expected_contents in exists_result["output"]["content"])


def test_complete_repo():
    fs, http = read_scenario("testdata/minder.txtar")
    exists_result = eval(
        rule="insights_exists",
        entity=ENTITY,
        data_sources=["../data-sources/insightsghapi.yaml"],
        mock_fs=fs,
        mock_http=http,
    )
    update_result = eval(
        rule="insights_up_to_date",
        entity=ENTITY,
        data_sources=["../data-sources/insightsghapi.yaml"],
        mock_fs=fs,
        mock_http=http,
    )

    assert.eq(exists_result["status"], "pass")
    assert.eq(exists_result["message"], "")
    assert.eq(update_result["status"], "pass")
