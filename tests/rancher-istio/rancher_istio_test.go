package rancher_istio

import (
	"testing"

	"github.com/rancher/hull/pkg/test"
)

func TestChart(t *testing.T) {
	opts := test.GetRancherOptions()
	opts.Coverage.IncludeSubcharts = false
	opts.Coverage.Disabled = true
	opts.YAMLLint.Enabled = false
	suite.Run(t, opts)
}
