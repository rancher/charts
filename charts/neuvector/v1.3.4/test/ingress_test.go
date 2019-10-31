package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	extv1beta1 "k8s.io/api/extensions/v1beta1"
)

func TestIngress(t *testing.T) {
	helmChartPath := ".."

	options := &helm.Options{
		SetValues: map[string]string{
			"controller.ingress.enabled": "true",
			"manager.ingress.enabled":    "true",
		},
	}

	// Test ingress
	out := helm.RenderTemplate(t, options, helmChartPath, []string{"templates/ingress.yaml"})
	outs := splitYaml(out)

	if len(outs) != 2 {
		t.Errorf("Resource count is wrong. count=%v\n", len(outs))
	}

	for i, output := range outs {
		var ing extv1beta1.Ingress
		helm.UnmarshalK8SYaml(t, output, &ing)

		switch i {
		case 0:
			if ing.Name != "neuvector-webui-ingress" {
				t.Errorf("Ingress name is wrong. name=%v\n", ing.Name)
			}
		case 1:
			if ing.Name != "neuvector-restapi-ingress" {
				t.Errorf("Ingress name is wrong. name=%v\n", ing.Name)
			}
		}
	}
}
