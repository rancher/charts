package unit

import (
	"fmt"
	"github.com/stretchr/testify/require"
	"io/ioutil"
	"k8s.io/api/batch/v1"
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
)

func TestHelmTemplateSucceeds(t *testing.T) {
	wd, _ := os.Getwd()
	chart := os.Getenv("CHART")
	if chart == "" {
		files, err := ioutil.ReadDir(fmt.Sprintf("%s/../../../packages", wd))
		if err != nil {
			log.Fatal(err)
		}

		for _, f := range files {
			fmt.Println(f.Name())
		}
	}
	logger.Log(t, fmt.Sprintf("Running common rests for: %s ", chart))
	helmChartPath := fmt.Sprintf("%s/../../../packages/%s/charts", wd, chart)
	releaseName := "rancher-istio"
	namespaceName := "istio-system"
	options := &helm.Options{
        SetValues: map[string]string{"namespace": namespaceName,},
		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
    }
	var job v1.Job
	helm.UnmarshalK8SYaml(t, filelocation, &job)
	require.Equal(t, "boots", job.Image)
}

func TestSystemDefaultRegistry(t *testing.T) {
	changedFiles := os.Getenv("FILES_CHANGED")
	helmChartPath := "../../charts"
	logger.Logf(t, "HelmchartPath: %s\n", helmChartPath)
	releaseName := "rancher-istio"
	namespaceName := "istio-system"
	istioOptions := &helm.Options{
        SetValues: map[string]string{"namespace": namespaceName},
		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
    }
	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/deployment.yaml"})
	var deployment appsv1.deployment
	helm.UnmarshalK8SYaml(t, output, &deployment)
}

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
