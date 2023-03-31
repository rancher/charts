package rancher_gatekeeper_crd

import (
	"testing"

	"github.com/rancher/hull/pkg/test"
)

func TestChart(t *testing.T) {
	opts := test.GetRancherOptions()
	opts.Coverage.IncludeSubcharts = false
	opts.Coverage.Disabled = false
	opts.YAMLLint.Enabled = false
	suite.Run(t, opts)
}
