ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))

def eval_dockerfile(dockerfile):
    return eval(
        rule="dockerfile_no_latest_tag",
        entity=ENTITY,
        mock_fs={"Dockerfile": dockerfile}
    )

def test_pinned_tag_passes():
    PASS(eval_dockerfile("""
FROM golang:1.21.4
RUN echo hello
"""))

def test_digest_pinned_passes():
    PASS(eval_dockerfile("""
FROM golang@sha256:337543447173c2238c78d4851456760dcc57c1dfa8c3bcd94cbee8b0f7b32ad0
RUN echo hello
"""))

def test_multistage_pinned_passes():
    PASS(eval_dockerfile("""
FROM node:20 AS builder
RUN npm ci
FROM golang:1.21.4
COPY --from=builder /app /app
"""))

def test_latest_tag_fails():
    FAIL(eval_dockerfile("""
FROM golang:latest
RUN echo hello
"""))

def test_platform_latest_tag_fails():
    FAIL(eval_dockerfile("""
FROM --platform=$BUILDPLATFORM golang:latest AS build
RUN echo hello
"""))

# An image reference without any tag implicitly resolves to 'latest',
# so it must fail as well (this is why the rego matches `FROM [^: ]+`).
def test_untagged_base_image_fails():
    FAIL(eval_dockerfile("""
FROM scratch
COPY app /app
"""))

def test_mixed_pinned_and_latest_fails():
    FAIL(eval_dockerfile("""
FROM node:20 AS builder
FROM golang:1.21.4 AS build
FROM debian:latest
"""))
