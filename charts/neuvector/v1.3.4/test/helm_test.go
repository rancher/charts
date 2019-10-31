package test

import (
	"strings"
)

func splitYaml(out string) []string {
	outputs := make([]string, 0)

	outs := strings.Split(out, "---")
	for _, out := range outs {
		if len(out) > 0 {
			outputs = append(outputs, out)
		}
	}
	return outputs
}
