package rancher_gatekeeper

import (
	"fmt"
	"reflect"
	"strconv"

	"github.com/rancher/charts/tests/common"
	"github.com/rancher/hull/pkg/chart"
	"github.com/rancher/hull/pkg/checker"
	"github.com/rancher/hull/pkg/test"
	"github.com/rancher/hull/pkg/utils"
	"github.com/stretchr/testify/assert"
	adminReg "k8s.io/api/admissionregistration/v1"
	appsv1 "k8s.io/api/apps/v1"
	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
	networkingv1 "k8s.io/api/networking/v1"
	policyv1 "k8s.io/api/policy/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/kubernetes/pkg/apis/admissionregistration"
	"k8s.io/kubernetes/pkg/apis/rbac"
	rbacv1 "k8s.io/kubernetes/pkg/apis/rbac"
)

var ChartPath = utils.MustGetLatestChartVersionPathFromIndex("../index.yaml", "rancher-gatekeeper", true)

var (
	DefaultNamespace   = "cattle-gatekeeper-system"
	DefaultReleaseName = "rancher-gatekeeper"
)

var suite = test.Suite{
	ChartPath: ChartPath,

	Cases: []test.Case{
		{
			Name: "Using Defaults",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace),
		},
		{
			Name: "Set .Values.replicas",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"replicas", 3,
				),
		},
		{
			Name: "Set .Values.auditInterval",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"auditInterval", 150,
				),
		},
		{
			Name: "Set .Values.metricsBackends",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"metricsBackends", testMetricsBackend,
				),
		},
		{
			Name: "Set .Values.constraintViolationsLimit",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"constraintViolationsLimit", 30,
				),
		},
		{
			Name: "Set .Values.auditMatchKindOnly to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditMatchKindOnly", "false",
				),
		}, {
			Name: "Set .Values.auditMatchKindOnly to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditMatchKindOnly", "true",
				),
		},
		{
			Name: "Set .Values.auditFromCache to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditFromCache", "false",
				),
		},
		{
			Name: "Set .Values.auditFromCache to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditFromCache", "true",
				),
		},
		{
			Name: "Set .Values.validatingWebhookName",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookName", "example-name",
				),
		},
		{
			Name: "Set .Values.disableMutation to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"disableMutation", false,
				),
		},
		{
			Name: "Set .Values.disableMutation to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"disableMutation", true,
				),
		},
		{
			Name: "Set .Values.enableExternalData to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableExternalData", "false",
				),
		},
		{
			Name: "Set .Values.enableExternalData to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableExternalData", "true",
				),
		},
		{
			Name: "Set .Values.disableValidatingWebhook to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"disableValidatingWebhook", "false",
				),
		},
		{
			Name: "Set .Values.disableValidatingWebhook to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"disableValidatingWebhook", "true",
				),
		},
		{
			Name: "Set .Values.validatingWebhookTimeoutSeconds to 4",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"validatingWebhookTimeoutSeconds", 4,
				),
		},
		{
			Name: "Set .Values.validatingWebhookFailurePolicy to Ignore",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookFailurePolicy", "Ignore",
				),
		},
		{
			Name: "Set .Values.validatingWebhookFailurePolicy to Fail",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookFailurePolicy", "Fail",
				),
		},
		{
			Name: "Set .Values.validatingWebhookObjectSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"validatingWebhookObjectSelector", testValidatingWebhookObjectSelector,
				),
		},
		{
			Name: "Set .Values.validatingWebhookAnnotations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"validatingWebhookAnnotations", testWebhookAnnotations,
				),
		},
		{
			Name: "Set .Values.validatingWebhookCheckIgnoreFailurePolicy to Fail",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookCheckIgnoreFailurePolicy", "Fail",
				),
		},
		{
			Name: "Set .Values.validatingWebhookCheckIgnoreFailurePolicy to Ignore",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookCheckIgnoreFailurePolicy", "Ignore",
				),
		},
		{
			Name: "Set .Values.enableDeleteOperations to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableDeleteOperations", "false",
				),
		},
		{
			Name: "Set .Values.enableDeleteOperations to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableDeleteOperations", "true",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookName",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookName", "example-name",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookFailurePolicy to Fail",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookFailurePolicy", "Fail",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookFailurePolicy to Ignore",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookFailurePolicy", "Ignore",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookReinvocationPolicy to IfNeeded",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookReinvocationPolicy", "IfNeeded",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookReinvocationPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookReinvocationPolicy", "Never",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookAnnotations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"mutatingWebhookAnnotations", testWebhookAnnotations,
				),
		},
		{
			Name: "Set .Values.mutatingWebhookTimeoutSeconds to 2",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"mutatingWebhookTimeoutSeconds", 2,
				),
		},
		{
			Name: "Set .Values.mutationAnnotations to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutationAnnotations", "false",
				),
		},
		{
			Name: "Set .Values.mutationAnnotations to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutationAnnotations", "true",
				),
		},
		{
			Name: "Set .Values.enableGeneratorResourceExpansion to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableGeneratorResourceExpansion", "false",
				),
		},
		{
			Name: "Set .Values.enableGeneratorResourceExpansion to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableGeneratorResourceExpansion", "true",
				),
		},
		{
			Name: "Set .Values.enableTLSHealthcheck to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableTLSHealthcheck", "false",
				),
		},
		{
			Name: "Set .Values.enableTLSHealthcheck to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableTLSHealthcheck", "true",
				),
		},
		{
			Name: "Set .Values.maxServingThreads to 1",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"maxServingThreads", 1,
				),
		},
		{
			Name: "Set .Values.auditChunkSize to 600",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"auditChunkSize", 600,
				),
		},
		{
			Name: "Set .Values.logLevel to Debug",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logLevel", "DEBUG",
				),
		},
		{
			Name: "Set .Values.logLevel to INFO",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logLevel", "INFO",
				),
		},
		{
			Name: "Set .Values.logLevel to WARNING",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logLevel", "WARNING",
				),
		},
		{
			Name: "Set .Values.logLevel to ERROR",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logLevel", "ERROR",
				),
		},
		{
			Name: "Set .Values.logDenies to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logDenies", "false",
				),
		},
		{
			Name: "Set .Values.logDenies to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logDenies", "true",
				),
		},
		{
			Name: "Set .Values.logMutations to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logMutations", "false",
				),
		},
		{
			Name: "Set .Values.logMutations to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logMutations", "true",
				),
		},
		{
			Name: "Set .Values.emitAdmissionEvents to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"emitAdmissionEvents", "false",
				),
		},
		{
			Name: "Set .Values.emitAdmissionEvents to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"emitAdmissionEvents", "true",
				),
		},
		{
			Name: "Set .Values.emitAuditEvents to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"emitAuditEvents", "false",
				),
		},
		{
			Name: "Set .Values.emitAuditEvents to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"emitAuditEvents", "true",
				),
		},
		{
			Name: "Set .Values.admissionEventsInvolvedNamespace to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"admissionEventsInvolvedNamespace", false,
				),
		},
		{
			Name: "Set .Values.admissionEventsInvolvedNamespace to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"admissionEventsInvolvedNamespace", true,
				),
		},
		{
			Name: "Set .Values.auditEventsInvolvedNamespace to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"auditEventsInvolvedNamespace", false,
				),
		},
		{
			Name: "Set .Values.auditEventsInvolvedNamespace to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"auditEventsInvolvedNamespace", true,
				),
		},

		//		For .Values.postUpgrade

		{
			Name: "Set Values for postUpgrade",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.labelNamespace.enabled", true,
				),
		},

		{
			Name: "Set Values for postUpgrade.labelNamespace.enabled",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.enabled", "true",
				),
		},
		{
			Name: "Set Values for postUpgrade.labelNamespace.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.enabled", "false",
				),
		},
		{
			Name: "Set .postUpgrade.labelNamespace.image.repository and .postUpgrade.labelNamespace.image.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.image.repository", "test-kubectl-repo",
				).
				SetValue(
					"postUpgrade.labelNamespace.image.tag", "v1.20.11",
				),
		},
		{
			Name: "Set postUpgrade.labelNamespace.image.pullPolicy to IfNotPresent",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.image.pullPolicy", "IfNotPresent",
				),
		},
		{
			Name: "Set postUpgrade.labelNamespace.image.pullPolicy to Always",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.image.pullPolicy", "Always",
				),
		},
		{
			Name: "Set postUpgrade.labelNamespace.image.pullPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.image.pullPolicy", "Never",
				),
		},
		// {
		// 	Name: "Set postUpgrade.labelNamespace.image.pullSecrets with labelNamespace set to true",

		// 	TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
		// 		Set(
		// 			"postUpgrade.labelNamespace.image.pullSecrets", testPullSecrets,
		// 		).
		// 		Set(
		// 			"postUpgrade.labelNamespace.enabled", true,
		// 		),
		// },
		// {
		// 	Name: "Set postUpgrade.labelNamespace.image.pullSecrets with labelNamespace set to false",

		// 	TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
		// 		Set(
		// 			"postUpgrade.labelNamespace.image.pullSecrets", testPullSecrets,
		// 		).
		// 		Set(
		// 			"postUpgrade.labelNamespace.enabled", false,
		// 		),
		// },
		{
			Name: "Set postUpgrade.labelNamespace.image.pullSecrets",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.labelNamespace.image.pullSecrets", testPullSecrets,
				),
		},
		// {
		// 	Name: "Set postUpgrade.labelNamespace.extraNamespaces",

		// 	TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
		// 		Set(
		// 			"postUpgrade.labelNamespace.extraNamespaces", testExtraNamespaces,
		// 		).
		// 		Set(
		// 			"postUpgrade.labelNamespace.enabled", true,
		// 		),
		// },
		{
			Name: "Set postUpgrade.labelNamespace.podSecurity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.labelNamespace.podSecurity", testPodSecurityLabels,
				),
		},
		{
			Name: "Set postUpgrade.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.affinity", testAffinity,
				),
		},
		{
			Name: "Set postUpgrade.resources",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.resources", testResources,
				),
		},
		{
			Name: "Set postUpgrade.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.securityContext", testSecurityContext,
				),
		},
		{
			Name: "Set postUpgrade.labelNamespace.extraAnnotations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.labelNamespace.extraAnnotations", testPodAnnotation,
				),
		},

		//		For .Values.postInstall
		{
			Name: "Set Values for postInstall.labelNamespace.enabled",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.enabled", "true",
				),
		},
		{
			Name: "Set Values for postInstall.labelNamespace.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.enabled", "false",
				),
		},
		{
			Name: "Set .postInstall.labelNamespace.image.repository and .postInstall.labelNamespace.image.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.image.repository", "test-gatekeeper-crd-repo",
				).
				SetValue(
					"postInstall.labelNamespace.image.tag", "v3.10.0",
				),
		},
		{
			Name: "Set postInstall.labelNamespace.image.pullPolicy to IfNotPresent",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.image.pullPolicy", "IfNotPresent",
				),
		},
		{
			Name: "Set postInstall.labelNamespace.image.pullPolicy to Always",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.image.pullPolicy", "Always",
				),
		},
		{
			Name: "Set postInstall.labelNamespace.image.pullPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.image.pullPolicy", "Never",
				),
		},
		{
			Name: "Set postInstall.labelNamespace.image.pullSecrets",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.labelNamespace.image.pullSecrets", testPullSecrets,
				),
		},
		{
			Name: "Set postInstall.labelNamespace.extraNamespaces",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.labelNamespace.extraNamespaces", testExtraNamespaces,
				),
		},
		{
			Name: "Set postInstall.labelNamespace.podSecurity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.labelNamespace.podSecurity", testPodSecurityLabels,
				),
		},
		{
			Name: "Set postInstall.resources",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.resources", testResources,
				),
		},

		// For .Values.postInstall.probeWebhook
		{
			Name: "Set Values for postInstall.probeWebhook.enabled",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.enabled", "true",
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.enabled", "false",
				),
		},
		{
			Name: "Set .postInstall.probeWebhook.image.repository and .postInstall.probeWebhook.image.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.image.repository", "test-curlimages-repo",
				).
				SetValue(
					"postInstall.probeWebhook.image.tag", "v7.83.1",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.image.pullPolicy to IfNotPresent",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.image.pullPolicy", "IfNotPresent",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.image.pullPolicy to Always",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.image.pullPolicy", "Always",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.image.pullPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.image.pullPolicy", "Never",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.image.pullSecrets",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.image.pullSecrets", "testPullSecrets",
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.waitTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.probeWebhook.waitTimeout", 50,
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.httpTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.probeWebhook.httpTimeout", 1,
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.insecureHTTPS to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.insecureHTTPS", "true",
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.insecureHTTPS to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.insecureHTTPS", "false",
				),
		},
		{
			Name: "Set postInstall.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.affinity", testAffinity,
				),
		},
		{
			Name: "Set postInstall.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.securityContext", testSecurityContext,
				).
				Set(
					"postInstall.labelNamespace.enabled", true,
				),
		},
		{
			Name: "Set postInstall.labelNamespace.extraAnnotations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.labelNamespace.extraAnnotations", testPodAnnotation,
				).
				Set(
					"postInstall.labelNamespace.enabled", true,
				),
		},

		// // For .Values.preUninstall
		// {
		// 	Name: "Set preUninstall.deleteWebhookConfigurations.extraRules",
		// 	TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
		// 		SetValue("preUninstall.deleteWebhookConfigurations.extraRules", "testExtraRules"),
		// },
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.enabled to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.deleteWebhookConfigurations.enabled", false,
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.enabled to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.deleteWebhookConfigurations.enabled", true),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.image.repository and preUninstall.deleteWebhookConfigurations.image.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.image.repository", "test-gatekeeper-crd-repo",
				).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.image.tag", "v3.10.0",
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.image.pullPolicy to IfNotPresent",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.image.pullPolicy", "IfNotPresent",
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.image.pullPolicy to Always",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.image.pullPolicy", "Always",
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.image.pullPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.image.pullPolicy", "Never",
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.image.pullSecrets",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.deleteWebhookConfigurations.image.pullSecrets", testPullSecrets,
				),
		},
		{
			Name: "Set preUninstall.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.affinity", testAffinity,
				),
		},
		{
			Name: "Set preUninstall.resources",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.resources", testResources,
				),
		},
		{
			Name: "Set preUninstall.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.securityContext", testSecurityContext,
				),
		},

		// For .Values.images
		{
			Name: "Set .images.gatekeeper.repository and .images.gatekeeper.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"images.gatekeeper.repository", "test-gatekeeper-repo",
				).
				SetValue(
					"images.gatekeeper.tag", "v3.11.0",
				),
		},
		{
			Name: "Set .images.gatekeepercrd.repository and .images.gatekeepercrd.tag",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"images.gatekeepercrd.repository", "test-gatekeeper-crd-repo",
				).
				SetValue(
					"images.gatekeepercrd.tag", "v3.11.0",
				),
		},
		{
			Name: "Set images.pullPolicy to IfNotPresent",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"images.pullPolicy", "IfNotPresent",
				),
		},
		{
			Name: "Set images.pullPolicy to Always",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"images.pullPolicy", "Always",
				),
		},
		{
			Name: "Set images.pullPolicy to Never",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"images.pullPolicy", "Never",
				),
		},
		{
			Name: "Set images.pullSecrets",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"images.pullSecrets", testPullSecrets,
				),
		},
		{
			Name: "Set podAnnotations",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"podAnnotations", testPodAnnotation,
				),
		},
		{
			Name: "Set podLabels",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"podLabels", testPodLabels,
				),
		},
		{
			Name: "Set enableRuntimeDefaultSeccompProfile to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableRuntimeDefaultSeccompProfile", "false",
				),
		},
		{
			Name: "Set enableRuntimeDefaultSeccompProfile to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"enableRuntimeDefaultSeccompProfile", "true",
				),
		},

		// // For Values.controllerManager
		{
			Name: "Set controllerManager.exemptNamespaces",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.exemptNamespaces", testExemptNamespaces,
				),
		},
		{
			Name: "Set controllerManager.exemptNamespacePrefixes",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.exemptNamespacePrefixes", testExemptNamespacesPrefixes,
				),
		},
		{
			Name: "Set controllerManager.exemptNamespaceSuffixes",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.exemptNamespaceSuffixes", testExemptNamespacesSuffixes,
				),
		},
		{
			Name: "Set controllerManager.hostNetwork to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.hostNetwork", "true",
				),
		},
		{
			Name: "Set controllerManager.hostNetwork to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.hostNetwork", "false",
				),
		},
		{
			Name: "Set controllerManager.dnsPolicy to ClusterFirst",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.dnsPolicy", "ClusterFirst",
				),
		},
		{
			Name: "Set controllerManager.dnsPolicy to Default",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.dnsPolicy", "Default",
				),
		},
		{
			Name: "Set controllerManager.dnsPolicy to ClusterFirstWithHostNet",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.dnsPolicy", "ClusterFirstWithHostNet",
				),
		},
		{
			Name: "Set controllerManager.port",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.port", 8000,
				),
		},
		{
			Name: "Set controllerManager.metricsPort",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.metricsPort", 8080,
				),
		},
		{
			Name: "Set controllerManager.healthPort",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.healthPort", 8989,
				),
		},
		{
			Name: "Set controllerManager.readinessTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.readinessTimeout", 2,
				),
		},
		{
			Name: "Set controllerManager.livenessTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.livenessTimeout", 2,
				),
		},
		{
			Name: "Set controllerManager.priorityClassName",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.priorityClassName", "system-cluster-critical",
				),
		},
		{
			Name: "Set controllerManager.disableCertRotation to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.disableCertRotation", "true",
				),
		},
		{
			Name: "Set controllerManager.disableCertRotation to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.disableCertRotation", "false",
				),
		},
		{
			Name: "Set controllerManager.tlsMinVersion",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.tlsMinVersion", 1.2,
				),
		},
		{
			Name: "Set controllerManager.affinity",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.affinity", testDeploymentAffinity,
				),
		},
		{
			Name: "Set controllerManager.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.tolerations", testTolerations,
				),
		},
		{
			Name: "Set controllerManager.nodeSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.nodeSelector", testNodeSelector,
				),
		},
		// {
		// 	Name: "Set controllerManager.resources",

		// 	TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
		// 		Set(
		// 			"controllerManager.resources", testResources,
		// 		),
		// },
		{
			Name: "Set controllerManager.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.securityContext", testSecurityContext,
				),
		},
		{
			Name: "Set controllerManager.podSecurityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.podSecurityContext", testPodSecurityContext,
				),
		},
		{
			Name: "Set controllerManager.logFile",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.logFile", "test-file",
				),
		},
		{
			Name: "Set controllerManager.clientCertName",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.clientCertName", "test",
				),
		},
		{
			Name: "Set Values for controllerManager.networkPolicy.enabled",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.networkPolicy.enabled", true,
				),
		},
		{
			Name: "Set Values for controllerManager.networkPolicy.enabled to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.networkPolicy.enabled", false,
				),
		},
		{
			Name: "Set .Values.controllerManager.logLevel to Debug",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.logLevel", "DEBUG",
				),
		},
		{
			Name: "Set .Values.controllerManager.logLevel to INFO",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.logLevel", "INFO",
				),
		},
		{
			Name: "Set .Values.controllerManager.logLevel to WARNING",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.logLevel", "WARNING",
				),
		},
		{
			Name: "Set .Values.controllerManager.logLevel to ERROR",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.logLevel", "ERROR",
				),
		},

		// // For Values.audit
		{
			Name: "Set audit.hostNetwork to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.hostNetwork", "true",
				),
		},
		{
			Name: "Set audit.hostNetwork to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.hostNetwork", "false",
				),
		},
		{
			Name: "Set audit.dnsPolicy to ClusterFirst",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.dnsPolicy", "ClusterFirst",
				),
		},
		{
			Name: "Set audit.dnsPolicy to Default",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.dnsPolicy", "Default",
				),
		},
		{
			Name: "Set audit.writeToRAMDisk to false",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.writeToRAMDisk", false,
				),
		},
		{
			Name: "Set audit.writeToRAMDisk to true",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.writeToRAMDisk", true,
				),
		},
		{
			Name: "Set audit.dnsPolicy to ClusterFirstWithHostNet",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.dnsPolicy", "ClusterFirstWithHostNet",
				),
		},
		{
			Name: "Set audit.metricsPort",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.metricsPort", "8080",
				),
		},
		{
			Name: "Set audit.healthPort",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.healthPort", "8989",
				),
		},
		{
			Name: "Set audit.readinessTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.readinessTimeout", "2",
				),
		},
		{
			Name: "Set audit.livenessTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.livenessTimeout", "2",
				),
		},
		{
			Name: "Set audit.priorityClassName",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.priorityClassName", "system-cluster-critical",
				),
		},
		{
			Name: "Set audit.disableCertRotation to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.disableCertRotation", "true",
				),
		},
		{
			Name: "Set audit.disableCertRotation to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.disableCertRotation", "false",
				),
		},
		{
			Name: "Set audit.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.tolerations", testTolerations,
				),
		},
		{
			Name: "Set audit.nodeSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.nodeSelector", testNodeSelector,
				),
		},

		{
			Name: "Set audit.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.affinity", testAffinity,
				),
		},
		{
			Name: "Set audit.resources",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.resources", testResources,
				),
		},

		{
			Name: "Set audit.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.securityContext", testSecurityContext,
				),
		},
		{
			Name: "Set audit.podSecurityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"audit.podSecurityContext", testPodSecurityContext,
				),
		},
		{
			Name: "Set audit.logFile",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.logFile", "test-file",
				),
		},
		{
			Name: "Set .Values.audit.logLevel to Debug",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.logLevel", "DEBUG",
				),
		},
		{
			Name: "Set .Values.audit.logLevel to INFO",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.logLevel", "INFO",
				),
		},
		{
			Name: "Set .Values.audit.logLevel to WARNING",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.logLevel", "WARNING",
				),
		},
		{
			Name: "Set .Values.audit.logLevel to ERROR",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.logLevel", "ERROR",
				),
		},

		{
			Name: "Set crds.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"crds.affinity", testAffinity,
				),
		},
		{
			Name: "Set crds.resources",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"crds.resources", testResources,
				),
		},
		{
			Name: "Set crds.securityContext",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"crds.securityContext", testSecurityContext,
				),
		},
		{
			Name: "Set pdb.controllerManager.minAvailable",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"pdb.controllerManager.minAvailable", 1,
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
			Name: "Set Values.global.cattle.systemDefaultRegistry",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("global.cattle.systemDefaultRegistry", "test-registry"),
		},
		{
			Name: "Set externalCertInjection.enabled to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"externalCertInjection.enabled", "true",
				),
		},
		{
			Name: "Set externalCertInjection.enabled to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"externalCertInjection.enabled", "false",
				),
		},
		{
			Name: "Set externalCertInjection.secretName",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"externalCertInjection.secretName", "secret",
				),
		},
		{
			Name: "Set Values.nameOverride",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"nameOverride", "example-chart",
				),
		},
		{
			Name: "Set disabledBuiltins",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"disabledBuiltins", testDisabledBuiltins,
				),
		},
		{
			Name: "Set upgradeCRDs.enabled to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"upgradeCRDs.enabled", "true",
				),
		},
		{
			Name: "Set upgradeCRDs.enabled to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"upgradeCRDs.enabled", "false",
				),
		},
		{
			Name: "Set rbac.create to True",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"rbac.create", "true",
				),
		},
		{
			Name: "Set rbac.create to False",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"rbac.create", "false",
				),
		},
		{
			Name: "Set controllerManager.extraRules and rbac.create",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"rbac", map[string]interface{}{
						"create": true,
					}).
				Set("controllerManager.extraRules", testExtraRules),
		},
		{
			Name: "Set postInstall.labelNamespace.extraRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"rbac", map[string]interface{}{
						"create": true,
					}).
				Set(
					"postInstall.labelNamespace.extraRules", testExtraRules,
				),
		},
		{
			Name: "Set upgradeCRDs.extraRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"rbac", map[string]interface{}{
						"create": true,
					}).
				Set(
					"upgradeCRDs.extraRules", testExtraRules,
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.extraRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"rbac", map[string]interface{}{
						"create": true,
					}).
				Set(
					"preUninstall.deleteWebhookConfigurations.extraRules", testExtraRules,
				),
		},
		{
			Name: "Set controllerManager.topologySpreadConstraints",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("controllerManager.topologySpreadConstraints", testTopologySpreadConstraints),
		},
		{
			Name: "Set mutatingWebhookName and mutatingWebhookExemptNamespacesLabels",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("mutatingWebhookName", "mutating-webhook").
				Set("mutatingWebhookExemptNamespacesLabels", testWebhookExemptNamespacesLabels).
				Set("Values.disableMutation", false),
		},
		{
			Name: "Set mutatingWebhookName",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("mutatingWebhookName", "mutating-webhook"),
		},
		{
			Name: "Set podCountLimit",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("podCountLimit", "5"),
		},
		{
			Name: "Set postInstall.labelNamespace.extraRules and rbac.create",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("rbac.create", true).
				Set("postInstall.labelNamespace.extraRules", testExtraRules),
		},
		{
			Name: "Set service to nil",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("service", nil),
		},
		{
			Name: "Set service to empty map",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("service", map[string]interface{}{}),
		},
		{
			Name: "Set service.healthzPort",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("service.healthzPort", 8080),
		},
		{
			Name: "Set service.type to NodePort",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("service.type", corev1.ServiceTypeNodePort),
		},
		{
			Name: "Set service.type to LoadBalancer and service.loadBalancerIP",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("service", map[string]interface{}{
					"type":           corev1.ServiceTypeLoadBalancer,
					"loadBalancerIP": "172.82.12.1",
				}),
		},
		{
			Name: "Set service.type to ExternalName",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("service.type", corev1.ServiceTypeExternalName),
		},
		{
			Name: "Set crds.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"crds.tolerations", testTolerations,
				),
		},
		{
			Name: "Set postInstall.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.tolerations", testTolerations,
				),
		},
		{
			Name: "Set preUninstall.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.tolerations", testTolerations,
				),
		},
		{
			Name: "Set validatingWebhookCustomRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("validatingWebhookCustomRules", testWebhookCustomRules),
		},
		{
			Name: "Set mutatingWebhookCustomRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("mutatingWebhookCustomRules", testWebhookCustomRules),
		},
		{
			Name: "Set validatingWebhookName and validatingWebhookExemptNamespacesLabels",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set("validatingWebhookName", "mutating-webhook").
				Set("validatingWebhookExemptNamespacesLabels", testWebhookExemptNamespacesLabels).
				Set("Values.disableMutation", false),
		},
	},

	NamedChecks: []test.NamedCheck{

		// {
		// 	Name:   "All Workloads Have Service Account",
		// 	Checks: common.AllWorkloadsHaveServiceAccount,
		// },
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
			Name: "Check gatekeeper-controller-manager deployment has correct number of replicas (.Values.replicas)",
			Covers: []string{
				".Values.replicas",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.Name != "gatekeeper-controller-manager" {
						return
					}

					expectedReplicasValue, ok := checker.RenderValue[int32](tc, ".Values.replicas")
					if ok {
						assert.NotNil(tc.T, deployment.Spec.Replicas)

						assert.Equal(tc.T,
							expectedReplicasValue, *deployment.Spec.Replicas,
							"deplooyment %s does not have correct number of replicas, expected: %v got: %v",
							deployment.Name, expectedReplicasValue, *deployment.Spec.Replicas,
						)
					}
				}),
			},
		},
		{
			Name: "Check gatekeeper-audit-controller deployment has correct auditInterval (.Values.auditInterval)",
			Covers: []string{
				".Values.auditInterval",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditIntervalValue, ok := checker.RenderValue[int](tc, ".Values.auditInterval")

						expectedArg := fmt.Sprintf("--audit-interval=%d", auditIntervalValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct audit interval argument",
								container.Name, obj.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct auditMatchKindOnly set (.Values.auditMatchKindOnly)",
			Covers: []string{
				".Values.auditMatchKindOnly",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditMatchKindOnlyVal, ok := checker.RenderValue[bool](tc, ".Values.auditMatchKindOnly")

						expectedArg := fmt.Sprintf("--audit-match-kind-only=%t", auditMatchKindOnlyVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct auditMatchKindOnly argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct auditFromCache set (.Values.auditFromCache)",
			Covers: []string{
				".Values.auditFromCache",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditFromCacheVal, ok := checker.RenderValue[bool](tc, ".Values.auditFromCache")

						expectedArg := fmt.Sprintf("--audit-from-cache=%t", auditFromCacheVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct auditFromCache argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment container has correct validatingWebhookName arg (.Values.validatingWebhookName)",
			Covers: []string{
				".Values.validatingWebhookName",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						validatingWebhookNameVal, ok := checker.RenderValue[string](tc, ".Values.validatingWebhookName")

						expectedArg := fmt.Sprintf("--validating-webhook-configuration-name=%s", validatingWebhookNameVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct validatingWebhookName argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct disableMutation  (.Values.disableMutation)",
			Covers: []string{
				".Values.disableMutation",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						disableMutationVal, ok := checker.RenderValue[bool](tc, ".Values.disableMutation")

						expectedArg := "--operation=mutation-status"
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found == !disableMutationVal,
								"container %s of obj %s does not have correct disableMutation argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct number of constraintViolationsLimit (.Values.constraintViolationsLimit)",
			Covers: []string{
				".Values.constraintViolationsLimit",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						constraintViolationsLimitValue, ok := checker.RenderValue[int](tc, ".Values.constraintViolationsLimit")

						expectedArg := fmt.Sprintf("--constraint-violations-limit=%d", constraintViolationsLimitValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct constraintsViolation argument",
								container.Name, obj.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct enableExternalData (.Values.enableExternalData)",
			Covers: []string{
				".Values.enableExternalData",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						enableExternalDataValue, ok := checker.RenderValue[bool](tc, ".Values.enableExternalData")

						expectedArg := fmt.Sprintf("--enable-external-data=%t", enableExternalDataValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct enableExternalData argument",
								container.Name, obj.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct enableGeneratorResourceExpansion Args (.Values.enableGeneratorResourceExpansion)",
			Covers: []string{
				".Values.enableGeneratorResourceExpansion",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						enableGeneratorResourceExpansionValue, ok := checker.RenderValue[int](tc, ".Values.enableGeneratorResourceExpansion")

						expectedArg := fmt.Sprintf("--enable-generator-resource-expansion=%d", enableGeneratorResourceExpansionValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct enableGeneratorResourceExpansion argument",
								container.Name, obj.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct number of auditChunkSize (.Values.auditChunkSize)",
			Covers: []string{
				".Values.auditChunkSize",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditChunkSizeValue, ok := checker.RenderValue[int](tc, ".Values.auditChunkSize")

						expectedArg := fmt.Sprintf("--audit-chunk-size=%d", auditChunkSizeValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct auditChunkSize argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment containers has correct metrics backend arg (.Values.metricsBackends)",
			Covers: []string{
				".Values.metricsBackends",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						metricsBackendsValue, ok := checker.RenderValue[[]string](tc, ".Values.metricsBackends")

						expectedArg := fmt.Sprintf("--metrics-backend=%s", metricsBackendsValue[0])
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct metricsBackends argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct number of enableTLSHealthcheck (.Values.enableTLSHealthcheck)",
			Covers: []string{
				".Values.enableTLSHealthcheck",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != " gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						enableTLSHealthcheckValue, _ := checker.RenderValue[bool](tc, ".Values.enableTLSHealthcheck")

						expected := container.Args

						if enableTLSHealthcheckValue {

							expected = append(container.Args, "--enable-tls-healthcheck")
						}

						assert.Equal(tc.T, expected, container.Args,
							"container %s of obj %s does not have correct tlsHealthCheck argument set. Expected container args: %v. Got: %v",
							container.Name, obj.GetName(), expected, container.Args)
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct number of maxServingThreads (.Values.maxServingThreads)",
			Covers: []string{
				".Values.maxServingThreads",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						maxServingThreadsValue, ok := checker.RenderValue[int](tc, ".Values.maxServingThreads")

						expectedArg := fmt.Sprintf("--max-serving-threads=%d", maxServingThreadsValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct maxServingThreads argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct logLevel set (.Values.logLevel)",
			Covers: []string{
				".Values.logLevel",
				".Values.audit.logLevel",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						logLevelValue, ok := checker.RenderValue[string](tc, ".Values.logLevel")
						auditLogLevelValue, _ := checker.RenderValue[string](tc, ".Values.audit.logLevel")

						if len(auditLogLevelValue) > 0 {
							expectedArg := fmt.Sprintf("--log-level=%s", auditLogLevelValue)
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct logLevel argument",
									container.Name, obj.GetName())
							}
						} else {
							expectedArg := fmt.Sprintf("--log-level=%s", logLevelValue)
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct logLevel argument",
									container.Name, obj.GetName())
							}
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct logDenies set (.Values.logDenies)",
			Covers: []string{
				".Values.logDenies",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						logDeniesVal, ok := checker.RenderValue[bool](tc, ".Values.logDenies")

						expectedArg := fmt.Sprintf("--log-denies=%t", logDeniesVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct logDenies argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct logMutations set (.Values.logMutations)",
			Covers: []string{
				".Values.logMutations",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						logMutationsVal, ok := checker.RenderValue[bool](tc, ".Values.logMutations")

						expectedArg := fmt.Sprintf("--log-mutations=%t", logMutationsVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct logMutations argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},
		{
			Name: "Check gatekeeper-controller-manager deployment has correct mutationAnnotations set (.Values.mutationAnnotations)",
			Covers: []string{
				".Values.mutationAnnotations",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						mutationAnnotationsVal, ok := checker.RenderValue[bool](tc, ".Values.mutationAnnotations")

						expectedArg := fmt.Sprintf("--mutation-annotations=%t", mutationAnnotationsVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct mutationAnnotations argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct emitAdmissionEvents set (.Values.emitAdmissionEvents)",
			Covers: []string{
				".Values.emitAdmissionEvents",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						emitAdmissionEventsVal, ok := checker.RenderValue[bool](tc, ".Values.emitAdmissionEvents")

						expectedArg := fmt.Sprintf("--emit-admission-events=%t", emitAdmissionEventsVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct emitAdmissionEvents argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct emitAuditEvents set (.Values.emitAuditEvents)",
			Covers: []string{
				".Values.emitAuditEvents",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						emitAuditEventsVal, ok := checker.RenderValue[bool](tc, ".Values.emitAuditEvents")

						expectedArg := fmt.Sprintf("--emit-audit-events=%t", emitAuditEventsVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct emitAuditEvents argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment container has correct admissionEventsInvolvedNamespace arg set (.Values.admissionEventsInvolvedNamespace)",
			Covers: []string{
				".Values.admissionEventsInvolvedNamespace",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						admissionEventsInvolvedNamespaceVal, ok := checker.RenderValue[bool](tc, ".Values.admissionEventsInvolvedNamespace")

						expectedArg := fmt.Sprintf("--admission-events-involved-namespace=%t", admissionEventsInvolvedNamespaceVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct admissionEventsInvolvedNamespace argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment container has correct auditEventsInvolvedNamespace arg set (.Values.auditEventsInvolvedNamespace)",
			Covers: []string{
				".Values.auditEventsInvolvedNamespace",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditEventsInvolvedNamespaceVal, ok := checker.RenderValue[bool](tc, ".Values.auditEventsInvolvedNamespace")

						expectedArg := fmt.Sprintf("--audit-events-involved-namespace=%t", auditEventsInvolvedNamespaceVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct auditEventsInvolvedNamespace argument set",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		// Checkers for Values.postUpgrade

		{
			Name: "Check postUpgrade.labelNamespace.enabled",
			Covers: []string{
				".Values.postUpgrade.labelNamespace.enabled",
				".Values.postUpgrade.probeWebhook.enabled",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					// enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")
					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")
					enableprobeWebhookVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.probeWebhook.enabled")

					if !enableLabelNamespaceVal && enableprobeWebhookVal {
						found := false
						if job.Name == "gatekeeper-update-namespace-label-post-upgrade" {
							found = true
						}

						assert.True(tc.T, found,
							"Incorrect postUpgrade labelNamespace configuration")
					}

				}),
			},
		},

		// {
		// 	Name: "Check namespace-post-upgrade job containers have correct extra namespace args (.Values.postUpgrade.labelNamespace.extraNamespaces)",
		// 	Covers: []string{
		// 		".Values.postUpgrade.labelNamespace.extraNamespaces",
		// 	},

		// 	Checks: test.Checks{
		// 		checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

		// 			enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

		// 			if !enableLabelNamespaceVal && job.GetName() != "gatekeeper-update-namespace-label-post-upgrade" {
		// 				return
		// 			}

		// 			if len(job.Spec.Template.Spec.Containers) > 0 {

		// 				extraNamespacesVal, _ := checker.RenderValue[[]string](tc, ".Values.postUpgrade.labelNamespace.extraNamespaces")
		// 				if len(extraNamespacesVal) > 0 {
		// 					container := job.Spec.Template.Spec.Containers[0]

		// 					if container.Name != "kubectl-label-extra" {
		// 						return
		// 					}

		// 					containerArgsVal := container.Args
		// 					args := make(map[string]bool)

		// 					for _, s := range containerArgsVal {
		// 						args[s] = true
		// 					}

		// 					allExist := true

		// 					for _, s := range extraNamespacesVal {
		// 						if _, ok := args[s]; !ok {
		// 							allExist = false
		// 							break
		// 						}
		// 					}
		// 					assert.True(tc.T, allExist,
		// 						"Job %s container does not have correct namespaces in container args", job.Name)
		// 				}
		// 			}
		// 		}),
		// 	},
		// },

		{
			Name: "Check namespace-post-upgrade job tcontainers have correct podSecurity labels in container args (.Values.postUpgrade.labelNamespace.podSecurity)",
			Covers: []string{
				".Values.postUpgrade.labelNamespace.podSecurity",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					assert.Equal(tc.T,
						1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers, expected: %v got: %v",
						job.GetName(), 1, len(job.Spec.Template.Spec.Containers),
					)

					if len(job.Spec.Template.Spec.Containers) > 0 {
						container := job.Spec.Template.Spec.Containers[0]

						podSecurityVal, _ := checker.RenderValue[[]string](tc, ".Values.postUpgrade.labelNamespace.podSecurity")
						enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

						if !enableLabelNamespaceVal {
							return
						}

						containerArgsVal := container.Args

						args := make(map[string]bool)

						for _, s := range containerArgsVal {
							args[s] = true
						}

						allExist := true

						for _, s := range podSecurityVal {
							if _, ok := args[s]; !ok {
								allExist = false
								break
							}
						}
						assert.True(tc.T, allExist,
							"Job %s container does not have correct podSecurity labels in container args", job.Name)
					}
				}),
			},
		},

		{
			Name: "Check kubectl image repository and tag for postUpgrade Job",
			Covers: []string{
				".Values.postUpgrade.labelNamespace.image.repository",
				".Values.postUpgrade.labelNamespace.image.tag",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label-post-upgrade" {
						return
					}

					ok := assert.Equal(tc.T, 1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers: expected: %d, got: %d",
						job.Name, 1, len(job.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					kubectlRepo, _ := checker.RenderValue[string](tc, ".Values.postUpgrade.labelNamespace.image.repository")
					kubectlTag, _ := checker.RenderValue[string](tc, ".Values.postUpgrade.labelNamespace.image.tag")
					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

					if !enableLabelNamespaceVal {
						return
					}

					containerImage := kubectlRepo + ":" + kubectlTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of job %s does not have correct image: expected: %v got: %v",
						container.Name, job.Name, expectedContainerImage, container.Image)

				}),
			},
		},

		{
			Name: "Check that postUpgrade job has correct imagePullSecrets",
			Covers: []string{
				".Values.postUpgrade.labelNamespace.image.pullSecrets",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label-post-upgrade" {
						return
					}

					labelNamespaceEnabled, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

					expectedImagePullSecrets, _ := checker.RenderValue[[]corev1.LocalObjectReference](tc, ".Values.postUpgrade.labelNamespace.image.pullSecrets")
					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

					if !enableLabelNamespaceVal {
						return
					}

					if len(expectedImagePullSecrets) == 0 || !labelNamespaceEnabled {
						expectedImagePullSecrets = nil
					}

					assert.Equal(tc.T,
						expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets,
						"job %s does not have correct imagePullSecrets: expected: %v got: %v",
						job.Name, expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets)
				}),
			},
		},

		{
			Name: "Check that postUpgrade job containers have correct imagePullPolicy",
			Covers: []string{
				".Values.postUpgrade.labelNamespace.image.pullPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label-post-upgrade" {
						return
					}

					expectedImagePullPolicy, exists := checker.RenderValue[corev1.PullPolicy](tc, ".Values.postUpgrade.labelNamespace.image.pullPolicy")
					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

					if !enableLabelNamespaceVal {
						return
					}

					if exists {
						for _, container := range job.Spec.Template.Spec.Containers {

							assert.Equal(tc.T,
								expectedImagePullPolicy, container.ImagePullPolicy,
								"container %s of job %s does not have correct imagePullPolicy: expected: %v got: %v",
								container.Name, job.Name, expectedImagePullPolicy, container.ImagePullPolicy)
						}
					}
				}),
			},
		},

		{

			Name: "Check postUpgrade.affinity",
			Covers: []string{
				".Values.postUpgrade.affinity",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label-post-upgrade" {
						return
					}
					container := job.Spec.Template.Spec

					auditAffinityAddedFromValues, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.postUpgrade.affinity")
					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

					if !enableLabelNamespaceVal {
						return
					}

					expectedAffinity := auditAffinityAddedFromValues
					assert.Equal(tc.T,
						expectedAffinity, container.Affinity,
						"job %s does not have correct affinity: expected: %v, got: %v",
						job.Name, expectedAffinity, container.Affinity)

				}),
			},
		},

		{
			Name: "Check postUpgrade has correct SecurityContext as per given value",
			Covers: []string{
				".Values.postUpgrade.securityContext",
			},

			Checks: test.Checks{

				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label-post-upgrade" {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]
					expected, _ := checker.RenderValue[*corev1.SecurityContext](tc, "Values.postUpgrade.securityContext")
					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")
					enableRuntimeDefaultSeccompProfileVal, _ := checker.RenderValue[bool](tc, "Values.enableRuntimeDefaultSeccompProfile")

					if !enableLabelNamespaceVal {
						return
					}

					if enableRuntimeDefaultSeccompProfileVal {
						expected.SeccompProfile = &corev1.SeccompProfile{
							Type: corev1.SeccompProfileTypeRuntimeDefault,
						}
					}

					assert.True(tc.T,
						reflect.DeepEqual(expected, container.SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						job.Name, job, expected, container.SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check postUpgrade resources",
			Covers: []string{
				".Values.postUpgrade.resources",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postUpgrade.labelNamespace.enabled")

					if !enableLabelNamespaceVal && job.Name != "gatekeeper-update-namespace-label-post-upgrade" {
						return
					}

					container := job.Spec.Template.Spec

					ok := assert.Equal(tc.T, 1, len(container.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						job.Name, 1, len(container.Containers))

					if !ok {
						return
					}

					expectedResourceReq, _ := checker.RenderValue[corev1.ResourceRequirements](tc, ".Values.postUpgrade.resources")

					assert.Equal(tc.T,
						expectedResourceReq, container.Containers[0].Resources,
						"container %s of deployment %s does not have correct resources constraint: expected: %v, got: %v",
						container.Containers[0].Name, job.Name, expectedResourceReq, container.Containers[0].Resources)

				}),
			},
		},
		{
			Name: "Check post-upgrade job has correct annotations (.Values.postUpgrade.labelNamespace.extraAnnotations)",
			Covers: []string{
				".Values.postUpgrade.labelNamespace.extraAnnotations",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != " gatekeeper-update-namespace-label-post-upgrade" {
						return
					}

					expectedExtraAnnotations, _ := checker.RenderValue[map[string]string](tc, ".Values.postUpgrade.labelNamespace.extraAnnotations")

					deployementAnnotationVal := job.Annotations

					args := make(map[string]bool)

					for _, s := range deployementAnnotationVal {
						args[s] = true
					}

					allExist := true

					for _, s := range expectedExtraAnnotations {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"job %s container does not have correct Annotations", job.Name)
				}),
			},
		},

		// For Values.postInstall

		{
			Name: "Check postInstall.labelNamespace.enabled",
			Covers: []string{
				".Values.postInstall.labelNamespace.enabled",
				".Values.postInstall.probeWebhook.enabled",
			},

			Checks: test.Checks{
				checker.OnResources(func(tc *checker.TestContext, jobs []*batchv1.Job) {

					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postInstall.labelNamespace.enabled")
					enableprobeWebhookVal, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !enableLabelNamespaceVal && enableprobeWebhookVal {
						found := false
						for _, job := range jobs {
							if job.Name == "gatekeeper-probe-webhook-post-install" {
								found = true
							}
						}

						assert.True(tc.T, found,
							"Incorrect postInstall labelNamespace configuration")
					}

				}),
			},
		},

		{
			Name: "Check images repository and tag for postInstall Job",
			Covers: []string{
				".Values.postInstall.labelNamespace.image.repository",
				".Values.postInstall.labelNamespace.image.tag",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					ok := assert.Equal(tc.T, 1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers: expected: %d, got: %d",
						job.Name, 1, len(job.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					imageRepo, _ := checker.RenderValue[string](tc, ".Values.postInstall.labelNamespace.image.repository")
					imageTag, _ := checker.RenderValue[string](tc, ".Values.postInstall.labelNamespace.image.tag")

					containerImage := imageRepo + ":" + imageTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of job %s does not have correct image: expected: %v got: %v",
						container.Name, job.Name, expectedContainerImage, container.Image)

				}),
			},
		},

		{
			Name: "Check that postInstall job containers have correct imagePullPolicy",
			Covers: []string{
				".Values.postInstall.labelNamespace.image.pullPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					expectedImagePullPolicy, exists := checker.RenderValue[corev1.PullPolicy](tc, ".Values.postInstall.labelNamespace.image.pullPolicy")

					if exists {
						for _, container := range job.Spec.Template.Spec.Containers {

							assert.Equal(tc.T,
								expectedImagePullPolicy, container.ImagePullPolicy,
								"container %s of job %s does not have correct imagePullPolicy: expected: %v got: %v",
								container.Name, job.Name, expectedImagePullPolicy, container.ImagePullPolicy)
						}
					}
				}),
			},
		},

		{
			Name: "Check that postInstall job has correct imagePullSecrets",
			Covers: []string{
				".Values.postInstall.labelNamespace.image.pullSecrets",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					labelNamespaceEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.labelNamespace.enabled")

					expectedImagePullSecrets, _ := checker.RenderValue[[]corev1.LocalObjectReference](tc, ".Values.postInstall.labelNamespace.image.pullSecrets")

					if len(expectedImagePullSecrets) == 0 || !labelNamespaceEnabled {
						expectedImagePullSecrets = nil
					}

					assert.Equal(tc.T,
						expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets,
						"job %s does not have correct image: expected: %v got: %v",
						job.Name, expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets)
				}),
			},
		},

		{

			Name: "Check postInstall.affinity",
			Covers: []string{
				".Values.postInstall.affinity",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}
					container := job.Spec.Template.Spec

					auditAffinityAddedFromValues, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.postInstall.affinity")

					expectedAffinity := auditAffinityAddedFromValues
					assert.Equal(tc.T,
						expectedAffinity, container.Affinity,
						"job %s does not have correct affinity: expected: %v, got: %v",
						job.Name, expectedAffinity, container.Affinity)

				}),
			},
		},

		{
			Name: "Check postInstall has correct SecurityContext as per given value",
			Covers: []string{
				".Values.postInstall.securityContext",
			},

			Checks: test.Checks{

				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]

					enableRuntimeDefaultSeccompProfileVal, _ := checker.RenderValue[bool](tc, "Values.enableRuntimeDefaultSeccompProfile")

					expected, _ := checker.RenderValue[*corev1.SecurityContext](tc, "Values.postInstall.securityContext")

					if enableRuntimeDefaultSeccompProfileVal {
						expected.SeccompProfile = &corev1.SeccompProfile{
							Type: corev1.SeccompProfileTypeRuntimeDefault,
						}
					}

					assert.True(tc.T,
						reflect.DeepEqual(expected, container.SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						job.Name, job, expected, container.SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check postInstall resources",
			Covers: []string{
				".Values.postInstall.resources",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					enableLabelNamespaceVal, _ := checker.RenderValue[bool](tc, ".Values.postInstall.labelNamespace.enabled")

					if !enableLabelNamespaceVal && job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					if job.Name == "gatekeeper-update-namespace-label" {

						container := job.Spec.Template.Spec

						ok := assert.Equal(tc.T, 1, len(container.Containers),
							"deployment %s does not have correct number of container: expected: %d, got: %d",
							job.Name, 1, len(container.Containers))

						if !ok {
							return
						}

						expectedResourceReq, _ := checker.RenderValue[corev1.ResourceRequirements](tc, ".Values.postInstall.resources")

						assert.Equal(tc.T,
							expectedResourceReq, container.Containers[0].Resources,
							"container %s of deployment %s does not have correct resources constraint: expected: %v, got: %v",
							container.Containers[0].Name, job.Name, expectedResourceReq, container.Containers[0].Resources)

					}
				}),
			},
		},

		{
			Name: "Check namespace-post-install job tcontainers have correct extra namespace args (.Values.postInstall.labelNamespace.extraNamespaces)",
			Covers: []string{
				".Values.postInstall.labelNamespace.extraNamespaces",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					assert.Equal(tc.T,
						1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers, expected: %v got: %v",
						job.GetName(), 1, len(job.Spec.Template.Spec.Containers),
					)

					if len(job.Spec.Template.Spec.Containers) > 0 {
						labelNamespaceEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.labelNamespace.enabled")
						extraNamespacesVal, _ := checker.RenderValue[[]string](tc, ".Values.postInstall.labelNamespace.extraNamespaces")

						if len(extraNamespacesVal) > 0 && labelNamespaceEnabled {

							container := job.Spec.Template.Spec.Containers[1]
							containerArgsVal := container.Args
							args := make(map[string]bool)

							for _, s := range containerArgsVal {
								args[s] = true
							}

							allExist := true

							for _, s := range extraNamespacesVal {
								if _, ok := args[s]; !ok {
									allExist = false
									break
								}
							}
							assert.True(tc.T, allExist,
								"Job container does not have correct namespaces in container args")
						}
					}
				}),
			},
		},

		{
			Name: "Check namespace-post-install job tcontainers have correct podSecurity labels in container args (.Values.postInstall.labelNamespace.podSecurity)",
			Covers: []string{
				".Values.postInstall.labelNamespace.podSecurity",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					assert.Equal(tc.T,
						1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers, expected: %v got: %v",
						job.GetName(), 1, len(job.Spec.Template.Spec.Containers),
					)

					if len(job.Spec.Template.Spec.Containers) > 0 {
						container := job.Spec.Template.Spec.Containers[0]

						podSecurityVal, _ := checker.RenderValue[[]string](tc, ".Values.postInstall.labelNamespace.podSecurity")

						containerArgsVal := container.Args

						args := make(map[string]bool)

						for _, s := range containerArgsVal {
							args[s] = true
						}

						allExist := true

						for _, s := range podSecurityVal {
							if _, ok := args[s]; !ok {
								allExist = false
								break
							}
						}
						assert.True(tc.T, allExist,
							"Job container does not have correct podSecurity labels in container args")
					}
				}),
			},
		},

		{
			Name: "Check post-install job has correct annotations (.Values.postInstall.labelNamespace.extraAnnotations)",
			Covers: []string{
				".Values.postInstall.labelNamespace.extraAnnotations",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					expectedExtraAnnotations, _ := checker.RenderValue[map[string]string](tc, ".Values.postInstall.labelNamespace.extraAnnotations")

					if len(expectedExtraAnnotations) == 0 {
						expectedExtraAnnotations = nil
					}

					deployementAnnotationVal := job.Annotations

					args := make(map[string]bool)

					for _, s := range deployementAnnotationVal {
						args[s] = true
					}

					allExist := true

					for _, s := range expectedExtraAnnotations {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"job %s container does not have correct Annotations. Expected: %v, Got: %v",
						job.Name, expectedExtraAnnotations, deployementAnnotationVal)
				}),
			},
		},

		{
			Name: "Check images repository and tag for postInstall Job",
			Covers: []string{
				".Values.postInstall.probeWebhook.image.repository",
				".Values.postInstall.probeWebhook.image.tag",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !probeWebhookEnabled {
						return
					}

					ok := assert.Equal(tc.T, 1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers: expected: %d, got: %d",
						job.Name, 1, len(job.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := job.Spec.Template.Spec.InitContainers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					imageRepo, _ := checker.RenderValue[string](tc, ".Values.postInstall.probeWebhook.image.repository")
					imageTag, _ := checker.RenderValue[string](tc, ".Values.postInstall.probeWebhook.image.tag")

					containerImage := imageRepo + ":" + imageTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of job %s does not have correct image: expected: %v got: %v",
						container.Name, job.Name, expectedContainerImage, container.Image)

				}),
			},
		},

		{
			Name: "Check that namespace-post-install job containers have correct imagePullPolicy",
			Covers: []string{
				".Values.postInstall.probeWebhook.image.pullPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !probeWebhookEnabled {
						return
					}

					expectedImagePullPolicy, _ := checker.RenderValue[corev1.PullPolicy](tc, ".Values.postInstall.probeWebhook.image.pullPolicy")

					container := job.Spec.Template.Spec.InitContainers[0]

					assert.Equal(tc.T,
						expectedImagePullPolicy, container.ImagePullPolicy,
						"container %s of job %s does not have correct imagePullPolicy: expected: %v got: %v",
						container.Name, job.Name, expectedImagePullPolicy, container.ImagePullPolicy)
				}),
			},
		},

		{
			Name: "Check that postInstall job has correct imagePullSecrets",
			Covers: []string{
				".Values.postInstall.probeWebhook.image.pullSecrets",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-probe-webhook-post-install" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")
					expectedImagePullSecrets, _ := checker.RenderValue[[]corev1.LocalObjectReference](tc, ".Values.postInstall.probeWebhook.image.pullSecrets")

					if len(expectedImagePullSecrets) == 0 || !probeWebhookEnabled {
						expectedImagePullSecrets = nil
					}

					assert.Equal(tc.T,
						expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets,
						"job %s does not have correct imagePullSecrets: expected: %v got: %v",
						job.Name, expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets)
				}),
			},
		},

		{
			Name: "Check namespace-post-install job initcontainers have correct waitTimeout args (.Values.postInstall.probeWebhook.waitTimeout)",
			Covers: []string{
				".Values.postInstall.probeWebhook.waitTimeout",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !probeWebhookEnabled {
						return
					}

					assert.Equal(tc.T,
						1, len(job.Spec.Template.Spec.InitContainers),
						"job %s does not have correct number of containers, expected: %v got: %v",
						job.GetName(), 1, len(job.Spec.Template.Spec.InitContainers),
					)

					if len(job.Spec.Template.Spec.InitContainers) > 0 {
						container := job.Spec.Template.Spec.InitContainers[0]

						probeWebhookWaitTimeoutValue, ok := checker.RenderValue[int](tc, ".Values.postInstall.probeWebhook.waitTimeout")

						expectedArg := fmt.Sprintf("%d", probeWebhookWaitTimeoutValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"Initcontainer %s of job %s does not have correct waitTimeout args argument",
								container.Name, job.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check namespace-post-install job initcontainers have correct httpTimeout args (.Values.postInstall.probeWebhook.httpTimeout)",
			Covers: []string{
				".Values.postInstall.probeWebhook.httpTimeout",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !probeWebhookEnabled {
						return
					}

					assert.Equal(tc.T,
						1, len(job.Spec.Template.Spec.InitContainers),
						"job %s does not have correct number of containers, expected: %v got: %v",
						job.GetName(), 1, len(job.Spec.Template.Spec.InitContainers),
					)

					if len(job.Spec.Template.Spec.InitContainers) > 0 {
						container := job.Spec.Template.Spec.InitContainers[0]

						probeWebhookHttpTimeoutValue, ok := checker.RenderValue[int](tc, ".Values.postInstall.probeWebhook.httpTimeout")

						expectedArg := fmt.Sprintf("%d", probeWebhookHttpTimeoutValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"Initcontainer %s of job %s does not have correct httpTimeout argument",
								container.Name, job.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check namespace-post-install job initcontainers have correct insecureHTTPS args (.Values.postInstall.probeWebhook.httpTimeout)",
			Covers: []string{
				".Values.postInstall.probeWebhook.insecureHTTPS",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !probeWebhookEnabled {
						return
					}

					assert.Equal(tc.T,
						1, len(job.Spec.Template.Spec.InitContainers),
						"job %s does not have correct number of containers, expected: %v got: %v",
						job.GetName(), 1, len(job.Spec.Template.Spec.InitContainers),
					)

					if len(job.Spec.Template.Spec.InitContainers) > 0 {
						container := job.Spec.Template.Spec.InitContainers[0]

						probeWebhookInsecureHTTPS, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.insecureHTTPS")

						initContainerArgs := container.Args

						if probeWebhookInsecureHTTPS {

							assert.Equal(tc.T, initContainerArgs, container.Args,
								"container %s of obj %s does not have correct insecureHTTPS argument set. Expected container args: %v. Got: %v",
								container.Name, job.Name, initContainerArgs, container.Args)

						}

						assert.Equal(tc.T, initContainerArgs, container.Args,
							"container %s of obj %s does not have correct insecureHTTPS argument set. Expected container args: %v. Got: %v",
							container.Name, job.Name, initContainerArgs, container.Args)

					}
				}),
			},
		},

		// For preUninstall

		{
			Name: "Check gatekeeper image repository and tag for preUninstall Job",
			Covers: []string{
				".Values.preUninstall.deleteWebhookConfigurations.image.repository",
				".Values.preUninstall.deleteWebhookConfigurations.image.tag",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}

					ok := assert.Equal(tc.T, 1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers: expected: %d, got: %d",
						job.Name, 1, len(job.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					kubectlRepo, _ := checker.RenderValue[string](tc, ".Values.preUninstall.deleteWebhookConfigurations.image.repository")
					kubectlTag, _ := checker.RenderValue[string](tc, ".Values.preUninstall.deleteWebhookConfigurations.image.tag")

					containerImage := kubectlRepo + ":" + kubectlTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of job %s does not have correct image: expected: %v got: %v",
						container.Name, job.Name, expectedContainerImage, container.Image)

				}),
			},
		},

		{
			Name: "Check that preUninstall job has correct imagePullSecrets",
			Covers: []string{
				".Values.preUninstall.deleteWebhookConfigurations.image.pullSecrets",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}

					disableValidatingWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.disableValidatingWebhook")
					disableMutationEnabled, _ := checker.RenderValue[bool](tc, ".Values.disableMutation")
					deleteWebhookConfigurationsEnabled, _ := checker.RenderValue[bool](tc, ".Values.preUninstall.deleteWebhookConfigurations.enabled")

					expectedImagePullSecrets, _ := checker.RenderValue[[]corev1.LocalObjectReference](tc, ".Values.preUninstall.deleteWebhookConfigurations.image.pullSecrets")

					if len(expectedImagePullSecrets) == 0 || ((!disableValidatingWebhookEnabled || !disableMutationEnabled) && deleteWebhookConfigurationsEnabled) {
						expectedImagePullSecrets = nil
					}

					assert.Equal(tc.T,
						expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets,
						"job %s does not have correct imagePullSecrets: expected: %v got: %v",
						job.Name, expectedImagePullSecrets, job.Spec.Template.Spec.ImagePullSecrets)
				}),
			},
		},

		{

			Name: "Check preUninstall.affinity",
			Covers: []string{
				".Values.preUninstall.affinity",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}
					container := job.Spec.Template.Spec

					auditAffinityAddedFromValues, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.preUninstall.affinity")

					expectedAffinity := auditAffinityAddedFromValues
					assert.Equal(tc.T,
						expectedAffinity, container.Affinity,
						"job %s does not have correct affinity: expected: %v, got: %v",
						job.Name, expectedAffinity, container.Affinity)

				}),
			},
		},

		{
			Name: "Check preUninstall has correct SecurityContext as per given value",
			Covers: []string{
				".Values.preUninstall.securityContext",
			},

			Checks: test.Checks{

				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]

					expected, _ := checker.RenderValue[*corev1.SecurityContext](tc, "Values.preUninstall.securityContext")

					assert.True(tc.T,
						reflect.DeepEqual(expected, container.SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						job.Name, job, expected, container.SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check that preUninstall job containers have correct imagePullPolicy",
			Covers: []string{
				".Values.preUninstall.deleteWebhookConfigurations.image.pullPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}

					expectedImagePullPolicy, exists := checker.RenderValue[corev1.PullPolicy](tc, ".Values.preUninstall.deleteWebhookConfigurations.image.pullPolicy")

					if exists {
						for _, container := range job.Spec.Template.Spec.Containers {

							assert.Equal(tc.T,
								expectedImagePullPolicy, container.ImagePullPolicy,
								"container %s of job %s does not have correct imagePullPolicy: expected: %v got: %v",
								container.Name, job.Name, expectedImagePullPolicy, container.ImagePullPolicy)
						}
					}
				}),
			},
		},

		{
			Name: "Check preUninstall resources",
			Covers: []string{
				".Values.preUninstall.resources",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}

					container := job.Spec.Template.Spec

					ok := assert.Equal(tc.T, 1, len(container.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						job.Name, 1, len(container.Containers))

					if !ok {
						return
					}

					expectedResourceReq, _ := checker.RenderValue[corev1.ResourceRequirements](tc, ".Values.preUninstall.resources")

					assert.Equal(tc.T,
						expectedResourceReq, container.Containers[0].Resources,
						"container %s of deployment %s does not have correct resources constraint: expected: %v, got: %v",
						container.Containers[0].Name, job.Name, expectedResourceReq, container.Containers[0].Resources)

				}),
			},
		},

		// For Values.audit
		{
			Name: "Check gatekeeper-audit-controller deployment has correct hostNetwork (.Values.audit.hostNetwork)",
			Covers: []string{
				".Values.audit.hostNetwork",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					auditHostNetworkValue, _ := checker.RenderValue[bool](tc, ".Values.audit.hostNetwork")

					expectedArg := auditHostNetworkValue

					assert.Equal(tc.T,
						expectedArg, podTemplateSpec.Spec.HostNetwork,
						"audit-controller does not have correct HostNetwork set. Expected: %v got: %v",
						expectedArg, podTemplateSpec.Spec.HostNetwork,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct dnsPolicy (.Values.audit.dnsPolicy)",
			Covers: []string{
				".Values.audit.dnsPolicy",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					auditdnsPolicyValue, _ := checker.RenderValue[corev1.DNSPolicy](tc, ".Values.audit.dnsPolicy")

					expectedArg := auditdnsPolicyValue

					assert.Equal(tc.T,
						expectedArg, podTemplateSpec.Spec.DNSPolicy,
						"audit-controller does not have correct DNSPolicy set. Expected: %v got: %v",
						expectedArg, podTemplateSpec.Spec.DNSPolicy,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit deployment has correct volumes configuration (.Values.audit.writeToRAMDisk)",
			Covers: []string{
				".Values.audit.writeToRAMDisk",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if !checker.Select("gatekeeper-audit", DefaultNamespace, obj) {
						return
					}

					writeToRAMDisk, _ := checker.RenderValue[bool](tc, ".Values.audit.writeToRAMDisk")

					for _, vol := range podTemplateSpec.Spec.Volumes {
						if vol.Name == "tmp-volume" && writeToRAMDisk {
							assert.Equal(tc.T, corev1.StorageMediumMemory, vol.EmptyDir.Medium,
								"deployment %s does not have correct volume medium for volume %s, expected: %v, got:%v", obj.GetName(),
								vol.Name, corev1.StorageMediumMemory, vol.EmptyDir.Medium)
						} else if vol.Name == "tmp-volume" {
							assert.Equal(tc.T, corev1.StorageMediumDefault, vol.EmptyDir.Medium,
								"deployment %s does not have correct volume medium for volume %s, expected: %v, got:%v", obj.GetName(),
								vol.Name, corev1.StorageMediumMemory, vol.EmptyDir.Medium)
						}
					}

				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct priorityClassName (.Values.audit.priorityClassName)",
			Covers: []string{
				".Values.audit.priorityClassName",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					PriorityClassNameValue, _ := checker.RenderValue[string](tc, ".Values.audit.priorityClassName")

					expectedArg := PriorityClassNameValue

					assert.Equal(tc.T,
						expectedArg, podTemplateSpec.Spec.PriorityClassName,
						"audit-controller does not have correct PriorityClassName set. Expected: %v got: %v",
						expectedArg, podTemplateSpec.Spec.PriorityClassName,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-critical-pods resource quota has correct priorityClassName (.Values.audit.priorityClassName)",
			Covers: []string{
				".Values.audit.priorityClassName",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, resourceQuota *corev1.ResourceQuota) {

					if resourceQuota.Name != "gatekeeper-critical-pods" {
						return
					}

					PriorityClassNameValue, _ := checker.RenderValue[string](tc, ".Values.audit.priorityClassName")

					expectedArg := PriorityClassNameValue

					assert.Equal(tc.T,
						expectedArg, resourceQuota.Spec.ScopeSelector.MatchExpressions[0].Values[1],
						"gatekeeper-critical-pods resourcequota does not have correct PriorityClassName set. Expected: %v got: %v",
						expectedArg, resourceQuota.Spec.ScopeSelector.MatchExpressions[0].Values[1],
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct disable-cert-rotation arg set in container args (.Values.audit.disableCertRotation)",
			Covers: []string{
				".Values.audit.disableCertRotation",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditDisableCertRotationValue, ok := checker.RenderValue[bool](tc, ".Values.audit.disableCertRotation")

						expectedArg := fmt.Sprintf("--disable-cert-rotation=%t", auditDisableCertRotationValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct auditDisableCertRotation argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct metricsPort (.Values.audit.metricsPort)",
			Covers: []string{
				".Values.audit.metricsPort",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditMetricsPortValue, ok := checker.RenderValue[int](tc, ".Values.audit.metricsPort")

						expectedArg := fmt.Sprintf("--prometheus-port=%d", auditMetricsPortValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct audit.metricsPort argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct logFile (.Values.audit.logFile)",
			Covers: []string{
				".Values.audit.logFile",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditLogFileVal, ok := checker.RenderValue[string](tc, ".Values.audit.logFile")

						expectedArg := fmt.Sprintf("--log-file=%s", auditLogFileVal)
						if len(auditLogFileVal) > 0 {
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct audit.logFile argument",
									container.Name, obj.GetName())
							}
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct healthPort (.Values.audit.healthPort)",
			Covers: []string{
				".Values.audit.healthPort",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditHealthPortValue, ok := checker.RenderValue[int](tc, ".Values.audit.healthPort")

						expectedLivenessProbePort := container.LivenessProbe.HTTPGet.Port

						expectedContainerHealthzPort := container.Ports[1].ContainerPort

						expectedArg := fmt.Sprintf("--health-addr=:%d", auditHealthPortValue)

						if ok {
							found := false

							if auditHealthPortValue == int(expectedContainerHealthzPort) {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct healthz containerPort",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							if auditHealthPortValue == expectedLivenessProbePort.IntValue() {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct LivenessProbe Port",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							if auditHealthPortValue == expectedLivenessProbePort.IntValue() {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct LivenessProbe Port",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct audit.healthPort argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct readiness timeout (.Values.audit.readinessTimeout)",
			Covers: []string{
				".Values.audit.readinessTimeout",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditReadinessTimeoutValue, _ := checker.RenderValue[int](tc, ".Values.audit.readinessTimeout")

						expectedAuditReadinessTimeout := int32(auditReadinessTimeoutValue)

						assert.Equal(tc.T,
							expectedAuditReadinessTimeout, container.ReadinessProbe.TimeoutSeconds,
							"container %s of obj %s does not have correct audit.readinessTimeout argument, expected: %v, got: %v",
							container.Name, obj.GetName(), expectedAuditReadinessTimeout, container.ReadinessProbe.TimeoutSeconds)
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct liveness timeout (.Values.audit.livenessTimeout)",
			Covers: []string{
				".Values.audit.livenessTimeout",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						auditLivenessTimeoutValue, _ := checker.RenderValue[int](tc, ".Values.audit.livenessTimeout")

						expectedAuditLivenessTimeout := int32(auditLivenessTimeoutValue)

						assert.Equal(tc.T,
							expectedAuditLivenessTimeout, container.LivenessProbe.TimeoutSeconds,
							"container %s of obj %s does not have correct audit.readinessTimeout argument, expected: %v, got: %v",
							container.Name, obj.GetName(), expectedAuditLivenessTimeout, container.LivenessProbe.TimeoutSeconds)
					}
				}),
			},
		},

		{
			Name: "Check audit has correct SecurityContext as per given value",
			Covers: []string{
				".Values.audit.securityContext",
				".Values.enableRuntimeDefaultSeccompProfile",
			},

			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					enableRuntimeDefaultSeccompProfileVal, _ := checker.RenderValue[bool](tc, "Values.enableRuntimeDefaultSeccompProfile")

					expected, _ := checker.RenderValue[*corev1.SecurityContext](tc, "Values.audit.securityContext")

					if enableRuntimeDefaultSeccompProfileVal {
						expected.SeccompProfile = &corev1.SeccompProfile{
							Type: corev1.SeccompProfileTypeRuntimeDefault,
						}
					}

					assert.True(tc.T,
						reflect.DeepEqual(expected, podTemplateSpec.Spec.Containers[0].SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						obj.GetName(), obj, expected, podTemplateSpec.Spec.Containers[0].SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check audit Has NodeSelector As Per Given Value",
			Covers: []string{
				".Values.audit.nodeSelector",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					nodeSelectorAddedByValues, _ := checker.RenderValue[map[string]string](tc, ".Values.audit.nodeSelector")

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
			Name: "Check audit Have Tolerations As Per Given Value",
			Covers: []string{
				".Values.audit.tolerations",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.audit.tolerations")

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

			Name: "Check audit.affinity",
			Covers: []string{
				".Values.audit.affinity",
			},
			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					auditAffinityAddedFromValues, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.audit.affinity")

					expectedAffinity := auditAffinityAddedFromValues
					assert.Equal(tc.T,
						expectedAffinity, podTemplateSpec.Spec.Affinity,
						"deployment %s does not have correct affinity: expected: %v, got: %v",
						obj.GetName(), expectedAffinity, podTemplateSpec.Spec.Affinity)

				}),
			},
		},

		{
			Name: "Check audit has correct PodSecurityContext as per given value",
			Covers: []string{
				".Values.audit.podSecurityContext",
			},

			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					podSecurityContextAddedFromValues, _ := checker.RenderValue[*corev1.PodSecurityContext](tc, "Values.audit.podSecurityContext")

					expectedPodSecurityContext := podSecurityContextAddedFromValues

					assert.True(tc.T,
						reflect.DeepEqual(expectedPodSecurityContext, podTemplateSpec.Spec.SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						obj.GetName(), obj, expectedPodSecurityContext, podTemplateSpec.Spec.SecurityContext,
					)
				}),
			},
		},

		// Checker functions for Values.controllerManager

		{
			Name: "Check controllerManager deployment containers have correct exempt namespace args (.Values.controllerManager.exemptNamespaces)",
			Covers: []string{
				".Values.controllerManager.exemptNamespaces",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.GetName() != "gatekeeper-update-namespace-label" {
						return
					}

					assert.Equal(tc.T,
						1, len(deployment.Spec.Template.Spec.Containers),
						"deployment %s does not have correct number of containers, expected: %v got: %v",
						deployment.GetName(), 1, len(deployment.Spec.Template.Spec.Containers),
					)

					if len(deployment.Spec.Template.Spec.Containers) > 0 {
						container := deployment.Spec.Template.Spec.Containers[0]

						exemptNamespaceVal, _ := checker.RenderValue[[]string](tc, ".Values.controllerManager.exemptNamespaces")

						containerArgsVal := container.Args

						args := make(map[string]bool)

						for _, s := range containerArgsVal {
							args[s] = true
						}

						allExist := true

						for _, s := range exemptNamespaceVal {
							if _, ok := args[s]; !ok {
								allExist = false
								break
							}
						}
						assert.True(tc.T, allExist,
							"deployment %s container does not have correct exempt namespaces in container args", deployment.Name)
					}
				}),
			},
		},

		{
			Name: "Check controller-manager deployment containers have correct exemptNamespacePrefixes argument ",
			Covers: []string{
				".Values.controllerManager.exemptNamespacePrefixes",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					exemptNamespacePrefixesVal, _ := checker.RenderValue[[]string](tc, ".Values.controllerManager.exemptNamespacePrefixes")

					if len(exemptNamespacePrefixesVal) == 0 {
						return
					}
					namespacesList := make([]string, len(exemptNamespacePrefixesVal))

					containerArgs := podTemplateSpec.Spec.Containers[0].Args

					for i, ns := range exemptNamespacePrefixesVal {
						namespacesList[i] = fmt.Sprintf("--exempt-namespace-prefix=%s", ns)
					}

					args := make(map[string]bool)

					for _, s := range containerArgs {
						args[s] = true
					}

					allExist := true

					for _, s := range namespacesList {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"container %s of deployment %s does not have correct exemptNamespacePrefixes arg set",
						podTemplateSpec.Spec.Containers[0].Name, obj.GetName())
				}),
			},
		},

		{
			Name: "Check controllerManager Has NodeSelector As Per Given Value",
			Covers: []string{
				".Values.controllerManager.nodeSelector",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					nodeSelectorAddedByValues, _ := checker.RenderValue[map[string]string](tc, ".Values.controllerManager.nodeSelector")

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
				".Values.controllerManager.tolerations",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.controllerManager.tolerations")

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
			Name: "Check gatekeeper-controller-manager-controller deployment has correct hostNetwork (.Values.controllerManager.hostNetwork)",
			Covers: []string{
				".Values.controllerManager.hostNetwork",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					controllerManagerHostNetworkValue, _ := checker.RenderValue[bool](tc, ".Values.controllerManager.hostNetwork")

					expectedArg := controllerManagerHostNetworkValue

					assert.Equal(tc.T,
						expectedArg, podTemplateSpec.Spec.HostNetwork,
						"controllerManager-controller does not have correct HostNetwork set. Expected: %v got: %v",
						expectedArg, podTemplateSpec.Spec.HostNetwork,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager-controller deployment has correct dnsPolicy (.Values.controllerManager.dnsPolicy)",
			Covers: []string{
				".Values.controllerManager.dnsPolicy",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					controllerManagerDnsPolicyValue, _ := checker.RenderValue[corev1.DNSPolicy](tc, ".Values.controllerManager.dnsPolicy")

					expectedArg := controllerManagerDnsPolicyValue

					assert.Equal(tc.T,
						expectedArg, podTemplateSpec.Spec.DNSPolicy,
						"controllerManager-controller does not have correct DNSPolicy set. Expected: %v got: %v",
						expectedArg, podTemplateSpec.Spec.DNSPolicy,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct priorityClassName (.Values.controllerManager.priorityClassName)",
			Covers: []string{
				".Values.controllerManager.priorityClassName",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					PriorityClassNameValue, _ := checker.RenderValue[string](tc, ".Values.controllerManager.priorityClassName")

					expectedArg := PriorityClassNameValue

					assert.Equal(tc.T,
						expectedArg, podTemplateSpec.Spec.PriorityClassName,
						"gatekeeper-controller-manager does not have correct priority class name set. Expected: %v got: %v",
						expectedArg, podTemplateSpec.Spec.PriorityClassName,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-critical-pods resource quota has correct priorityClassName (.Values.controllerManager.priorityClassName)",
			Covers: []string{
				".Values.controllerManager.priorityClassName",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, resourceQuota *corev1.ResourceQuota) {

					if resourceQuota.Name != "gatekeeper-critical-pods" {
						return
					}

					PriorityClassNameValue, _ := checker.RenderValue[string](tc, ".Values.controllerManager.priorityClassName")

					expectedArg := PriorityClassNameValue

					assert.Equal(tc.T,
						expectedArg, resourceQuota.Spec.ScopeSelector.MatchExpressions[0].Values[1],
						"gatekeeper-controller-manager does not have correct priority class name set. Expected: %v got: %v",
						expectedArg, resourceQuota.Spec.ScopeSelector.MatchExpressions[0].Values[1],
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct readiness timeout (.Values.controllerManager.readinessTimeout)",
			Covers: []string{
				".Values.controllerManager.readinessTimeout",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerReadinessTimeoutValue, _ := checker.RenderValue[int](tc, ".Values.controllerManager.readinessTimeout")

						expectedAuditReadinessTimeout := int32(controllerManagerReadinessTimeoutValue)

						assert.Equal(tc.T,
							expectedAuditReadinessTimeout, container.ReadinessProbe.TimeoutSeconds,
							"container %s of obj %s does not have correct controllerManager.readinessTimeout argument, expected: %v, got: %v",
							container.Name, obj.GetName(), expectedAuditReadinessTimeout, container.ReadinessProbe.TimeoutSeconds)
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct liveness timeout (.Values.controllerManager.livenessTimeout)",
			Covers: []string{
				".Values.controllerManager.livenessTimeout",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerLivenessTimeoutValue, _ := checker.RenderValue[int](tc, ".Values.controllerManager.livenessTimeout")

						expectedAuditLivenessTimeout := int32(controllerManagerLivenessTimeoutValue)

						assert.Equal(tc.T,
							expectedAuditLivenessTimeout, container.LivenessProbe.TimeoutSeconds,
							"container %s of obj %s does not have correct controllerManager.readinessTimeout argument, expected: %v, got: %v",
							container.Name, obj.GetName(), expectedAuditLivenessTimeout, container.LivenessProbe.TimeoutSeconds)
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct port in container args and in container port (.Values.controllerManager.port)",
			Covers: []string{
				".Values.controllerManager.port",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerPortValue, ok := checker.RenderValue[int](tc, ".Values.controllerManager.port")
						expectedContainerPortValue := container.Ports[0].ContainerPort

						expectedArg := fmt.Sprintf("--port=%d", controllerManagerPortValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct controllerManager.port argument",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							if controllerManagerPortValue == int(expectedContainerPortValue) {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct containerPort",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct metricsPort in container args and container port (.Values.controllerManager.metricsPort)",
			Covers: []string{
				".Values.controllerManager.metricsPort",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerMetricsPortValue, ok := checker.RenderValue[int](tc, ".Values.controllerManager.metricsPort")
						expectedContainerMetricsPort := container.Ports[1].ContainerPort

						expectedArg := fmt.Sprintf("--prometheus-port=%d", controllerManagerMetricsPortValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct controllerManager.metricsPort argument",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							if controllerManagerMetricsPortValue == int(expectedContainerMetricsPort) {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct healthz containerPort",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct healthPort in container args and container port (.Values.controllerManager.healthPort)",
			Covers: []string{
				".Values.controllerManager.healthPort",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerHealthPortValue, ok := checker.RenderValue[int](tc, ".Values.controllerManager.healthPort")

						expectedLivenessProbePort := container.LivenessProbe.HTTPGet.Port

						expectedReadinessProbePort := container.ReadinessProbe.HTTPGet.Port

						expectedContainerHealthzPort := container.Ports[2].ContainerPort

						expectedArg := fmt.Sprintf("--health-addr=:%d", controllerManagerHealthPortValue)

						if ok {
							found := false

							if controllerManagerHealthPortValue == int(expectedContainerHealthzPort) {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct healthz containerPort",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							if controllerManagerHealthPortValue == expectedLivenessProbePort.IntValue() {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct LivenessProbe Port",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							if controllerManagerHealthPortValue == expectedReadinessProbePort.IntValue() {
								found = true
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct ReadinessProbe Port",
								container.Name, obj.GetName())
						}

						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct controllerManager.healthPort argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct disable-cert-rotation arg set in container args (.Values.controllerManager.disableCertRotation)",
			Covers: []string{
				".Values.controllerManager.disableCertRotation",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerDisableCertRotationValue, ok := checker.RenderValue[bool](tc, ".Values.controllerManager.disableCertRotation")

						expectedArg := fmt.Sprintf("--disable-cert-rotation=%t", controllerManagerDisableCertRotationValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct controllerManagerDisableCertRotation argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct controllerManagerTlsMinVersion arg in container args (.Values.controllerManager.tlsMinVersion)",
			Covers: []string{
				".Values.controllerManager.tlsMinVersion",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerTlsMinVersionValue, ok := checker.RenderValue[int](tc, ".Values.controllerManager.tlsMinVersion")

						expectedArg := fmt.Sprintf("--tls-min-version=%d", controllerManagerTlsMinVersionValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct controllerManagerTlsMinVersion argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{

			Name: "Check controllerManager.affinity",
			Covers: []string{
				".Values.controllerManager.affinity",
			},
			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}
					spec := podTemplateSpec.Spec

					auditAffinityAddedFromValues, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.controllerManager.affinity")

					expectedAffinity := auditAffinityAddedFromValues
					assert.Equal(tc.T,
						expectedAffinity, spec.Affinity,
						"job %s does not have correct affinity: expected: %v, got: %v",
						obj.GetName(), expectedAffinity, spec.Affinity)
				}),
			},
		},

		{
			Name: "Check controller-manager has correct SecurityContext as per given value",
			Covers: []string{
				".Values.controllerManager.securityContext",
			},

			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					enableRuntimeDefaultSeccompProfileVal, _ := checker.RenderValue[bool](tc, "Values.enableRuntimeDefaultSeccompProfile")

					expected, _ := checker.RenderValue[*corev1.SecurityContext](tc, "Values.controllerManager.securityContext")

					if enableRuntimeDefaultSeccompProfileVal {
						expected.SeccompProfile = &corev1.SeccompProfile{
							Type: corev1.SeccompProfileTypeRuntimeDefault,
						}
					}

					assert.True(tc.T,
						reflect.DeepEqual(expected, podTemplateSpec.Spec.Containers[0].SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						obj.GetName(), obj, expected, podTemplateSpec.Spec.Containers[0].SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check controllerManager has correct PodSecurityContext as per given value",
			Covers: []string{
				".Values.controllerManager.podSecurityContext",
			},

			Checks: test.Checks{

				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					podSecurityContextAddedFromValues, _ := checker.RenderValue[*corev1.PodSecurityContext](tc, "Values.controllerManager.podSecurityContext")

					expectedPodSecurityContext := podSecurityContextAddedFromValues

					assert.True(tc.T,
						reflect.DeepEqual(expectedPodSecurityContext, podTemplateSpec.Spec.SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						obj.GetName(), obj, expectedPodSecurityContext, podTemplateSpec.Spec.SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check gatekeeper-controllerManager-controller deployment has correct logFile (.Values.controllerManager.logFile)",
			Covers: []string{
				".Values.controllerManager.logFile",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerLogFileVal, ok := checker.RenderValue[string](tc, ".Values.controllerManager.logFile")

						expectedArg := fmt.Sprintf("--log-file=%s", controllerManagerLogFileVal)
						if len(controllerManagerLogFileVal) > 0 {
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct controllerManager.logFile argument",
									container.Name, obj.GetName())
							}
						}
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controllerManager-controller deployment has correct clientCertName (.Values.controllerManager.clientCertName)",
			Covers: []string{
				".Values.controllerManager.clientCertName",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						controllerManagerClientCertNameVal, ok := checker.RenderValue[string](tc, ".Values.controllerManager.clientCertName")

						expectedArg := fmt.Sprintf("--client-cert-name=%s", controllerManagerClientCertNameVal)
						if len(controllerManagerClientCertNameVal) > 0 {
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct controllerManager.clientCertName argument",
									container.Name, obj.GetName())
							}
						}
					}
				}),
			},
		},

		{
			Name: "Check controllerManager.networkPolicy.enabled",
			Covers: []string{
				".Values.controllerManager.networkPolicy.enabled",
			},

			Checks: test.Checks{
				checker.OnResources(func(tc *checker.TestContext, networkPolicy []*networkingv1.NetworkPolicy) {

					enableNetworkPolicyVal, _ := checker.RenderValue[bool](tc, ".Values.controllerManager.networkPolicy.enabled")

					if enableNetworkPolicyVal {
						found := false
						for _, np := range networkPolicy {
							if np.Name == "gatekeeper-controller-manager" {
								found = true
							}
						}

						assert.True(tc.T, found,
							"Incorrect controllerManager.networkPolicy configuration")
					}

				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager deployment has correct logLevel set (.Values.logLevel)",
			Covers: []string{
				".Values.logLevel",
				".Values.controllerManager.logLevel",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						logLevelValue, ok := checker.RenderValue[string](tc, ".Values.logLevel")
						controllerManagerLogLevelVal, _ := checker.RenderValue[string](tc, ".Values.controllerManager.logLevel")

						if len(controllerManagerLogLevelVal) > 0 {
							expectedArg := fmt.Sprintf("--log-level=%s", controllerManagerLogLevelVal)
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct logLevel argument",
									container.Name, obj.GetName())
							}
						} else {
							expectedArg := fmt.Sprintf("--log-level=%s", logLevelValue)
							if ok {
								found := false

								for _, arg := range container.Args {
									if arg == expectedArg {
										found = true
									}
								}

								assert.True(tc.T, found,
									"container %s of obj %s does not have correct logLevel argument",
									container.Name, obj.GetName())
							}
						}
					}
				}),
			},
		},

		// For .Values.crds
		{

			Name: "Check crds.affinity",
			Covers: []string{
				".Values.crds.affinity",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-crds-hook" {
						return
					}
					container := job.Spec.Template.Spec

					auditAffinityAddedFromValues, _ := checker.RenderValue[*corev1.Affinity](tc, ".Values.crds.affinity")

					expectedAffinity := auditAffinityAddedFromValues
					assert.Equal(tc.T,
						expectedAffinity, container.Affinity,
						"job %s does not have correct affinity: expected: %v, got: %v",
						job.Name, expectedAffinity, container.Affinity)

				}),
			},
		},

		{
			Name: "Check crds has correct SecurityContext as per given value",
			Covers: []string{
				".Values.crds.securityContext",
			},

			Checks: test.Checks{

				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-crds-hook" {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]

					expected, _ := checker.RenderValue[*corev1.SecurityContext](tc, "Values.crds.securityContext")
					enableRuntimeDefaultSeccompProfileVal, _ := checker.RenderValue[bool](tc, "Values.enableRuntimeDefaultSeccompProfile")

					if enableRuntimeDefaultSeccompProfileVal {
						expected.SeccompProfile = &corev1.SeccompProfile{
							Type: corev1.SeccompProfileTypeRuntimeDefault,
						}
					}

					assert.True(tc.T,
						reflect.DeepEqual(expected, container.SecurityContext),
						"workload %s (type: %T) does not have correct securityContext, expected: %v got: %v",
						job.Name, job, expected, container.SecurityContext,
					)
				}),
			},
		},

		{
			Name: "Check crds resources",
			Covers: []string{
				".Values.crds.resources",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-crds-hook" {
						return
					}

					container := job.Spec.Template.Spec

					ok := assert.Equal(tc.T, 1, len(container.Containers),
						"deployment %s does not have correct number of container: expected: %d, got: %d",
						job.Name, 1, len(container.Containers))

					if !ok {
						return
					}

					expectedResourceReq, _ := checker.RenderValue[corev1.ResourceRequirements](tc, ".Values.crds.resources")

					assert.Equal(tc.T,
						expectedResourceReq, container.Containers[0].Resources,
						"container %s of deployment %s does not have correct resources constraint: expected: %v, got: %v",
						container.Containers[0].Name, job.Name, expectedResourceReq, container.Containers[0].Resources)

				}),
			},
		},

		// For Values.pdb

		{
			Name: "Check controller manager minAvailable pdb",
			Covers: []string{
				".Values.pdb.controllerManager.minAvailable",
			},
			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, policy *policyv1.PodDisruptionBudget) {

					if policy.Name != "gatekeeper-controller-manager" {
						return
					}

					expectedPdbValue, _ := checker.RenderValue[int](tc, ".Values.pdb.controllerManager.minAvailable")

					assert.Equal(tc.T,
						expectedPdbValue, policy.Spec.MinAvailable,
						"policy %s does not have correct minAvailable value set for pdb: %v, got: %v",
						policy.Name, expectedPdbValue, policy.Spec.MinAvailable)
				}),
			},
		},
		{

			Name: "PSPs Are Created And Referenced As Per .Values.global.cattle.psp.enabled field",
			Covers: []string{
				".Values.global.cattle.psp.enabled",
			},
			Checks: common.EnsurePSPsExist(1),
		},

		{
			Name: "Check gatekeeper-audit-controller deployment has correct externalCertInjection Args (.Values.externalCertInjection.enabled)",
			Covers: []string{
				".Values.externalCertInjection.enabled",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						externalCertInjectionValue, ok := checker.RenderValue[int](tc, ".Values.externalCertInjection.enabled")

						expectedArg := fmt.Sprintf("--disable-cert-rotation=%d", externalCertInjectionValue)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct externalCertInjection argument",
								container.Name, obj.GetName())
						}

					}
				}),
			},
		},

		{
			Name: "Check gatekeeper images and systemDefaultRegistry value",
			Covers: []string{
				".Values.images.gatekeeper.repository",
				".Values.images.gatekeeper.tag",
				".Values.global.cattle.systemDefaultRegistry",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.Name != "gatekeeper-audit" {
						return
					}

					ok := assert.Equal(tc.T, 1, len(deployment.Spec.Template.Spec.Containers),
						"deployment %s does not have correct number of containers: expected: %d, got: %d",
						deployment.Name, 1, len(deployment.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := deployment.Spec.Template.Spec.Containers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					gatekeeperRepo, _ := checker.RenderValue[string](tc, ".Values.images.gatekeeper.repository")
					gatekeeperTag, _ := checker.RenderValue[string](tc, ".Values.images.gatekeeper.tag")

					containerImage := gatekeeperRepo + ":" + gatekeeperTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of deployement %s does not have correct image: expected: %v got: %v",
						container.Name, deployment.Name, expectedContainerImage, container.Image)
				}),
			},
		},

		{
			Name: "Check gatekeepercrd images value",
			Covers: []string{
				".Values.images.gatekeepercrd.repository",
				".Values.images.gatekeepercrd.tag",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-audit" {
						return
					}

					ok := assert.Equal(tc.T, 1, len(job.Spec.Template.Spec.Containers),
						"job %s does not have correct number of containers: expected: %d, got: %d",
						job.Name, 1, len(job.Spec.Template.Spec.Containers))
					if !ok {
						return
					}

					container := job.Spec.Template.Spec.Containers[0]
					systemDefaultRegistry := common.GetSystemDefaultRegistry(tc)

					gatekeeperRepo, _ := checker.RenderValue[string](tc, ".Values.images.gatekeepercrd.repository")
					gatekeeperTag, _ := checker.RenderValue[string](tc, ".Values.images.gatekeepercrd.tag")

					containerImage := gatekeeperRepo + ":" + gatekeeperTag

					expectedContainerImage := systemDefaultRegistry + containerImage
					assert.Equal(tc.T,
						expectedContainerImage, container.Image,
						"container %s of deployement %s does not have correct image: expected: %v got: %v",
						container.Name, job.Name, expectedContainerImage, container.Image)
				}),
			},
		},

		{
			Name: "Check that audit-controller deployment containers have correct imagePullPolicy",
			Covers: []string{
				".Values.images.pullPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.Name != "gatekeeper-audit" {
						return
					}

					expectedImagePullPolicy, exists := checker.RenderValue[corev1.PullPolicy](tc, ".Values.images.pullPolicy")

					if exists {
						for _, container := range deployment.Spec.Template.Spec.Containers {

							assert.Equal(tc.T,
								expectedImagePullPolicy, container.ImagePullPolicy,
								"container %s of deployment %s does not have correct imagePullPolicy: expected: %v got: %v",
								container.Name, deployment.Name, expectedImagePullPolicy, container.ImagePullPolicy)
						}
					}
				}),
			},
		},

		{
			Name: "Check that audit controller job has correct imagePullSecrets",
			Covers: []string{
				".Values.images.pullSecrets",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.Name != "gatekeeper-audit" {
						return
					}

					expectedImagePullSecrets, _ := checker.RenderValue[[]corev1.LocalObjectReference](tc, ".Values.images.pullSecrets")

					if len(expectedImagePullSecrets) == 0 {
						expectedImagePullSecrets = nil
					}

					assert.Equal(tc.T,
						expectedImagePullSecrets, deployment.Spec.Template.Spec.ImagePullSecrets,
						"deployment %s does not have correct image: expected: %v got: %v",
						deployment.Name, expectedImagePullSecrets, deployment.Spec.Template.Spec.ImagePullSecrets)
				}),
			},
		},

		{
			Name: "Check controllerManager deployment has correct annotations (.Values.podAnnotations)",
			Covers: []string{
				".Values.podAnnotations",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.GetName() != "gatekeeper-controller-manager" {
						return
					}

					expectedPodAnnotations, _ := checker.RenderValue[map[string]string](tc, ".Values.podAnnotations")

					deployementAnnotationVal := deployment.Spec.Template.Annotations

					args := make(map[string]bool)

					for _, s := range deployementAnnotationVal {
						args[s] = true
					}

					allExist := true

					for _, s := range expectedPodAnnotations {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"deployment %s container does not have correct Annotations", deployment.Name)
				}),
			},
		},

		{
			Name: "Check controllerManager deployment has correct labels (.Values.podLabels)",
			Covers: []string{
				".Values.podLabels",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, deployment *appsv1.Deployment) {

					if deployment.GetName() != "gatekeeper-controller-manager" {
						return
					}

					expectedPodLabels, _ := checker.RenderValue[map[string]string](tc, ".Values.podLabels")

					deployementLabelsVal := deployment.Spec.Template.Labels

					args := make(map[string]bool)

					for _, s := range deployementLabelsVal {
						args[s] = true
					}

					allExist := true

					for _, s := range expectedPodLabels {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"deployment %s container does not have correct labels", deployment.Name)
				}),
			},
		},

		{
			Name: "Check that update-namespace-label job volume has correct secret name",
			Covers: []string{
				".Values.externalCertInjection.secretName",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					probeWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.postInstall.probeWebhook.enabled")

					if !probeWebhookEnabled {
						return
					}

					expectedexternalCertInjectionSecretName, _ := checker.RenderValue[string](tc, ".Values.externalCertInjection.secretName")
					volumes := job.Spec.Template.Spec.Volumes[0]
					assert.Equal(tc.T,
						expectedexternalCertInjectionSecretName, volumes.Secret.SecretName,
						"job %s volume does not have correct secret: expected: %v got: %v",
						job.Name, expectedexternalCertInjectionSecretName, volumes.Secret.SecretName)
				}),
			},
		},

		{
			Name: "Check Values.nameOverride",
			Covers: []string{
				".Values.nameOverride",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, psp *policyv1.PodSecurityPolicy) {

					if psp.Name != "gatekeeper-admin" {
						return
					}

					nameOverrideVal, ok := checker.RenderValue[string](tc, ".Values.nameOverride")

					expectedLabel := fmt.Sprintf("app: %s", nameOverrideVal)

					if ok {
						found := false

						for _, arg := range psp.ObjectMeta.Labels {
							if arg == expectedLabel {
								found = true
							}
						}

						assert.True(tc.T, found,
							"Policy %s does not have correct labels",
							psp.Name)
					}
				}),
			},
		},

		{
			Name: "Check upgradeCRDs.enabled",
			Covers: []string{
				".Values.upgradeCRDs.enabled",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, clusterRole *rbacv1.ClusterRole) {

					upgradeCRDsVal, _ := checker.RenderValue[bool](tc, ".Values.upgradeCRDs.enabled")

					if upgradeCRDsVal {
						found := false

						if clusterRole.Name == "gatekeeper-admin-upgrade-crds" {
							found = true
						}

						assert.True(tc.T, found,
							"Incorrect upgradeCRDs")
					}

				}),
			},
		},

		{
			Name: "Check rbac.create",
			Covers: []string{
				".Values.rbac.create",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, clusterRole *rbacv1.ClusterRole) {

					rbacCreateVal, _ := checker.RenderValue[bool](tc, ".Values.rbac.create")

					if rbacCreateVal {
						found := false

						if clusterRole.Name == "gatekeeper-manager-role" {
							found = true
						}

						assert.True(tc.T, found,
							"Incorrect rbac configuration")
					}
				}),
			},
		},

		// For Validating Webhooks

		{
			Name: "Check disableValidatingWebhook",
			Covers: []string{
				".Values.disableValidatingWebhook",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

					disableValidatingWebhookVal, _ := checker.RenderValue[bool](tc, ".Values.disableValidatingWebhook")

					if !disableValidatingWebhookVal {
						found := false
						if validatingWebhook.Webhooks[0].Name == "gatekeeper-validating-webhook-configuration" {
							found = true
						}

						assert.True(tc.T, found,
							"Webhook %s has incorrect disableValidatingWebhook configuration", validatingWebhook.Webhooks[0].Name)
					}
				}),
			},
		},

		// {
		// 	Name: "Check validatingWebhookObjectSelector",
		// 	Covers: []string{
		// 		".Values.validatingWebhookObjectSelector",
		// 	},

		// 	Checks: test.Checks{
		// 		checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

		// 			disableValidatingWebhookVal, _ := checker.RenderValue[bool](tc, ".Values.disableValidatingWebhook")

		// 			if disableValidatingWebhookVal {
		// 				return
		// 			}

		// 			webhookSpec := validatingWebhook.Webhooks[0]
		// 			validatingWebhookObjectSelectorVal, _ := checker.RenderValue[*metav1.LabelSelector](tc, ".Values.validatingWebhookObjectSelector")
		// 			expectedObjectSelectorVal := webhookSpec.ObjectSelector

		// 			for _, ls := range expectedObjectSelectorVal {
		// 				if metav1.LabelSelectorEquals(&selector, &ls) {
		// 					fmt.Println("Found matching label selector:", ls)
		// 					break
		// 				}
		// 			}

		// 		}),
		// 	},
		// },

		{
			Name: "Check validatingWebhookTimeoutSeconds",
			Covers: []string{
				".Values.validatingWebhookTimeoutSeconds",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

					validatingWebhookTimeoutSecondsVal, _ := checker.RenderValue[int32](tc, ".Values.validatingWebhookTimeoutSeconds")
					webhookSpec := validatingWebhook.Webhooks[0]
					assert.Equal(tc.T, validatingWebhookTimeoutSecondsVal, webhookSpec.TimeoutSeconds,
						"Webhook %s has incorrect timeoutseconds. Expected: %v, got: %v",
						webhookSpec.Name, validatingWebhookTimeoutSecondsVal, webhookSpec.TimeoutSeconds)

				}),
			},
		},

		{
			Name: "Check validatingWebhookFailurePolicy",
			Covers: []string{
				".Values.validatingWebhookFailurePolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

					validatingWebhookFailurePolicyVal, _ := checker.RenderValue[admissionregistration.FailurePolicyType](tc, ".Values.validatingWebhookFailurePolicy")
					webhookSpec := validatingWebhook.Webhooks[0]
					assert.Equal(tc.T, validatingWebhookFailurePolicyVal, webhookSpec.FailurePolicy,
						"Webhook %s has incorrect timeoutseconds. Expected: %v, got: %v",
						webhookSpec.Name, validatingWebhookFailurePolicyVal, webhookSpec.FailurePolicy)

				}),
			},
		},

		{
			Name: "Check Validating Webhook configuration has correct annotations (.Values.validatingWebhookAnnotations)",
			Covers: []string{
				".Values.validatingWebhookAnnotations",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

					expectedvalidatingWebhookAnnotations, _ := checker.RenderValue[map[string]string](tc, ".Values.validatingWebhookAnnotations")

					webhookAnnotationVal := validatingWebhook.ObjectMeta.Annotations

					args := make(map[string]bool)

					for _, s := range webhookAnnotationVal {
						args[s] = true
					}

					allExist := true

					for _, s := range expectedvalidatingWebhookAnnotations {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"Validating Webhook %s container does not have correct Annotations", validatingWebhook.Name)
				}),
			},
		},

		{
			Name: "Check validatingWebhookCheckIgnoreFailurePolicy",
			Covers: []string{
				".Values.validatingWebhookCheckIgnoreFailurePolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

					validatingWebhookCheckIgnoreFailurePolicyVal, _ := checker.RenderValue[admissionregistration.FailurePolicyType](tc, ".Values.validatingWebhookCheckIgnoreFailurePolicy")
					webhookSpec := validatingWebhook.Webhooks[1]
					assert.Equal(tc.T, validatingWebhookCheckIgnoreFailurePolicyVal, webhookSpec.FailurePolicy,
						"Webhook %s has incorrect timeoutseconds. Expected: %v, got: %v",
						webhookSpec.Name, validatingWebhookCheckIgnoreFailurePolicyVal, webhookSpec.FailurePolicy)

				}),
			},
		},
		{
			Name: "Check enableDeleteOperations",
			Covers: []string{
				".Values.enableDeleteOperations",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, validatingWebhook *admissionregistration.ValidatingWebhookConfiguration) {

					enableDeleteOperationsVal, _ := checker.RenderValue[bool](tc, ".Values.enableDeleteOperations")

					if enableDeleteOperationsVal {
						found := false
						if validatingWebhook.Webhooks[0].Name == "gatekeeper-validating-webhook-configuration" {
							found = true
						}

						assert.True(tc.T, found,
							"Webhook %s has incorrect enableDeleteOperations configuration", validatingWebhook.Webhooks[0].Name)
					}
				}),
			},
		},

		// For mutating webhooks

		{
			Name: "Check gatekeeper-audit-controller deployment container has correct mutatingWebhookName arg (.Values.mutatingWebhookName)",
			Covers: []string{
				".Values.mutatingWebhookName",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-audit" {
						return
					}

					assert.Equal(tc.T,
						1, len(podTemplateSpec.Spec.Containers),
						"obj %s does not have correct number of containers, expected: %v got: %v",
						obj.GetName(), 1, len(podTemplateSpec.Spec.Containers),
					)

					if len(podTemplateSpec.Spec.Containers) > 0 {
						container := podTemplateSpec.Spec.Containers[0]

						mutatingWebhookNameVal, ok := checker.RenderValue[string](tc, ".Values.mutatingWebhookName")

						expectedArg := fmt.Sprintf("--mutating-webhook-configuration-name=%s", mutatingWebhookNameVal)
						if ok {
							found := false

							for _, arg := range container.Args {
								if arg == expectedArg {
									found = true
								}
							}

							assert.True(tc.T, found,
								"container %s of obj %s does not have correct mutatingWebhookName argument",
								container.Name, obj.GetName())
						}
					}
				}),
			},
		},

		{
			Name: "Check mutatingWebhookFailurePolicy",
			Covers: []string{
				".Values.mutatingWebhookFailurePolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, mutatingWebhook *admissionregistration.MutatingWebhookConfiguration) {

					mutatingWebhookFailurePolicyVal, _ := checker.RenderValue[admissionregistration.FailurePolicyType](tc, ".Values.mutatingWebhookFailurePolicy")
					webhookSpec := mutatingWebhook.Webhooks[0]
					assert.Equal(tc.T, mutatingWebhookFailurePolicyVal, webhookSpec.FailurePolicy,
						"Webhook %s has incorrect timeoutseconds. Expected: %v, got: %v",
						webhookSpec.Name, mutatingWebhookFailurePolicyVal, webhookSpec.FailurePolicy)
				}),
			},
		},

		{
			Name: "Check mutatingWebhookReinvocationPolicy",
			Covers: []string{
				".Values.mutatingWebhookReinvocationPolicy",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, mutatingWebhook *admissionregistration.MutatingWebhookConfiguration) {

					mutatingWebhookReinvocationPolicyVal, _ := checker.RenderValue[admissionregistration.ReinvocationPolicyType](tc, ".Values.mutatingWebhookReinvocationPolicy")
					webhookSpec := mutatingWebhook.Webhooks[0]
					assert.Equal(tc.T, mutatingWebhookReinvocationPolicyVal, webhookSpec.ReinvocationPolicy,
						"Webhook %s has incorrect timeoutseconds. Expected: %v, got: %v",
						webhookSpec.Name, mutatingWebhookReinvocationPolicyVal, webhookSpec.ReinvocationPolicy)
				}),
			},
		},
		{
			Name: "Check Validating Webhook configuration has correct annotations (.Values.mutatingWebhookAnnotations)",
			Covers: []string{
				".Values.mutatingWebhookAnnotations",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, mutatingWebhook *admissionregistration.MutatingWebhookConfiguration) {

					expectedMutatingWebhookAnnotations, _ := checker.RenderValue[map[string]string](tc, ".Values.mutatingWebhookAnnotations")

					webhookAnnotationVal := mutatingWebhook.ObjectMeta.Annotations

					args := make(map[string]bool)

					for _, s := range webhookAnnotationVal {
						args[s] = true
					}

					allExist := true

					for _, s := range expectedMutatingWebhookAnnotations {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"Validating Webhook %s container does not have correct Annotations", mutatingWebhook.Name)
				}),
			},
		},
		{
			Name: "Check mutatingWebhookTimeoutSeconds",
			Covers: []string{
				".Values.mutatingWebhookTimeoutSeconds",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, mutatingWebhook *admissionregistration.MutatingWebhookConfiguration) {

					mutatingWebhookTimeoutSecondsVal, _ := checker.RenderValue[int32](tc, ".Values.mutatingWebhookTimeoutSeconds")
					webhookSpec := mutatingWebhook.Webhooks[0]
					assert.Equal(tc.T, mutatingWebhookTimeoutSecondsVal, webhookSpec.TimeoutSeconds,
						"Webhook %s has incorrect timeoutseconds. Expected: %v, got: %v",
						webhookSpec.Name, mutatingWebhookTimeoutSecondsVal, webhookSpec.TimeoutSeconds)

				}),
			},
		},

		{
			Name: "Check preUninstall.deleteWebhookConfigurations.enabled",
			Covers: []string{
				".Values.preUninstall.deleteWebhookConfigurations.enabled",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					disableValidatingWebhookEnabled, _ := checker.RenderValue[bool](tc, ".Values.disableValidatingWebhook")
					disableMutationEnabled, _ := checker.RenderValue[bool](tc, ".Values.disableMutation")
					deleteWebhookConfigurationsEnabled, _ := checker.RenderValue[bool](tc, ".Values.preUninstall.deleteWebhookConfigurations.enabled")

					if (!disableValidatingWebhookEnabled || !disableMutationEnabled) && deleteWebhookConfigurationsEnabled {
						found := false
						if job.Name == "gatekeeper-delete-webhook-configs" {
							fmt.Println("job found")

							found = true
						}

						assert.True(tc.T, found,
							"Incorrect preUninstall deleteWebhook configuration")
					}
				}),
			},
		},

		{
			Name: "Check controller-manager deployment containers have correct exemptNamespaceSuffixes argument ",
			Covers: []string{
				".Values.controllerManager.exemptNamespaceSuffixes",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					exemptNamespaceSuffixesVal, _ := checker.RenderValue[[]string](tc, ".Values.controllerManager.exemptNamespaceSuffixes")

					if len(exemptNamespaceSuffixesVal) == 0 {
						return
					}
					namespacesList := make([]string, len(exemptNamespaceSuffixesVal))

					containerArgs := podTemplateSpec.Spec.Containers[0].Args

					for i, ns := range exemptNamespaceSuffixesVal {
						namespacesList[i] = fmt.Sprintf("--exempt-namespace-suffix=%s", ns)
					}

					args := make(map[string]bool)

					for _, s := range containerArgs {
						args[s] = true
					}

					allExist := true

					for _, s := range namespacesList {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"container %s of deployment %s does not have correct exemptNamespaceSuffixes arg set",
						podTemplateSpec.Spec.Containers[0].Name, obj.GetName())
				}),
			},
		},

		{
			Name: "Check controller-manager deployment containers have correct disabledBuiltins arguments ",
			Covers: []string{
				".Values.disabledBuiltins",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if obj.GetName() != "gatekeeper-controller-manager" {
						return
					}

					disabledBuiltinsVal, _ := checker.RenderValue[[]string](tc, ".Values.disabledBuiltins")

					builtinsList := make([]string, len(disabledBuiltinsVal))

					containerArgs := podTemplateSpec.Spec.Containers[0].Args

					for i, disabledBuiltinsList := range disabledBuiltinsVal {
						builtinsList[i] = fmt.Sprintf("--disable-opa-builtin=%s", disabledBuiltinsList)
					}

					args := make(map[string]bool)

					for _, s := range containerArgs {
						args[s] = true
					}

					allExist := true

					for _, s := range builtinsList {
						if _, ok := args[s]; !ok {
							allExist = false
							break
						}
					}
					assert.True(tc.T, allExist,
						"container %s of deployment %s does not have correct disabledBuiltins arg set",
						podTemplateSpec.Spec.Containers[0].Name, obj.GetName())
				}),
			},
		},
		{
			Name: "Check extrarules for gatekeeper-manager-role",
			Covers: []string{
				".Values.controllerManager.extraRules",
				".Values.rbac.create",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, role *rbacv1.ClusterRole) {

					if !checker.Select("gatekeeper-manager-role", DefaultNamespace, role) {
						return
					}

					expectedExtraRules, _ := checker.RenderValue[[]rbac.PolicyRule](tc, ".Values.controllerManager.extraRules")

					if len(expectedExtraRules) > 0 {
						ok := assert.GreaterOrEqual(tc.T, len(role.Rules), len(expectedExtraRules),
							"role gatekeeper-manager-role has less number of rules than extraRules, numRules:%d, numExtraRules:%d",
							len(role.Rules), len(expectedExtraRules))
						if !ok {
							return
						}
						// assuming that extraroles is appended at last
						extraRulesInRole := role.Rules[len(role.Rules)-len(expectedExtraRules):]

						assert.True(tc.T, reflect.DeepEqual(extraRulesInRole, expectedExtraRules),
							"role gatekeeper-manager-role does not have correct extrarules, totalRules:%v, expectedExtraRules:%v",
							role.Rules, expectedExtraRules)
					}
				}),
			},
		},

		{
			Name: "Check extrarules for gatekeeper-update-namespace-label",
			Covers: []string{
				".Values.upgradeCRDs.extraRules",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, clusterRole *rbacv1.ClusterRole) {

					if !checker.Select("gatekeeper-admin-upgrade-crds", DefaultNamespace, clusterRole) {
						return
					}

					expectedExtraRules, _ := checker.RenderValue[[]rbac.PolicyRule](tc, ".Values.upgradeCRDs.extraRules")

					if len(expectedExtraRules) > 0 {
						ok := assert.GreaterOrEqual(tc.T, len(clusterRole.Rules), len(expectedExtraRules),
							"role gatekeeper-update-namespace-label has less number of rules than extraRules, numRules:%d, numExtraRules:%d",
							len(clusterRole.Rules), len(expectedExtraRules))
						if !ok {
							return
						}
						// assuming that extraroles is appended at last
						extraRulesInRole := clusterRole.Rules[len(clusterRole.Rules)-len(expectedExtraRules):]

						assert.True(tc.T, reflect.DeepEqual(extraRulesInRole, expectedExtraRules),
							"role gatekeeper-update-namespace-label does not have correct extrarules, totalRules:%v, expectedExtraRules:%v",
							clusterRole.Rules, expectedExtraRules)
					}
				}),
			},
		},

		{
			Name: "Check extrarules for gatekeeper-update-namespace-label",
			Covers: []string{
				".Values.preUninstall.deleteWebhookConfigurations.extraRules",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, clusterRole *rbacv1.ClusterRole) {

					if !checker.Select("gatekeeper-delete-webhook-configs", DefaultNamespace, clusterRole) {
						return
					}

					expectedExtraRules, _ := checker.RenderValue[[]rbac.PolicyRule](tc, ".Values.preUninstall.deleteWebhookConfigurations.extraRules")

					if len(expectedExtraRules) > 0 {
						ok := assert.GreaterOrEqual(tc.T, len(clusterRole.Rules), len(expectedExtraRules),
							"role gatekeeper-update-namespace-label has less number of rules than extraRules, numRules:%d, numExtraRules:%d",
							len(clusterRole.Rules), len(expectedExtraRules))
						if !ok {
							return
						}
						// assuming that extraroles is appended at last
						extraRulesInRole := clusterRole.Rules[len(clusterRole.Rules)-len(expectedExtraRules):]

						assert.True(tc.T, reflect.DeepEqual(extraRulesInRole, expectedExtraRules),
							"role gatekeeper-update-namespace-label does not have correct extrarules, totalRules:%v, expectedExtraRules:%v",
							clusterRole.Rules, expectedExtraRules)
					}
				}),
			},
		},

		{
			Name: "Check gatekeeper-controller-manager has correct topology spread constraints",
			Covers: []string{
				".Values.controllerManager.topologySpreadConstraints",
			},

			Checks: test.Checks{
				checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

					if !checker.Select("gatekeeper-controller-manager", DefaultNamespace, obj) {
						return
					}

					topologySpreadConstraints, ok := checker.RenderValue[*corev1.TopologySpreadConstraint](tc, ".Values.controllerManager.topologySpreadConstraints")
					if ok && topologySpreadConstraints != nil {
						assert.Equal(tc.T, topologySpreadConstraints, podTemplateSpec.Spec.TopologySpreadConstraints)
					}
				}),
			},
		},
		{
			Name: "Check mutatingWebhookExemptNamespacesLabels for mutatingWebhook",
			Covers: []string{
				".Values.mutatingWebhookExemptNamespacesLabels",
				".Values.mutatingWebhookName",
				".Values.disableMutation",
			},

			Checks: test.Checks{
				checker.OnResources(func(tc *checker.TestContext, mutatingConfigs []*adminReg.MutatingWebhookConfiguration) {

					disableMutation, _ := checker.RenderValue[bool](tc, ".Values.disableMutation")
					if !disableMutation {
						assert.Equal(tc.T, 1, len(mutatingConfigs), "there should be just one mutating webhook configuration present, found:%d", len(mutatingConfigs))
					} else {
						assert.Equal(tc.T, 0, len(mutatingConfigs), "there should be no mutating webhook configuration present")
					}

					if len(mutatingConfigs) > 0 {

						mutatingWebhookName, _ := checker.RenderValue[string](tc, ".Values.mutatingWebhookName")
						if mutatingWebhookName != "" {
							assert.Equal(tc.T, mutatingWebhookName, mutatingConfigs[0].Name, "mutating config webhook name is not same as given in the values,expected:%s, got:%s",
								mutatingWebhookName, mutatingConfigs[0].Name)
						}

						assert.GreaterOrEqual(tc.T, len(mutatingConfigs[0].Webhooks), 1,
							"mutating config should have at least one webhook configured")

						if len(mutatingConfigs[0].Webhooks) > 0 {
							webhook := mutatingConfigs[0].Webhooks[0]

							matchExpressions := webhook.NamespaceSelector.MatchExpressions

							mutatingWebhookExemptNamespacesLabels, _ := checker.RenderValue[map[string][]string](tc, ".Values.mutatingWebhookExemptNamespacesLabels")

							exemptNsLabelsKeyMap := make(map[string]bool, len(mutatingWebhookExemptNamespacesLabels))

							for key := range mutatingWebhookExemptNamespacesLabels {
								exemptNsLabelsKeyMap[key] = false
							}

							for _, matchExpr := range matchExpressions {
								if _, ok := exemptNsLabelsKeyMap[matchExpr.Key]; ok {
									exemptNsLabelsKeyMap[matchExpr.Key] = true
									assert.Equal(tc.T, mutatingWebhookExemptNamespacesLabels[matchExpr.Key],
										matchExpr.Values, `mutating webhook configuration does not have correct value for
									selector matchExpr with key:%s, expected:%v, got %v`, matchExpr.Key,
										mutatingWebhookExemptNamespacesLabels[matchExpr.Key], matchExpr.Values)
								}
							}

							for key, value := range exemptNsLabelsKeyMap {
								assert.True(tc.T, value, "matchExpr for key:%s is not found in mutating webhook configuration", key)
							}
						}
					}

				}),
			},
		},
		{
			Name: "Check validatingWebhookExemptNamespacesLabels for validatingWebhook",
			Covers: []string{
				".Values.validatingWebhookExemptNamespacesLabels",
				".Values.validatingWebhookName",
				".Values.disableValidatingWebhook",
			},

			Checks: test.Checks{
				checker.OnResources(func(tc *checker.TestContext, validatingConfigs []*adminReg.ValidatingWebhookConfiguration) {

					disableValidatingWebhook, _ := checker.RenderValue[bool](tc, ".Values.disableValidatingWebhook")
					if !disableValidatingWebhook {
						assert.Equal(tc.T, 1, len(validatingConfigs), "there should be just one validating webhook configuration present, found:%d", len(validatingConfigs))
					} else {
						assert.Equal(tc.T, 0, len(validatingConfigs), "there should be no validating webhook configuration present")
					}

					if len(validatingConfigs) > 0 {

						validatingWebhookName, _ := checker.RenderValue[string](tc, ".Values.validatingWebhookName")
						if validatingWebhookName != "" {
							assert.Equal(tc.T, validatingWebhookName, validatingConfigs[0].Name, "validating config webhook name is not same as given in the values,expected:%s, got:%s",
								validatingWebhookName, validatingConfigs[0].Name)
						}

						assert.GreaterOrEqual(tc.T, len(validatingConfigs[0].Webhooks), 1,
							"validating config should have at least one webhook configured")

						if len(validatingConfigs[0].Webhooks) > 0 {
							webhook := validatingConfigs[0].Webhooks[0]

							matchExpressions := webhook.NamespaceSelector.MatchExpressions

							validatingWebhookExemptNamespacesLabels, _ := checker.RenderValue[map[string][]string](tc, ".Values.validatingWebhookExemptNamespacesLabels")

							exemptNsLabelsKeyMap := make(map[string]bool, len(validatingWebhookExemptNamespacesLabels))

							for key := range validatingWebhookExemptNamespacesLabels {
								exemptNsLabelsKeyMap[key] = false
							}

							for _, matchExpr := range matchExpressions {
								if _, ok := exemptNsLabelsKeyMap[matchExpr.Key]; ok {
									exemptNsLabelsKeyMap[matchExpr.Key] = true
									assert.Equal(tc.T, validatingWebhookExemptNamespacesLabels[matchExpr.Key],
										matchExpr.Values, `validating webhook configuration does not have correct value for
									selector matchExpr with key:%s, expected:%v, got %v`, matchExpr.Key,
										validatingWebhookExemptNamespacesLabels[matchExpr.Key], matchExpr.Values)
								}
							}

							for key, value := range exemptNsLabelsKeyMap {
								assert.True(tc.T, value, "matchExpr for key:%s is not found in validating webhook configuration", key)
							}
						}
					}

				}),
			},
		},
		{
			Name: "Check podCountLimit for gatekeeper-critical-pods resourceQuota",
			Covers: []string{
				".Values.podCountLimit",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, resourceQuota *corev1.ResourceQuota) {

					if !checker.Select("gatekeeper-critical-pods", DefaultNamespace, resourceQuota) {
						return
					}

					podCountLimit, ok := checker.RenderValue[string](tc, ".Values.podCountLimit")
					if ok {
						podCountLimitVal, err := strconv.Atoi(podCountLimit)
						ok := assert.Nil(tc.T, err, "error occured while converting podCountLimit Value to integer, actualValue: %v,err :%v", podCountLimit, err)
						if !ok {
							return
						}
						assert.Equal(tc.T, int64(podCountLimitVal), resourceQuota.Spec.Hard.Pods().Value(),
							"podCountLimit value for resourcequota:%s not matched, expected:%v, got:%v",
							resourceQuota.Name, int64(podCountLimitVal), resourceQuota.Spec.Hard.Pods().Value())

					}
				}),
			},
		},
		{
			Name: "Check extrarules for gatekeeper-update-namespace-label clusterRole",
			Covers: []string{
				".Values.postInstall.labelNamespace.extraRules",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, clusterRole *rbacv1.ClusterRole) {

					if !checker.Select("gatekeeper-update-namespace-label", DefaultNamespace, clusterRole) {
						return
					}

					expectedExtraRules, _ := checker.RenderValue[[]rbacv1.PolicyRule](tc, "Values.postInstall.labelNamespace.extraRules")

					if len(expectedExtraRules) > 0 {
						ok := assert.GreaterOrEqual(tc.T, len(clusterRole.Rules), len(expectedExtraRules),
							"role gatekeeper-manager-role has less number of rules than extraRules, numRules:%d, numExtraRules:%d",
							len(clusterRole.Rules), len(expectedExtraRules))
						if !ok {
							return
						}
						// assuming that extraroles is appended at last
						extraRulesInRole := clusterRole.Rules[len(clusterRole.Rules)-len(expectedExtraRules):]

						assert.Equal(tc.T, extraRulesInRole, expectedExtraRules,
							"gatekeeper-update-namespace-label clusterRole does not have correct extrarules, totalRules:%v, expectedExtraRules:%v",
							clusterRole.Rules, expectedExtraRules)
					}
				}),
			},
		},
		{
			Name: "Check gatekeeper-webhook-service values are correctly rendered",
			Covers: []string{
				".Values.service",
				".Values.service.healthzPort",
				".Values.service.type",
				".Values.service.loadBalancerIP",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, service *corev1.Service) {

					if !checker.Select("gatekeeper-webhook-service", DefaultNamespace, service) {
						return
					}

					serviceValues, _ := checker.RenderValue[map[string]interface{}](tc, ".Values.service")

					healthzPort, healthzPortSet := checker.RenderValue[int32](tc, ".Values.service.healthzPort")
					if serviceValues == nil || !healthzPortSet {

						healthzPortFound := false

						for _, port := range service.Spec.Ports {

							if port.Name == "http-webhook-healthz" {
								healthzPortFound = true
								break
							}
						}
						assert.False(tc.T, healthzPortFound,
							"healthzPort in gatekeeper-webhook-service found even though it was not specified in values.")
					} else {

						healthzPortFound := false

						for _, port := range service.Spec.Ports {

							if port.Name == "http-webhook-healthz" {
								healthzPortFound = true

								assert.Equal(tc.T, healthzPort, port.Port,
									"healthzPort value is not correct, expected:%v, got:%v",
									healthzPort, port.Port)

								break
							}
						}

						assert.True(tc.T, healthzPortFound,
							"healthzPort in gatekeeper-webhook-service not found even though it was specified in values.")
					}

					serviceType, serviceTypeSet := checker.RenderValue[corev1.ServiceType](tc, ".Values.service.type")
					if !serviceTypeSet && len(serviceValues) != 0 {
						assert.Equal(tc.T, corev1.ServiceTypeClusterIP, service.Spec.Type,
							"gatekeeper-webhook-service does not have correct service type, expected:%s, got:%s",
							corev1.ServiceTypeClusterIP, service.Spec.Type)
					} else {
						assert.Equal(tc.T, serviceType, service.Spec.Type,
							"gatekeeper-webhook-service does not have correct service type, expected:%s, got:%s",
							serviceType, service.Spec.Type)
					}

					loadBalancerIP, _ := checker.RenderValue[string](tc, ".Values.service.loadBalancerIP")

					assert.Equal(tc.T, loadBalancerIP, service.Spec.LoadBalancerIP,
						"gatekeeper-webhook-service does not have correct loadBalancerIP, expected:%s, got:%s",
						loadBalancerIP, service.Spec.LoadBalancerIP)

				}),
			},
		},
		{
			Name: "Check crds Have Tolerations As Per Given Value",
			Covers: []string{
				".Values.crds.tolerations",
				".Values.crds",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-crds-hook" {
						return
					}

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.crds.tolerations")

					expectedTolerations := append(defaultTolerations, tolerationsAddedByValues...)
					if len(expectedTolerations) == 0 {
						expectedTolerations = nil
					}

					assert.Equal(tc.T,
						expectedTolerations, job.Spec.Template.Spec.Tolerations,
						"workload %s (type: %T) does not have correct tolerations, expected: %v got: %v",
						job.Name, job, expectedTolerations, job.Spec.Template.Spec.Tolerations,
					)
				}),
			},
		},
		{
			Name: "Check postInstall Have Tolerations As Per Given Value",
			Covers: []string{
				".Values.postInstall.tolerations",
				".Values.postInstall",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-update-namespace-label" {
						return
					}

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.postInstall.tolerations")

					expectedTolerations := append(defaultTolerations, tolerationsAddedByValues...)
					if len(expectedTolerations) == 0 {
						expectedTolerations = nil
					}

					assert.Equal(tc.T,
						expectedTolerations, job.Spec.Template.Spec.Tolerations,
						"workload %s (type: %T) does not have correct tolerations, expected: %v got: %v",
						job.Name, job, expectedTolerations, job.Spec.Template.Spec.Tolerations,
					)
				}),
			},
		},
		{
			Name: "Check preUninstall Have Tolerations As Per Given Value",
			Covers: []string{
				".Values.preUninstall.tolerations",
				".Values.preUninstall",
			},

			Checks: test.Checks{
				checker.PerResource(func(tc *checker.TestContext, job *batchv1.Job) {

					if job.Name != "gatekeeper-delete-webhook-configs" {
						return
					}

					tolerationsAddedByValues, _ := checker.RenderValue[[]corev1.Toleration](tc, ".Values.preUninstall.tolerations")

					expectedTolerations := append(defaultTolerations, tolerationsAddedByValues...)
					if len(expectedTolerations) == 0 {
						expectedTolerations = nil
					}

					assert.Equal(tc.T,
						expectedTolerations, job.Spec.Template.Spec.Tolerations,
						"workload %s (type: %T) does not have correct tolerations, expected: %v got: %v",
						job.Name, job, expectedTolerations, job.Spec.Template.Spec.Tolerations,
					)
				}),
			},
		},
		{
			Name: "Check validatingWebhookCustomRules for validatingwebhook",
			Covers: []string{
				".Values.validatingWebhookCustomRules",
			},

			Checks: test.Checks{
				checker.OnResources(func(tc *checker.TestContext, validatingWebhookConfigs []*adminReg.ValidatingWebhookConfiguration) {

					disableValidating, _ := checker.RenderValue[bool](tc, ".Values.disableValidatingWebhook")
					if !disableValidating {
						assert.Equal(tc.T, 1, len(validatingWebhookConfigs), "there should be just one validating webhook configuration present, found:%d", len(validatingWebhookConfigs))
					} else {
						assert.Equal(tc.T, 0, len(validatingWebhookConfigs), "there should be no validating webhook configuration present")
					}

					if len(validatingWebhookConfigs) > 0 {

						assert.GreaterOrEqual(tc.T, len(validatingWebhookConfigs[0].Webhooks), 1,
							"mutating config should have at least one webhook configured")

						validatingWebhookName, _ := checker.RenderValue[string](tc, ".Values.validatingWebhookName")
						if validatingWebhookName != "" {
							assert.Equal(tc.T, validatingWebhookName, validatingWebhookConfigs[0].Name, "validating  config webhook name is not same as given in the values,expected:%s, got:%s",
								validatingWebhookName, validatingWebhookConfigs[0].Name)
						}

						if len(validatingWebhookConfigs[0].Webhooks) > 0 {

							webhook := validatingWebhookConfigs[0].Webhooks[0]

							expectedCustomRules, _ := checker.RenderValue[[]adminReg.RuleWithOperations](tc, ".Values.validatingWebhookCustomRules")

							if len(expectedCustomRules) > 0 {

								ok := assert.GreaterOrEqual(tc.T, len(webhook.Rules), len(expectedCustomRules),
									"role gatekeeper-manager-role has less number of rules than extraRules, numRules:%d, numExtraRules:%d",
									len(webhook.Rules), len(expectedCustomRules))
								if !ok {
									return
								}

								// assuming that extraroles is appended at last
								extraRulesInRole := webhook.Rules[:len(expectedCustomRules)]

								assert.Equal(tc.T, extraRulesInRole, expectedCustomRules,
									"role gatekeeper-manager-role does not have correct extrarules, totalRules:%v, expectedExtraRules:%v",
									webhook.Rules, expectedCustomRules)
							}
						}
					}

				}),
			},
		},
		{
			Name: "Check mutatingWebhookCustomRules for mutatingwebhook",
			Covers: []string{
				".Values.mutatingWebhookCustomRules",
			},

			Checks: test.Checks{
				checker.OnResources(func(tc *checker.TestContext, mutatingWebhookConfigs []*adminReg.MutatingWebhookConfiguration) {

					disableMutation, _ := checker.RenderValue[bool](tc, ".Values.disableMutation")
					if !disableMutation {
						assert.Equal(tc.T, 1, len(mutatingWebhookConfigs), "there should be just one mutating webhook configuration present, found:%d", len(mutatingWebhookConfigs))
					} else {
						assert.Equal(tc.T, 0, len(mutatingWebhookConfigs), "there should be no mutating webhook configuration present")
					}

					if len(mutatingWebhookConfigs) > 0 {

						assert.GreaterOrEqual(tc.T, len(mutatingWebhookConfigs[0].Webhooks), 1,
							"mutating config should have at least one webhook configured")

						mutatingWebhookName, _ := checker.RenderValue[string](tc, ".Values.mutatingWebhookName")
						if mutatingWebhookName != "" {
							assert.Equal(tc.T, mutatingWebhookName, mutatingWebhookConfigs[0].Name, "mutating  config webhook name is not same as given in the values,expected:%s, got:%s",
								mutatingWebhookName, mutatingWebhookConfigs[0].Name)
						}

						if len(mutatingWebhookConfigs[0].Webhooks) > 0 {

							webhook := mutatingWebhookConfigs[0].Webhooks[0]

							expectedCustomRules, _ := checker.RenderValue[[]adminReg.RuleWithOperations](tc, ".Values.mutatingWebhookCustomRules")

							if len(expectedCustomRules) > 0 {

								ok := assert.GreaterOrEqual(tc.T, len(webhook.Rules), len(expectedCustomRules),
									"role gatekeeper-manager-role has less number of rules than extraRules, numRules:%d, numExtraRules:%d",
									len(webhook.Rules), len(expectedCustomRules))
								if !ok {
									return
								}

								// assuming that extraroles is appended at last
								extraRulesInRole := webhook.Rules[:len(expectedCustomRules)]

								assert.Equal(tc.T, extraRulesInRole, expectedCustomRules,
									"role gatekeeper-manager-role does not have correct extrarules, totalRules:%v, expectedExtraRules:%v",
									webhook.Rules, expectedCustomRules)
							}
						}
					}

				}),
			},
		},
	},
}
