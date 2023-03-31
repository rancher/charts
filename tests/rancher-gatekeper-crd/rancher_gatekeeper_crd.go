package rancher_gatekeeper_crd

import (
	"github.com/rancher/charts/tests/common"
	"github.com/rancher/hull/pkg/chart"
	"github.com/rancher/hull/pkg/checker"
	"github.com/rancher/hull/pkg/test"
	"github.com/rancher/hull/pkg/utils"
	"github.com/stretchr/testify/assert"
	corev1 "k8s.io/api/core/v1"
	policyv1beta1 "k8s.io/api/policy/v1beta1"
	rbacv1 "k8s.io/api/rbac/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var ChartPath = utils.MustGetPathFromModuleRoot("../charts/rancher-gatekeeper-crd/102.0.0+up3.10.0")

const (
	DefaultReleaseName = "rancher-gatekeeper-crd"
	DefaultNamespace   = "cattle-gatekeeper-system"
)

var suite = test.Suite{
	ChartPath: ChartPath,

	Cases: []test.Case{
		{
			Name:            "Using Defaults",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace),
		},

		{
			Name: "Set .Values.global.cattle.systemDefaultRegistry",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"global.cattle.systemDefaultRegistry", "testRegistry",
				),
		},

		{
			Name: "Set .Values.tolerations",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"tolerations", testTolerations,
				),
		},

		{
			Name: "Set .Values.nodeSelector",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"nodeSelector", defaultNodeSelector,
				),
		},

		{
			Name: "Set .Values.global.cattle.psp.enabled to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("global.cattle.psp.enabled", true),
		},

		{
			Name: "Set .Values.global.cattle.psp.enabled to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("global.cattle.psp.enabled", false),
		},

		{
			Name: "Set .Values.image",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("image", map[string]string{
					"repository": "rancher/kubectl-test",
					"tag":        "v1.24.6",
				}),
		},

		{
			Name: "Set .Values.enableRuntimeDefaultSeccompProfile",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("enableRuntimeDefaultSeccompProfile", true),
		},

		{
			Name: "Set .Values.enableRuntimeDefaultSeccompProfile to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("enableRuntimeDefaultSeccompProfile", false),
		},

		{
			Name: "Set .Values.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("securityContext", testSecurityContext),
		},
	},

	NamedChecks: []test.NamedCheck{
		{
			Name:   "All Workloads Have Node Selectors and Tolerations",
			Checks: common.AllWorkloadsHaveNodeSelectorsAndTolerationsForOS,
		},

		{
			Name:   "All Workload Container Should Have SystemDefaultRegistry",
			Checks: common.AllContainerImagesShouldHaveSystemDefaultRegistryPrefix,
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
			},
		},

		{
			Name: "Check All Workload Have NodeSelector As Per Given Values",
			Covers: []string{
				".Values.nodeSelector",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					nodeselectorAddedByValues, _ := checker.RenderValue[map[string]string](tc, ".Values.nodeSelector")
					expectedNodeSelector := map[string]string{}

					for k, v := range nodeselectorAddedByValues {
						expectedNodeSelector[k] = v
					}

					for k, v := range defaultNodeSelector {
						expectedNodeSelector[k] = v
					}

					assert.Equal(tc.T, expectedNodeSelector, podTemplateSpec.Spec.NodeSelector,
						"workload %s (type: %T) does not have correct nodeSelectors, expected: %v got: %v",
						obj.GetName(), obj, expectedNodeSelector, podTemplateSpec.Spec.NodeSelector,
					)
				}),
			},
		},

		{
			Name: "Check All Workload Have Tolerations As Per Given Values",
			Covers: []string{
				".Values.tolerations",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					if obj.GetName() == "kiali" {
						return
					}

					if obj.GetName() == "rancher-istio-tracing" {
						return
					}

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.tolerations")

					expectedTolerations := append(defaultTolerations, tolerationsAddedByValues...)
					if len(expectedTolerations) == 0 {
						expectedTolerations = nil
					}

					assert.Equal(tc.T, expectedTolerations, podTemplateSpec.Spec.Tolerations,
						"workload %s (type: %T) does not have correct tolerations, expected: %v got: %v",
						obj.GetName(), obj, expectedTolerations, podTemplateSpec.Spec.Tolerations,
					)
				}),
			},
		},

		{ //Set PSPs
			Name: "Set PSPs",

			Covers: []string{
				".Values.global.cattle.psp.enabled",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, cr *rbacv1.ClusterRole) {
					pspsEnabled, _ := checker.RenderValue[bool](tc, ".Values.global.cattle.psp.enabled")
					pspsFound := false
					for _, rule := range cr.Rules {
						for _, resource := range rule.Resources {
							if resource == "podsecuritypolicies" {
								pspsFound = true
							}
						}
					}
					if !pspsEnabled {
						assert.False(tc.T, pspsFound, "ClusterRole %s has incorrect PSP configuration", cr.Name)
					}
				}),
				checker.OnResources(func(tc *checker.TestContext, psps []*policyv1beta1.PodSecurityPolicy) {
					pspsEnabled, _ := checker.RenderValue[bool](tc, ".Values.global.cattle.psp.enabled")
					if pspsEnabled {
						assert.Equal(tc.T, 1, len(psps), "Missing PSPs")
					} else {
						assert.Equal(tc.T, 0, len(psps), "Missing PSPs")
					}
				}),
			},
		},

		{
			Name: "Check securityContext",
			Covers: []string{
				".Values.securityContext",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "rancher-gatekeeper-crd" {
						return
					}

					securityContext, _ := checker.RenderValue[*corev1.SecurityContext](tc, ".Values.securityContext")

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, securityContext, container.SecurityContext,
							"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
							obj.GetName(), obj, securityContext, container.SecurityContext,
						)
					}
				}),
			},
		},

		{
			Name: "Check enableRuntimeDefaultSeccompProfile",
			Covers: []string{
				".Values.enableRuntimeDefaultSeccompProfile",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "rancher-gatekeeper-crd" {
						return
					}

					enableRuntimeDefaultSeccompProfile, _ := checker.RenderValue[bool](tc, ".Values.enableRuntimeDefaultSeccompProfile")

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, enableRuntimeDefaultSeccompProfile, *container.SecurityContext.SeccompProfile,
							"workload %s (type: %T) does not have correct enableRuntimeDefaultSeccompProfile, expected: %v got: %v",
							obj.GetName(), obj, enableRuntimeDefaultSeccompProfile, *container.SecurityContext.SeccompProfile,
						)
					}

					if !enableRuntimeDefaultSeccompProfile {
						for _, container := range podTemplateSpec.Spec.InitContainers {
							assert.Equal(tc.T, enableRuntimeDefaultSeccompProfile, *container.SecurityContext.SeccompProfile,
								"workload %s (type: %T) does not have correct enableRuntimeDefaultSeccompProfile, expected: %v got: %v",
								obj.GetName(), obj, enableRuntimeDefaultSeccompProfile, *container.SecurityContext.SeccompProfile,
							)
						}
					}
				}),
			},
		},

		{
			Name: "Check image and tag",
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
				".Values.image.repository",
				".Values.image.tag",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "rancher-gatekeeper-crd" {
						return
					}

					systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
					image, _ := checker.RenderValue[string](tc, ".Values.image.repository")
					tag, _ := checker.RenderValue[string](tc, ".Values.image.tag")
					expectedImage := image + ":" + tag

					if systemDefaultRegistry != "" {
						expectedImage = systemDefaultRegistry + "/" + expectedImage
					}

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, expectedImage, container.Image,
							"workload %s (type: %T) does not have correct image, expected: %v got: %v",
							obj.GetName(), obj, expectedImage, container.Image,
						)
					}
				}),
			},
		},
	},
}
