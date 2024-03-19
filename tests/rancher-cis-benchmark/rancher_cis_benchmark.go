package rancher_cis_benchmark

import (
	"encoding/json"
	"fmt"

	"github.com/rancher/charts/tests/common"
	"github.com/rancher/hull/pkg/chart"
	"github.com/rancher/hull/pkg/checker"
	"github.com/rancher/hull/pkg/test"
	"github.com/rancher/hull/pkg/utils"
	"github.com/stretchr/testify/assert"
	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var ChartPath = utils.MustGetLatestChartVersionPathFromIndex("../index.yaml", "rancher-cis-benchmark", true)

const (
	DefaultReleaseName = "rancher-cis-benchmark"
	DefaultNamespace   = "cis-operator-system"

	CisOperatorDeployExistsCheck = "CisOperatorDeploymentExistsCheck"
	FoundKey                     = "found"

	PatchSaJobExistsCheck = "PatchSaJobExistsCheck"
)

var suite = test.Suite{
	ChartPath: ChartPath,

	Cases: []test.Case{
		{
			Name: "Using Defaults",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace),
		},
		{
			Name: "Set Values.global.cattle.systemDefaultRegistry",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("global.cattle.systemDefaultRegistry", "test-registry"),
		},
		{
			Name: "Set Values.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("tolerations", testTolerations),
		},
		{
			Name: "Set Values.nodeSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("nodeSelector", testNodeSelector),
		},
		{
			Name: "Set Values.global.cattle.clusterName",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("global.cattle.clusterName", "test-cluster"),
		},
		{
			Name: "Set .Values.global.kubectl.repository and .Values.global.kubectl.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("global", map[string]string{
					"kubectl.repository": "test-kubectl-repo",
					"kubectl.tag":        "v1.20.11",
				}),
		},
		{
			Name: "Set .Values.global.kubectl.imagePullPolicy to IfNotPresent",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("global.imagePullPolicy", "IfNotPresent"),
		},
		{
			Name: "Set .Values.global.kubectl.imagePullPolicy to Always",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("global.imagePullPolicy", "Always"),
		},
		{
			Name: "Set .Values.global.kubectl.imagePullPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("global.imagePullPolicy", "Never"),
		},
		{
			Name: "Set .Values.image.cisoperator.repository and .Values.image.cisoperator.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("image", map[string]string{
					"cisoperator.repository": "test/cis-operator",
					"cisoperator.tag":        "v1.0.0",
				}),
		},
		{
			Name: "Set securityScan and sonobuoy image values",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("image", map[string]string{
					"securityScan.repository": "test/security-scan",
					"securityScan.tag":        "v1.1.0",
					"sonobuoy.repository":     "test/sonobuoy",
					"sonobuoy.tag":            "v1.2.0",
				}),
		},
		{
			Name: "Set alerts configuration values",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("alerts", map[string]interface{}{
					"enabled":     true,
					"severity":    "info",
					"metricsPort": 8099,
				}),
		},
		{
			Name: "Set .Values.alerts.enabled to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("alerts.enabled", false),
		},
		{
			Name: "Set Values.image.cisoperator.debug to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("image.cisoperator.debug", true),
		},
		{
			Name: "Set Values.image.cisoperator.debug to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("image.cisoperator.debug", false),
		},
		{
			Name: "Set Values.securityScanJob.overrideTolerations to 'true' and securityScanJob.tolerations to []",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("securityScanJob", map[string]interface{}{
					"overrideTolerations": true,
					"tolerations":         []corev1.Toleration{},
				}),
		},
		{
			Name: "Set Values.securityScanJob.overrideTolerations to 'true' and securityScanJob.tolerations to testSecScanJobTolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("securityScanJob", map[string]interface{}{
					"overrideTolerations": true,
					"tolerations":         testSecScanJobTolerations,
				}),
		},
		{
			Name: "Set Values.securityScanJob.overrideTolerations to 'false' and securityScanJob.tolerations to testSecScanJobTolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("securityScanJob", map[string]interface{}{
					"overrideTolerations": false,
					"tolerations":         testSecScanJobTolerations,
				}),
		},
		{
			Name: "Set Values.resources",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("resources", testResources),
		},
		{
			Name: "Set Values.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("affinity", testAffinity),
		},
	},

	NamedChecks: []test.NamedCheck{
		{
			Name:   "All Workloads Have Service Account",
			Checks: common.AllWorkloadsHaveServiceAccount,
		},
		{
			Name:   "All Workloads Have Node Selectors And Tolerations For OS",
			Checks: common.AllWorkloadsHaveNodeSelectorsAndTolerationsForOS,
		},
		{
			Name:   "All Workload Container Should Have SystemDefaultRegistryPrefix",
			Checks: common.AllContainerImagesShouldHaveSystemDefaultRegistryPrefix,
			Covers: []string{
				"Values.global.cattle.systemDefaultRegistry",
			},
		},
		{
			Name: "Check All Workloads Have NodeSelector As Per Given Value",
			Covers: []string{
				".Values.nodeSelector",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					nodeSelectorAddedByValues, _ := checker.RenderValue[map[string]string](tc, ".Values.nodeSelector")

					expectedNodeSelector := map[string]string{}

					for k, v := range nodeSelectorAddedByValues {
						expectedNodeSelector[k] = v
					}

					for k, v := range defaultNodeSelector {
						expectedNodeSelector[k] = v
					}

					assert.Equal(tc.T,
						expectedNodeSelector, podTemplateSpec.Spec.NodeSelector,
						"workload %s (type: %T) does not have correct nodeSelectors, expected: %v got: %v",
						obj.GetName(), obj, expectedNodeSelector, podTemplateSpec.Spec.NodeSelector,
					)
				}),
			},
		},
		{
			Name: "Check All Workloads Have Tolerations As Per Given Value",
			Covers: []string{
				".Values.tolerations",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.tolerations")

					expectedTolerations := append(defaultTolerations, tolerationsAddedByValues...)
					if len(expectedTolerations) == 0 {
						expectedTolerations = nil
					}

					assert.Equal(tc.T,
						expectedTolerations, podTemplateSpec.Spec.Tolerations,
						"workload %s (type: %T) does not have correct tolerations, expected: %v got: %v",
						obj.GetName(), obj, expectedTolerations, podTemplateSpec.Spec.Tolerations,
					)
				}),
			},
		},
		{
			Name: "Check that all job containers have global imagePullPolicy",
			Covers: []string{
				".Values.global.imagePullPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					expectedImagePullPolicy, exists := checker.RenderValue[corev1.PullPolicy](tc, ".Values.global.imagePullPolicy")

					if exists {
						for _, container := range job.Spec.Template.Spec.Containers {

							assert.Equal(tc.T,
								expectedImagePullPolicy, container.ImagePullPolicy,
								"container %s of job %s does not have correct image: expected: %v got: %v",
								container.Name, job.Name, expectedImagePullPolicy, container.ImagePullPolicy)
						}
					}
				}),
			},
		},
		{
			Name: "Check kubectl image value",
			Covers: []string{
				".Values.global.kubectl.repository",
				".Values.global.kubectl.tag",
				".Values.global.cattle.systemDefaultRegistry",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "patch-sa" {
						return
					}

					checker.MapSet(tc, PatchSaJobExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers: expected: %d, got: %d",
						job.Name, 1, len(job.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					kubectlRepo, _ := checker.RenderValue[string](tc, ".Values.global.kubectl.repository")
					kubectlTag, _ := checker.RenderValue[string](tc, ".Values.global.kubectl.tag")

					containerImage := kubectlRepo + ":" + kubectlTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of job %s does not have correct image: expected: %v got: %v",
						container.Name, job.Name, expectedContainerImage, container.Image)

				}),

				patchSaJobExistsCheck,
			},
		},
		{

			Name: "Check cisoperator image repository and tag",
			Covers: []string{
				".Values.image.cisoperator.repository",
				".Values.image.cisoperator.tag",
				".Values.global.cattle.systemDefaultRegistry",
			},
			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(podTemplateSpec.Spec.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers))

					if !ok {
						return
					}

					container := podTemplateSpec.Spec.Containers[0]

					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					cisOperatorRepo, _ := checker.RenderValue[string](tc, ".Values.image.cisoperator.repository")
					cisOperatorTag, _ := checker.RenderValue[string](tc, ".Values.image.cisoperator.tag")

					containerImage := cisOperatorRepo + ":" + cisOperatorTag

					expectedContainerImage := systemDefaultRegistry + containerImage

					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of deployment %s does not have correct image: expected: %v got: %v",
						container.Name, obj.GetName(), expectedContainerImage, container.Image)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
		{

			Name: "Check securityScan and sonobuoy images",
			Covers: []string{
				".Values.image.securityScan.repository",
				".Values.image.securityScan.tag",
				".Values.image.sonobuoy.repository",
				".Values.image.sonobuoy.tag",
			},
			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(podTemplateSpec.Spec.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers))

					if !ok {
						return
					}

					container := podTemplateSpec.Spec.Containers[0]

					assertSecurityScanAndSunobuoyImageValues(tc, container.Env)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
		{

			Name: "Check alerts configuration",
			Covers: []string{
				".Values.alerts.severity",
				".Values.alerts.enabled",
				".Values.alerts.metricsPort",
			},
			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(podTemplateSpec.Spec.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers))

					if !ok {
						return
					}

					container := podTemplateSpec.Spec.Containers[0]

					assertAlertsConfigurationValues(tc, container.Env)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
		{

			Name: "Check cisoperator configuration",
			Covers: []string{
				".Values.global.cattle.clusterName",
				".Values.image.cisoperator.debug",
			},
			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(podTemplateSpec.Spec.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers))

					if !ok {
						return
					}

					container := podTemplateSpec.Spec.Containers[0]

					assertCisOperatorConfigurationValues(tc, container.Env)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
		{

			Name: "Check securityScanJob configuration",
			Covers: []string{
				".Values.securityScanJob.overrideTolerations",
				".Values.securityScanJob.tolerations",
			},
			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(podTemplateSpec.Spec.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers))

					if !ok {
						return
					}

					container := podTemplateSpec.Spec.Containers[0]

					assertSecurityScanJobConfigurationValues(tc, container.Env)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
		{

			Name: "Check affinity",
			Covers: []string{
				".Values.affinity",
			},
			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					expectedAffinity, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.affinity")
					if expectedAffinity != nil && (*expectedAffinity) == (corev1.Affinity{}) {
						expectedAffinity = nil
					}

					assert.Equal(tc.T,
						expectedAffinity, podTemplateSpec.Spec.Affinity,
						"deployment %s does not have correct affinity: expected: %v, got: %v",
						obj.GetName(), expectedAffinity, podTemplateSpec.Spec.Affinity)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
		{

			Name: "Check resources",
			Covers: []string{
				".Values.resources",
			},
			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "cis-operator" {
						return
					}

					checker.MapSet(tc, CisOperatorDeployExistsCheck, FoundKey, true)

					ok := assert.Equal(tc.T, 1, len(podTemplateSpec.Spec.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers))

					if !ok {
						return
					}

					container := podTemplateSpec.Spec.Containers[0]

					expectedResourceReq, _ := checker.RenderValue[corev1.ResourceRequirements](tc, ".Values.resources")

					assert.Equal(tc.T,
						expectedResourceReq, container.Resources,
						"container %s of deployment %s does not have correct resources constraint: expected: %v, got: %v",
						container.Name, obj.GetName(), expectedResourceReq, container.Resources)

				}),
				cisOperatorDeployExistsCheck,
			},
		},
	},
}

func assertSecurityScanAndSunobuoyImageValues(tc *checker.TestContext, env []corev1.EnvVar) {

	systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

	for _, envVar := range env {

		expectedValue := ""

		switch envVar.Name {

		case "SECURITY_SCAN_IMAGE":
			value, _ := checker.RenderValue[string](tc, ".Values.image.securityScan.repository")
			expectedValue = systemDefaultRegistry + value

		case "SECURITY_SCAN_IMAGE_TAG":
			expectedValue, _ = checker.RenderValue[string](tc, ".Values.image.securityScan.tag")

		case "SONOBUOY_IMAGE":
			value, _ := checker.RenderValue[string](tc, ".Values.image.sonobuoy.repository")
			expectedValue = systemDefaultRegistry + value

		case "SONOBUOY_IMAGE_TAG":
			expectedValue, _ = checker.RenderValue[string](tc, ".Values.image.sonobuoy.tag")

		default:
			expectedValue = envVar.Value
		}

		assert.Equal(tc.T,
			expectedValue, envVar.Value,
			"container of cis-operator deployment does not have correct env value for envKey:%s, expected: %v, got: %v",
			envVar.Name, expectedValue, envVar.Value)
	}
}

func assertAlertsConfigurationValues(tc *checker.TestContext, env []corev1.EnvVar) {

	for _, envVar := range env {

		expectedValue := ""

		switch envVar.Name {

		case "CIS_ALERTS_METRICS_PORT":
			metricsPortValue, _ := checker.RenderValue[int](tc, ".Values.alerts.metricsPort")
			expectedValue = fmt.Sprintf("%d", metricsPortValue)

		case "CIS_ALERTS_SEVERITY":
			expectedValue, _ = checker.RenderValue[string](tc, ".Values.alerts.severity")

		case "CIS_ALERTS_ENABLED":
			alertsEnabled, _ := checker.RenderValue[bool](tc, ".Values.alerts.enabled")
			expectedValue = fmt.Sprintf("%t", alertsEnabled)

		default:
			expectedValue = envVar.Value
		}

		assert.Equal(tc.T,
			expectedValue, envVar.Value,
			"container of cis-operator deployment does not have correct env value for envKey:%s, expected: %v, got: %v",
			envVar.Name, expectedValue, envVar.Value)
	}
}

func assertCisOperatorConfigurationValues(tc *checker.TestContext, env []corev1.EnvVar) {

	for _, envVar := range env {

		expectedValue := ""

		switch envVar.Name {

		case "CLUSTER_NAME":
			expectedValue, _ = checker.RenderValue[string](tc, ".Values.global.cattle.clusterName")

		case "CIS_OPERATOR_DEBUG":
			debug, exists := checker.RenderValue[bool](tc, ".Values.image.cisoperator.debug")
			if !exists {
				tc.T.Logf("warn: .Values.image.cisoperator.debug not set")
				continue
			}
			expectedValue = fmt.Sprintf("%t", debug)

		default:
			expectedValue = envVar.Value
		}

		assert.Equal(tc.T,
			expectedValue, envVar.Value,
			"container of cis-operator deployment does not have correct env value for envKey:%s, expected: %v, got: %v",
			envVar.Name, expectedValue, envVar.Value)
	}
}

func assertSecurityScanJobConfigurationValues(tc *checker.TestContext, env []corev1.EnvVar) {

	for _, envVar := range env {

		expectedValue := ""

		switch envVar.Name {

		case "SECURITY_SCAN_JOB_TOLERATIONS":

			overrideScanJobToleration, _ := checker.RenderValue[bool](tc, ".Values.securityScanJob.overrideTolerations")
			if overrideScanJobToleration {
				tolerations, _ := checker.RenderValue[[]map[string]interface{}](tc, ".Values.securityScanJob.tolerations")
				bytes, _ := json.Marshal(tolerations)
				expectedValue = string(bytes)
			}

		default:
			expectedValue = envVar.Value
		}

		assert.Equal(tc.T,
			expectedValue, envVar.Value,
			"container of cis-operator deployment does not have correct env value for envKey:%s, expected: %v, got: %v",
			envVar.Name, expectedValue, envVar.Value)
	}
}

var cisOperatorDeployExistsCheck = checker.Once(func(tc *checker.TestContext) {

	foundCisOperatorDeploy, _ := checker.MapGet[string, string, bool](tc, CisOperatorDeployExistsCheck, FoundKey)
	if !foundCisOperatorDeploy {
		tc.T.Error("err: cis-operator depoloyment not found")
	}
})

var patchSaJobExistsCheck = checker.Once(func(tc *checker.TestContext) {

	foundPatchSaJob, _ := checker.MapGet[string, string, bool](tc, PatchSaJobExistsCheck, FoundKey)
	if !foundPatchSaJob {
		tc.T.Error("err: patch-sa job not found")
	}
})
