package test

import (
	"fmt"
	"github.com/stretchr/testify/require"
	"k8s.io/api/batch/v1"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
)

func TestHelmTemplateSucceeds(t *testing.T) {
	changed := os.Getenv("CHANGED_PATHS")
	logger.Log(t, fmt.Sprintf("Changed paths: %s ", changed))
	wd, _ := os.Getwd()
	logger.Log(t, fmt.Sprintf("Current Working Directory: %s ", wd))
	helmChartPath := fmt.Sprintf("%s/../../../packages/rancher-istio/charts", wd)
	logger.Log(t, fmt.Sprintf("HelmchartPath: %s ", helmChartPath))
	releaseName := "rancher-istio"
	namespaceName := "istio-system"
	options := &helm.Options{
        SetValues: map[string]string{"namespace": namespaceName,},
		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
    }
	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/istio-install-job.yaml"})
	var job v1.Job
	helm.UnmarshalK8SYaml(t, output, &job)
	require.Equal(t, namespaceName, job.Namespace)
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
