package common

import "github.com/rancher/hull/pkg/checker"

func GetSystemDefaultRegistry(tc *checker.TestContext) string {
	systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
	if systemDefaultRegistry != "" {
		systemDefaultRegistry += "/"
	}
	return systemDefaultRegistry
}
