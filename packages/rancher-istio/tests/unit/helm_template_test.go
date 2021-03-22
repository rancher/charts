package test

import (
	"github.com/gruntwork-io/terratest/modules/helm"
	"testing"
)

func TestHardenedCluster(t *testing.T) {
	helm.UnmarshalK8SYaml(t, "templates/generated-chart/", &deployment)

}

// func TestSystemDefaultRegistry(t *testing.T) {
// 	changedFiles := os.Getenv("FILES_CHANGED")
// 	helmChartPath := "../../charts"
// 	logger.Logf(t, "HelmchartPath: %s\n", helmChartPath)
// 	releaseName := "rancher-istio"
// 	namespaceName := "istio-system"
// 	istioOptions := &helm.Options{
//         SetValues: map[string]string{"namespace": namespaceName},
// 		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
//     }
// 	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/deployment.yaml"})
// 	var deployment appsv1.deployment
// 	helm.UnmarshalK8SYaml(t, output, &deployment)
// }

// func TestImagesCorrectFormat(t *testing.T) {
// 	changedFiles := os.Getenv("FILES_CHANGED")
// 	helmChartPath := "../../charts"
// 	logger.Logf(t, "HelmchartPath: %s\n", helmChartPath)
// 	releaseName := "rancher-istio"
// 	namespaceName := "istio-system"
// 	istioOptions := &helm.Options{
//         SetValues: map[string]string{"namespace": namespaceName},
// 		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
//     }
// 	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/deployment.yaml"})
// 	var deployment appsv1.deployment
// 	helm.UnmarshalK8SYaml(t, output, &deployment)
// 	//check that the system default registry works
// 	//check that all images have rancher/ in them
// 	//check that images exist upstream
// }

// func TestChartAnnotationsExist(t *testing.T) {
// 	changedFiles := os.Getenv("FILES_CHANGED")
// 	helmChartPath := "../../charts"
// 	logger.Logf(t, "HelmchartPath: %s\n", helmChartPath)
// 	releaseName := "rancher-istio"
// 	namespaceName := "istio-system"
// 	istioOptions := &helm.Options{
//         SetValues: map[string]string{"namespace": namespaceName},
// 		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
//     }
// 	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/deployment.yaml"})
// 	var deployment appsv1.deployment
// 	helm.UnmarshalK8SYaml(t, output, &deployment)
// 	//check that the required annotations are in the chart.yaml
// }
