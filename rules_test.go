package main

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/reflect/protoreflect"
	"gopkg.in/yaml.v3"

	minderv1 "github.com/mindersec/minder/pkg/api/protobuf/go/minder/v1"
	rtengine "github.com/mindersec/minder/pkg/engine/v1/rtengine"
	tkv1 "github.com/mindersec/minder/pkg/testkit/v1"
)

type RuleTestSuite struct {
	Version string `yaml:"version"`
	// Tests is a list of rule tests
	Tests []RuleTest `yaml:"tests"`
}

type RuleTest struct {
	// Name is the name of the rule
	Name string `yaml:"name"`
	// Def is the definition of the rule type
	Def map[string]any `yaml:"def"`
	// Params is the parameters for the rule type
	Params map[string]any       `yaml:"params"`
	Entity EntityVersionWrapper `yaml:"entity"`
	// Expect is the expected result of the test
	Expect ExpectResult `yaml:"expect"`
	// ErrorText is the expected error text of the test
	ErrorText string `yaml:"error_text"`
	// Git is the configuration for the git test
	Git *GitTest `yaml:"git"`
	// HTTP is the configuration for the HTTP test
	HTTP *HTTPTest `yaml:"http"`
}

type EntityVersionWrapper struct {
	Type   string                    `yaml:"type"`
	Entity protoreflect.ProtoMessage `yaml:"entity"`
}

// The Entity Key in EntityVersionWrapper requires a custom unmarshaler
// Version and Type can be parsed as is.
// The Entity field depends on the Type field.
func (e *EntityVersionWrapper) UnmarshalYAML(value *yaml.Node) error {
	var entity map[string]any
	if err := value.Decode(&entity); err != nil {
		return err
	}

	typ, ok := entity["type"]
	if !ok {
		return errors.New("missing type field from entity definition")
	}

	e.Type, ok = typ.(string)
	if !ok {
		return errors.New("entity type field must be a string")
	}

	switch e.Type {
	case "repo", "repository":
		e.Entity = &minderv1.Repository{}
	default:
		e.Entity = &minderv1.EntityInstance{}
	}

	entityBytes, err := json.Marshal(entity["entity"])
	if err != nil {
		return err
	}

	return protojson.Unmarshal(entityBytes, e.Entity)
}

type GitTest struct {
	// RepoBase is the base directory for the stubbed git repository
	// Note that the base must be under the rule type's test data directory
	RepoBase string `yaml:"repo_base"`
}

type HTTPTest struct {
	// Status is the HTTP status code to return
	Status int `yaml:"status"`
	// Body is the body to return
	Body string `yaml:"body"`
	// BodyFile is the file to read the body from
	BodyFile string `yaml:"body_file"`
	// Headers is the headers to return
	Headers map[string]string `yaml:"headers"`
}

// ExpectResult is an enum for the possible results of a test
type ExpectResult string

const (
	// ExpectPass indicates that the test is expected to pass
	ExpectPass ExpectResult = "pass"
	// ExpectFail indicates that the test is expected to fail
	ExpectFail ExpectResult = "fail"
	// ExpectError indicates that the test is expected to error
	ExpectError ExpectResult = "error"
	// ExpectSkip indicates that the test is expected to be skipped
	ExpectSkip ExpectResult = "skip"
)

func ParseRuleTypeTests(f io.Reader) (*RuleTestSuite, error) {
	suite := &RuleTestSuite{}

	err := yaml.NewDecoder(f).Decode(suite)
	if err != nil {
		return nil, err
	}

	return suite, nil
}

type RuleTypeTestFunc func(t *testing.T, rt *minderv1.RuleType, suite *RuleTest, rtDataPath string)

func TestRuleTypes(t *testing.T) {
	t.Parallel()

	require.NoError(t, os.Setenv("REGO_ENABLE_PRINT", "true"))

	for _, folder := range []string{"rule-types", "security-baseline/rule-types"} {
		// iterate rule types directory
		err := walkRuleTypesTests(t, folder, func(t *testing.T, rt *minderv1.RuleType, tc *RuleTest, rtDataPath string) {
			var opts []tkv1.Option
			if rt.Def.Ingest.Type == "git" {
				opts = append(opts, gitTestOpts(t, tc, rtDataPath))
			} else if rt.Def.Ingest.Type == "rest" {
				opts = append(opts, httpTestOpts(t, tc, rtDataPath))
			} else {
				t.Skipf("Unsupported ingest type %s", rt.Def.Ingest.Type)
			}

			ztw := zerolog.NewTestWriter(t)
			zerolog.SetGlobalLevel(zerolog.DebugLevel)
			ctx := zerolog.New(ztw).With().Timestamp().Logger().WithContext(context.Background())

			tk := tkv1.NewTestKit(opts...)
			rte, err := rtengine.NewRuleTypeEngine(ctx, rt, tk, nil)
			require.NoError(t, err)

			val := rte.GetRuleInstanceValidator()
			require.NoError(t, val.ValidateRuleDefAgainstSchema(tc.Def), "Failed to validate rule definition against schema")
			require.NoError(t, val.ValidateParamsAgainstSchema(tc.Params), "Failed to validate params against schema")

			if tk.ShouldOverrideIngest() {
				rte.WithCustomIngester(tk)
			}

			_, err = rte.Eval(ctx, tc.Entity.Entity, tc.Def, tc.Params, tkv1.NewVoidResultSink())
			if tc.Expect == ExpectPass {
				require.NoError(t, err)
			} else {
				require.Error(t, err)
				if tc.ErrorText != "" {
					require.Equal(t, strings.TrimSpace(tc.ErrorText), strings.TrimSpace(err.Error()))
				}
			}
		})

		if err != nil {
			t.Error(err)
		}
	}
}

func walkRuleTypesTests(t *testing.T, folder string, testfunc RuleTypeTestFunc) error {
	t.Helper()

	return filepath.Walk(folder, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil
		}
		if !isRelevantRuleTypeFile(path) {
			return nil
		}

		t.Run(normalizeTestNameFromPath(path), func(t *testing.T) {
			t.Parallel()

			// tests have the form of <rule path minus extension>.test.yaml
			testPath := removeExtension(path) + ".test.yaml"
			if _, err := os.Stat(testPath); os.IsNotExist(err) {
				t.Skipf("No test file found for rule %s", path)
			}

			// test data path has the form of <rule path minus extension>.testdata
			rtDataPath := removeExtension(path) + ".testdata"
			// parse the test file
			suite, err := openTestSuite(testPath)
			if err != nil {
				t.Error(err)
				return
			}

			// open the rule type file
			rt, err := openRuleType(path)
			if err != nil {
				t.Error(err)
				return
			}

			// override project so that the rule type engine can be created
			if rt.Context == nil {
				rt.Context = &minderv1.Context{}
			}

			prjName := "rule-type-test"
			rt.Context.Project = &prjName

			if err := rt.Validate(); err != nil {
				t.Error(err)
				return
			}

			for _, test := range suite.Tests {
				test := test

				t.Run(test.Name, func(t *testing.T) {
					t.Parallel()

					testfunc(t, rt, &test, rtDataPath)
				})
			}
		})

		return nil
	})
}

func normalizeTestNameFromPath(p string) string {
	return removeExtension(p[len("rule-types")+1:])
}

func removeExtension(p string) string {
	return p[:len(p)-len(filepath.Ext(p))]
}

func isRelevantRuleTypeFile(path string) bool {
	return (filepath.Ext(path) == ".yaml" || filepath.Ext(path) == ".yml") && !isTestFile(path)
}

func isTestFile(path string) bool {
	return strings.HasSuffix(path, ".test.yaml") || strings.HasSuffix(path, ".test.yml")
}

func openTestSuite(testPath string) (*RuleTestSuite, error) {
	// open the test file
	testFile, err := os.Open(testPath)
	if err != nil {
		return nil, err
	}

	defer testFile.Close()

	// parse the test file
	suite, err := ParseRuleTypeTests(testFile)
	if err != nil {
		return nil, err
	}

	return suite, nil
}

func openRuleType(path string) (*minderv1.RuleType, error) {
	// open the rule type file
	ruleTypeFile, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	defer ruleTypeFile.Close()

	// parse the rule type file
	rt := &minderv1.RuleType{}
	err = minderv1.ParseResource(ruleTypeFile, rt)
	if err != nil {
		return nil, err
	}

	return rt, nil
}

func gitTestOpts(t *testing.T, tc *RuleTest, rtDataPath string) tkv1.Option {
	require.NotNil(t, tc.Git, "Git test is missing for test")
	require.DirExistsf(t, rtDataPath, "Rule type test data directory %s does not exist", rtDataPath)
	return tkv1.WithGitDir(filepath.Join(rtDataPath, tc.Git.RepoBase))
}

func httpTestOpts(t *testing.T, tc *RuleTest, rtDataPath string) tkv1.Option {
	require.NotNil(t, tc.HTTP, "HTTP test is missing for test")

	if tc.HTTP.Status == 0 {
		tc.HTTP.Status = http.StatusOK
	}

	if tc.HTTP.Headers == nil {
		tc.HTTP.Headers = make(map[string]string)
	}

	if tc.HTTP.BodyFile != "" {
		require.DirExistsf(t, rtDataPath, "Rule type test data directory %s does not exist", rtDataPath)
		tc.HTTP.Body = readFile(t, rtDataPath, tc.HTTP.BodyFile)
	}
	return tkv1.WithHTTP(tc.HTTP.Status, []byte(tc.HTTP.Body), tc.HTTP.Headers)
}

func readFile(t *testing.T, dir, file string) string {
	t.Helper()

	data, err := os.ReadFile(filepath.Join(dir, file))
	require.NoError(t, err, "failed to read file %s", file)

	return string(data)
}
