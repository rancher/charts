package rancher_istio

import (
	"github.com/rancher/charts/tests/common"
	"github.com/rancher/hull/pkg/chart"
	"github.com/rancher/hull/pkg/checker"
	"github.com/rancher/hull/pkg/test"
	"github.com/rancher/hull/pkg/utils"
	"github.com/stretchr/testify/assert"
	autoscalingv2 "k8s.io/api/autoscaling/v2"
	corev1 "k8s.io/api/core/v1"
	policyv1beta1 "k8s.io/api/policy/v1beta1"
	rbacv1 "k8s.io/api/rbac/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var ChartPath = utils.MustGetPathFromModuleRoot("../charts/rancher-istio/102.0.0+up1.15.3")

const (
	DefaultReleaseName = "rancher-istio"
	DefaultNamespace   = "istio-system"
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
			Name: "Set .Values.global.proxy",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("global.proxy", map[string]string{
					"repository": "testRepo/mirrored-istio-proxyv2",
					"tag":        "1.7.3",
				}),
		},

		{
			Name: "Set .Values.global.proxy_init",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("global.proxy_init", map[string]string{
					"repository": "testRepo/mirrored-istio-proxyv2",
					"tag":        "1.7.3",
				}),
		},

		{
			Name: "Set .Values.global.defaultPodDisruptionBudget.enabled to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"global.defaultPodDisruptionBudget.enabled", "true",
				),
		},

		{
			Name: "Set .Values.overlayFile",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"overlayFile", testIstioOverlay,
				),
		},

		{
			Name: "Set .Values.tag",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"tag", "1.7.3",
				),
		},

		{
			Name: "Set .Values.forceInstall to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"forceInstall", true,
				),
		},

		{
			Name: "Set .Values.forceInstall to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"forceInstall", false,
				),
		},

		{
			Name: "Set .Values.kiali to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"kiali.enabled", false,
				),
		},

		{
			Name: "Set .Values.dns to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"dns.enabled", true,
				),
		},

		{
			Name: "Set .Values.dns to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"dns.enabled", false,
				),
		},

		{
			Name: "Set .Values.base to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"base.enabled", true,
				),
		},

		{
			Name: "Set .Values.base to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"base.enabled", false,
				),
		},

		{
			Name: "Set .Values.istiodRemote to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"istiodRemote.enabled", true,
				),
		},

		{
			Name: "Set .Values.istiodRemote to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"istiodRemote.enabled", false,
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
			Name: "Set .Values.tolerations",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"tolerations", testTolerations,
				),
		},

		{
			Name: "Set .Values.installer repository and tag",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("installer", map[string]string{
					"repository":            "testRepo/mirrored-istio-installer",
					"tag":                   "1.7.3",
					"releaseMirror.enabled": "false",
					"debug.secondsSleep":    "0",
				}),
		},

		{
			Name: "Set CNI to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"cni.enabled", "false",
				),
		},

		{
			Name: "Set CNI to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("cni", map[string]interface{}{
					"enabled":    true,
					"repository": "testRepo/mirrored-istio-install-cni",
					"tag":        "1.7.3",
					"logLevel":   "debug",
					"excludeNamespaces": []string{
						"kube-system",
						"istio-system",
					},
				}),
		},

		{
			Name: "Set .Values.pilot.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"pilot.enabled", false,
				),
		},

		{
			Name: "Set .Values.pilot.enabled to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("pilot", map[string]interface{}{
					"enabled":             true,
					"repository":          "testRepo/mirrored-istio-pilot",
					"tag":                 "1.7.3",
					"hpaSpec":             testHPASpec,
					"podDisruptionBudget": testPodDisruptionBudget,
				}),
		},

		{
			Name: "Set .Values.egressGateways.enabled to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("egressGateways", map[string]interface{}{
					"enabled":             true,
					"type":                "NodePort",
					"hpaSpec":             testHPASpec,
					"podDisruptionBudget": testPodDisruptionBudget,
				}),
		},

		{
			Name: "Set .Values.egressGateways.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("egressGateways", map[string]interface{}{
					"enabled":             false,
					"type":                "NodePort",
					"hpaSpec":             testHPASpec,
					"podDisruptionBudget": testPodDisruptionBudget,
				}),
		},

		{
			Name: "Set .Values.ingressGateway.enabled to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("ingressGateways", map[string]interface{}{
					"enabled":             true,
					"type":                "NodePort",
					"hpaSpec":             testHPASpec,
					"podDisruptionBudget": testPodDisruptionBudget,
				}),
		},

		{
			Name: "Set .Values.ingressGateways.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("ingressGateways", map[string]interface{}{
					"enabled":             false,
					"type":                "NodePort",
					"hpaSpec":             testHPASpec,
					"podDisruptionBudget": testPodDisruptionBudget,
				}),
		},
	},

	NamedChecks: []test.NamedCheck{
		{
			Name:   "All Deployments Have ServiceAccount",
			Checks: common.AllWorkloadsHaveServiceAccount,
		},

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

		{ // Setting forceInstall: true will remove the check for istio version < 1.6.x and will not analyze your install cluster prior to install
			Name: "forceinstall",
			Covers: []string{
				".Values.forceInstall",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, cr *rbacv1.ClusterRole) {
					forceInstall, _ := checker.RenderValue[bool](tc, ".Values.forceInstall")
					if forceInstall == true {
						return
					}
				}),
			},
		},

		{
			Name: "Check installer",
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
				".Values.installer.repository",
				".Values.installer.tag",
				".Values.installer.releaseMirror.enabled",
				".Values.installer.debug.secondsSleep",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "istioctl-installer" {
						return
					}

					systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
					installerRepository, _ := checker.RenderValue[string](tc, ".Values.installer.repository")
					installerTag, _ := checker.RenderValue[string](tc, ".Values.installer.tag")
					expectedInstallerImage := installerRepository + ":" + installerTag

					if systemDefaultRegistry != "" {
						expectedInstallerImage = systemDefaultRegistry + "/" + expectedInstallerImage
					}

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, expectedInstallerImage, container.Image,
							"workload %s (type: %T) in Deployment %s/%s does not have correct image",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
					}

					if obj.GetName() != "installer-job" {
						return
					}
					releaseMirrorEnabled, _ := checker.RenderValue[bool](tc, ".Values.installer.releaseMirror.enabled")

					if !releaseMirrorEnabled {
						return
					}

					releaseMirrorDebugSecondsSleep, _ := checker.RenderValue[int](tc, ".Values.installer.debug.secondsSleep")
					if releaseMirrorEnabled {
						assert.Equal(tc.T, 60, releaseMirrorDebugSecondsSleep,
							"workload %s (type: %T) in Deployment %s/%s does not have correct debug.secondsSleep",
							obj.GetName(), obj, obj.GetNamespace(), obj.GetName(),
						)
					} else {
						assert.Equal(tc.T, 0, releaseMirrorDebugSecondsSleep,
							"workload %s (type: %T) in Deployment %s/%s does not have correct debug.secondsSleep",
							obj.GetName(), obj, obj.GetNamespace(), obj.GetName(),
						)
					}
				}),
			},
		},

		{
			Name: "Check proxy repository and tag",
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
				".Values.global.proxy.repository",
				".Values.global.proxy.tag",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "istio-proxy" {
						return
					}

					systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
					proxyRepository, _ := checker.RenderValue[string](tc, ".Values.global.proxy.repository")
					proxyTag, _ := checker.RenderValue[string](tc, ".Values.global.proxy.tag")
					expectedProxyImage := proxyRepository + ":" + proxyTag

					if systemDefaultRegistry != "" {
						expectedProxyImage = systemDefaultRegistry + "/" + expectedProxyImage
					}

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, expectedProxyImage, container.Image,
							"workload %s (type: %T) in Deployment %s/%s does not have correct image",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
					}
				}),
			},
		},

		{
			Name: "Check proxy_init repository and tag",
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
				".Values.global.proxy_init.repository",
				".Values.global.proxy_init.tag",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "istio-init" {
						return
					}

					systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
					proxyInitRepository, _ := checker.RenderValue[string](tc, ".Values.global.proxy_init.repository")
					proxyInitTag, _ := checker.RenderValue[string](tc, ".Values.global.proxy_init.tag")
					expectedProxyInitImage := proxyInitRepository + ":" + proxyInitTag

					if systemDefaultRegistry != "" {
						expectedProxyInitImage = systemDefaultRegistry + "/" + expectedProxyInitImage
					}

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, expectedProxyInitImage, container.Image,
							"workload %s (type: %T) in Deployment %s/%s does not have correct image",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
					}
				}),
			},
		},

		{
			Name: "Check istio-cni repository and tag",
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
				".Values.cni.enabled",
				".Values.cni.repository",
				".Values.cni.tag",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					cniEnabled := checker.MustRenderValue[bool](tc, ".Values.cni.enabled")

					if obj.GetName() != "istio-cni-node" {
						return
					}

					if !cniEnabled {
						return
					}

					systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
					istioCniRepository, _ := checker.RenderValue[string](tc, ".Values.cni.repository")
					istioCniTag, _ := checker.RenderValue[string](tc, ".Values.cni.tag")
					expectedIstioCniImage := istioCniRepository + ":" + istioCniTag

					if systemDefaultRegistry != "" {
						expectedIstioCniImage = systemDefaultRegistry + "/" + expectedIstioCniImage
					}

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, expectedIstioCniImage, container.Image,
							"workload %s (type: %T) in Deployment %s/%s does not have correct image",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
					}
				}),
			},
		},

		{
			Name: "Check istio-cni logLevel and excludeNamespaces",
			Covers: []string{
				".Values.cni.enabled",
				".Values.cni.logLevel",
				".Values.cni.excludeNamespaces",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					cniEnabled := checker.MustRenderValue[bool](tc, ".Values.cni.enabled")

					if obj.GetName() != "istio-cni-node" {
						return
					}

					if !cniEnabled {
						return
					}

					logLevel, _ := checker.RenderValue[string](tc, ".Values.cni.logLevel")
					excludeNamespaces, _ := checker.RenderValue[string](tc, ".Values.cni.excludeNamespaces")

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, logLevel, container.Args[1],
							"workload %s (type: %T) in Deployment %s/%s does not have correct logLevel",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
						assert.Equal(tc.T, excludeNamespaces, container.Args[3],
							"workload %s (type: %T) in Deployment %s/%s does not have correct excludeNamespaces",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
					}
				}),
			},
		},

		{
			Name: "Check overlayFile",
			Covers: []string{
				".Values.overlayFile",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					overlayFile, _ := checker.RenderValue[string](tc, ".Values.overlayFile")

					if overlayFile == "" {
						return
					} else {
						for _, container := range podTemplateSpec.Spec.Containers {
							assert.Contains(tc.T, container.Args, "--overlay="+overlayFile,
								"workload %s (type: %T) in Deployment %s/%s does not have correct overlayFile",
								container.Name, obj, obj.GetNamespace(), obj.GetName(),
							)
						}
					}
				}),
			},
		},

		{
			Name: "Check .Values.pilot.repository and .Values.pilot.tag",
			Covers: []string{
				".Values.global.cattle.systemDefaultRegistry",
				".Values.pilot.enabled",
				".Values.pilot.repository",
				".Values.pilot.tag",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					pilotEnabled := checker.MustRenderValue[bool](tc, ".Values.pilot.enabled")

					if obj.GetName() != "istiod" {
						return
					}

					if !pilotEnabled {
						return
					}

					systemDefaultRegistry, _ := checker.RenderValue[string](tc, ".Values.global.cattle.systemDefaultRegistry")
					pilotRepository, _ := checker.RenderValue[string](tc, ".Values.pilot.repository")
					pilotTag, _ := checker.RenderValue[string](tc, ".Values.pilot.tag")
					expectedPilotImage := pilotRepository + ":" + pilotTag

					if systemDefaultRegistry != "" {
						expectedPilotImage = systemDefaultRegistry + "/" + expectedPilotImage
					}

					for _, container := range podTemplateSpec.Spec.Containers {
						assert.Equal(tc.T, expectedPilotImage, container.Image,
							"workload %s (type: %T) in Deployment %s/%s does not have correct image",
							container.Name, obj, obj.GetNamespace(), obj.GetName(),
						)
					}
				}),
			},
		},

		{
			Name: "Check .Values.pilot.hpaSpec",
			Covers: []string{
				".Values.pilot.enabled",
				".Values.pilot.hpaSpec",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, hpa *autoscalingv2.HorizontalPodAutoscaler) {
					pilotEnabled := checker.MustRenderValue[bool](tc, ".Values.pilot.enabled")

					if hpa.Name != "pilot" {
						return
					}

					if !pilotEnabled {
						return
					}

					hpaSpec, _ := checker.RenderValue[string](tc, ".Values.pilot.hpaSpec")
					assert.Equal(tc.T, hpaSpec, hpa.Spec)
				}),
			},
		},

		{
			Name: "Check .Values.pilot.podDisruptionBudget",
			Covers: []string{
				".Values.pilot.podDisruptionBudget",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, pdb *policyv1beta1.PodDisruptionBudget) {
					pilotEnabled := checker.MustRenderValue[bool](tc, ".Values.pilot.enabled")

					if pdb.Name != "pilot" {
						return
					}

					if !pilotEnabled {
						return
					}

					pilotPodDisruptionBudget, _ := checker.RenderValue[string](tc, ".Values.pilot.podDisruptionBudget")
					assert.Equal(tc.T, pilotPodDisruptionBudget, pdb.Spec)
				}),
			},
		},

		{
			Name: "Check .Values.egressGateways.type",
			Covers: []string{
				".Values.egressGateways.enabled",
				".Values.egressGateways.type",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					egressGatewaysEnabled := checker.MustRenderValue[bool](tc, ".Values.egressGateways.enabled")

					if !egressGatewaysEnabled {
						return
					}

					egressGatewaysType, _ := checker.RenderValue[string](tc, ".Values.egressGateways.type")

					assert.Equal(tc.T, egressGatewaysType, "NodePort")
				}),
			},
		},

		{
			Name: "Check .Values.egressGateways.hpaSpec",
			Covers: []string{
				".Values.egressGateways.enabled",
				".Values.egressGateways.hpaSpec",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, hpa *autoscalingv2.HorizontalPodAutoscaler) {
					egressGatewaysEnabled := checker.MustRenderValue[bool](tc, ".Values.egressGateways.enabled")

					if !egressGatewaysEnabled {
						return
					}

					egressGatewaysHpaSpec, _ := checker.RenderValue[string](tc, ".Values.egressGateways.hpaSpec")
					assert.Equal(tc.T, egressGatewaysHpaSpec, hpa.Spec)
				}),
			},
		},

		{
			Name: "Check .Values.egressGateways.podDisruptionBudget",
			Covers: []string{
				".Values.egressGateways.enabled",
				".Values.egressGateways.podDisruptionBudget",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, pdb *policyv1beta1.PodDisruptionBudget) {
					egressGatewaysEnabled := checker.MustRenderValue[bool](tc, ".Values.egressGateways.enabled")

					if !egressGatewaysEnabled {
						return
					}

					egressGatewaysPodDisruptionBudget, _ := checker.RenderValue[string](tc, ".Values.egressGateways.podDisruptionBudget")
					assert.Equal(tc.T, egressGatewaysPodDisruptionBudget, pdb.Spec)
				}),
			},
		},

		{
			Name: "Check .Values.ingressGateways.type",
			Covers: []string{
				".Values.ingressGateways.enabled",
				".Values.ingressGateways.type",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					ingressGatewaysEnabled := checker.MustRenderValue[bool](tc, ".Values.ingressGateways.enabled")

					if !ingressGatewaysEnabled {
						return
					}

					ingressGatewaysType, _ := checker.RenderValue[string](tc, ".Values.ingressGateways.type")

					assert.Equal(tc.T, ingressGatewaysType, "NodePort")
				}),
			},
		},

		{
			Name: "Check .Values.ingressGateways.hpaSpec",
			Covers: []string{
				".Values.ingressGateways.enabled",
				".Values.ingressGateways.hpaSpec",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, hpa *autoscalingv2.HorizontalPodAutoscaler) {
					ingressGatewaysEnabled := checker.MustRenderValue[bool](tc, ".Values.ingressGateways.enabled")

					if !ingressGatewaysEnabled {
						return
					}

					ingressGatewaysHpaSpec, _ := checker.RenderValue[string](tc, ".Values.ingressGateways.hpaSpec")
					assert.Equal(tc.T, ingressGatewaysHpaSpec, hpa.Spec)
				}),
			},
		},

		{
			Name: "Check .Values.ingressGateways.podDisruptionBudget",
			Covers: []string{
				".Values.ingressGateways.enabled",
				".Values.ingressGateways.podDisruptionBudget",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, pdb *policyv1beta1.PodDisruptionBudget) {
					ingressGatewaysEnabled := checker.MustRenderValue[bool](tc, ".Values.ingressGateways.enabled")

					if !ingressGatewaysEnabled {
						return
					}

					ingressGatewaysPodDisruptionBudget, _ := checker.RenderValue[string](tc, ".Values.ingressGateways.podDisruptionBudget")
					assert.Equal(tc.T, ingressGatewaysPodDisruptionBudget, pdb.Spec)
				}),
			},
		},

		{
			Name: "Check .Values.kiali.enabled",
			Covers: []string{
				".Values.kiali.enabled",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
					kialiEnabled := checker.MustRenderValue[bool](tc, ".Values.kiali.enabled")

					if !kialiEnabled {
						return
					}
				}),
			},
		},
	},
}
