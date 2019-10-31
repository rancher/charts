package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestEnforcerDaemonset(t *testing.T) {
	helmChartPath := ".."

	options := &helm.Options{
		SetValues: map[string]string{},
	}

	// Test ingress
	out := helm.RenderTemplate(t, options, helmChartPath, []string{"templates/enforcer-daemonset.yaml"})
	outs := splitYaml(out)

	if len(outs) != 1 {
		t.Errorf("Resource count is wrong. count=%v\n", len(outs))
	}
}
