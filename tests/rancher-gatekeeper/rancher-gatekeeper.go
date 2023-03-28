package rancher_gatekeeper

import (
	"github.com/aiyengar2/hull/pkg/chart"
	"github.com/rancher/hull/pkg/chart"
	"github.com/rancher/hull/pkg/test"
	"github.com/rancher/hull/pkg/utils"
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
				SetValue(
					"replicas", "2",
				),
		},
		{
			Name: "Set .Values.auditInterval",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditInterval", "40",
				),
		},
		{
			Name: "Set .Values.auditMatchKindOnly to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditMatchKindOnly", "false",
				),
		},
		{
			Name: "Set .Values.constraintViolationsLimit to 20",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"constraintViolationsLimit", "20",
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
			Name: "Set .Values.disableMutation to false",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"disableMutation", "false",
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
			Name: "Set .Values.validatingWebhookTimeoutSeconds to 3",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookTimeoutSeconds", "3",
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
			Name: "Set .Values.validatingWebhookCheckIgnoreFailurePolicy to Fail",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"validatingWebhookCheckIgnoreFailurePolicy", "Fail",
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
			Name: "Set .Values.mutatingWebhookReinvocationPolicy to IfNeeded",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookReinvocationPolicy", "IfNeeded",
				),
		},
		{
			Name: "Set .Values.mutatingWebhookTimeoutSeconds to 2",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"mutatingWebhookReinvocationPolicy", "2",
				),
		},
		{
			Name: "Set .Values.auditChunkSize to 600",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"auditChunkSize", "600",
				),
		},
		{
			Name: "Set .Values.logLevel to Debug",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"logLevel", "DEBUG",
				),
		},

		//		For .Values.postUpgrade
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
		{
			Name: "Set postUpgrade.labelNamespace.image.pullSecrets",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.image.pullSecrets", "testPullSecrets",
				),
		},
		{
			Name: "Set postUpgrade.labelNamespace.extraNamespaces",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.labelNamespace.extraNamespaces", "testExtraNamespace",
				),
		},
		{
			Name: "Set postUpgrade.labelNamespace.podSecurity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.labelNamespace.podSecurity", testPodSecurityLabels,
				),
		},
		{
			Name: "Set postUpgrade.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.tolerations", testTolerations,
				),
		},
		{
			Name: "Set postUpgrade.nodeSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postUpgrade.nodeSelector", testNodeSelector,
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
					"postUpgrade.affinity", testResources,
				),
		},
		{
			Name: "Set postUpgrade.securityContext.allowPrivilegeEscalation to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.allowPrivilegeEscalation", "true",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.allowPrivilegeEscalation to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.allowPrivilegeEscalation", "false",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.capabilities.drop",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.capabilities.drop", "NET_ADMIN",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.readOnlyRootFilesystem to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.readOnlyRootFilesystem", "false",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.readOnlyRootFilesystem to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.readOnlyRootFilesystem", "true",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.runAsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.runAsGroup", "3000",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.runAsNonRoot to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.runAsNonRoot", "false",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.runAsNonRoot to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.runAsNonRoot", "true",
				),
		},
		{
			Name: "Set postUpgrade.securityContext.runAsUser",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postUpgrade.securityContext.runAsUser", "2000",
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
			Name: "Set postInstall.labelNamespace.extraRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("postInstall.labelNamespace.extraRules", "testExtraRules"),
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
				SetValue(
					"postInstall.labelNamespace.image.pullSecrets", "testPullSecrets",
				),
		},
		{
			Name: "Set postInstall.labelNamespace.extraNamespaces",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.labelNamespace.extraNamespaces", "testExtraNamespace",
				),
		},
		{
			Name: "Set postInstall.labelNamespace.podSecurity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.labelNamespace.podSecurity", testPodSecurityLabels,
				),
		},

		//		For .Values.postInstall.probeWebhook
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
				SetValue(
					"postInstall.probeWebhook.waitTimeout", "50",
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.httpTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.httpTimeout", "1",
				),
		},
		{
			Name: "Set Values for postInstall.probeWebhook.insecureHTTPS",
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
			Name: "Set postInstall.probeWebhook.tolerations",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.probeWebhook.tolerations", testTolerations,
				),
		},
		{
			Name: "Set postInstall.probeWebhook.nodeSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.probeWebhook.nodeSelector", testNodeSelector,
				),
		},
		{
			Name: "Set postInstall.probeWebhook.affinity",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"postInstall.probeWebhook.affinity", testAffinity,
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.allowPrivilegeEscalation to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.allowPrivilegeEscalation", "true",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.allowPrivilegeEscalation to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.allowPrivilegeEscalation", "false",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.capabilities.drop",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.capabilities.drop", "NET_ADMIN",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.readOnlyRootFilesystem to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.readOnlyRootFilesystem", "false",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.readOnlyRootFilesystem to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.readOnlyRootFilesystem", "true",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.runAsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.runAsGroup", "3000",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.runAsNonRoot to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.runAsNonRoot", "false",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.runAsNonRoot to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.runAsNonRoot", "true",
				),
		},
		{
			Name: "Set postInstall.probeWebhook.securityContext.runAsUser",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"postInstall.probeWebhook.securityContext.runAsUser", "2000",
				),
		},

		// For .Values.preUninstall
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.extraRules",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("preUninstall.deleteWebhookConfigurations.extraRules", "testExtraRules"),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.enabled to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.enabled", "false",
				),
		},
		{
			Name: "Set preUninstall.deleteWebhookConfigurations.enabled to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.deleteWebhookConfigurations.enabled", "true",
				),
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
				SetValue(
					"preUninstall.deleteWebhookConfigurations.image.pullSecrets", "testPullSecrets",
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
			Name: "Set preUninstall.nodeSelector",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"preUninstall.nodeSelector", testNodeSelector,
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
					"postUpgrade.affinity", testResources,
				),
		},
		{
			Name: "Set preUninstall.securityContext.allowPrivilegeEscalation to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.allowPrivilegeEscalation", "true",
				),
		},
		{
			Name: "Set preUninstall.securityContext.allowPrivilegeEscalation to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.allowPrivilegeEscalation", "false",
				),
		},
		{
			Name: "Set preUninstall.securityContext.capabilities.drop",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.capabilities.drop", "NET_ADMIN",
				),
		},
		{
			Name: "Set preUninstall.securityContext.readOnlyRootFilesystem to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.readOnlyRootFilesystem", "false",
				),
		},
		{
			Name: "Set preUninstall.securityContext.readOnlyRootFilesystem to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.readOnlyRootFilesystem", "true",
				),
		},
		{
			Name: "Set preUninstall.securityContext.runAsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.runAsGroup", "3000",
				),
		},
		{
			Name: "Set preUninstall.securityContext.runAsNonRoot to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.runAsNonRoot", "false",
				),
		},
		{
			Name: "Set preUninstall.securityContext.runAsNonRoot to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.runAsNonRoot", "true",
				),
		},
		{
			Name: "Set preUninstall.securityContext.runAsUser",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"preUninstall.securityContext.runAsUser", "2000",
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
				SetValue(
					"images.pullSecrets", "testPullSecrets",
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
			Name: "Set podCountLimit",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"podCountLimit", "120",
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

		// For Values.controllerManager
		{
			Name: "Set controllerManager.exemptNamespaces",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				Set(
					"controllerManager.exemptNamespaces", testExemptNamespaces,
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
				SetValue(
					"controllerManager.port", "8000",
				),
		},
		{
			Name: "Set controllerManager.metricsPort",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.metricsPort", "8080",
				),
		},
		{
			Name: "Set controllerManager.healthPort",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.healthPort", "8989",
				),
		},
		{
			Name: "Set controllerManager.readinessTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.readinessTimeout", "2",
				),
		},
		{
			Name: "Set controllerManager.livenessTimeout",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.livenessTimeout", "2",
				),
		},
		{
			Name: "Set controllerManager.priorityClassName",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.priorityClassName", "cluster-critical",
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
			Name: "Set livenessTimeout.tlsMinVersion",
			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"livenessTimeout.tlsMinVersion", "1.2",
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
		{
			Name: "Set controllerManager.resources.limits",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.resources.limits.cpu", "900m",
				).
				SetValue(
					"controllerManager.resources.limits.memory", "500Mi",
				),
		},
		{
			Name: "Set controllerManager.resources.requests",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.resources.requests.cpu", "90m",
				).
				SetValue(
					"controllerManager.resources.requests.memory", "250Mi",
				),
		},
		{
			Name: "Set controllerManager.securityContext.allowPrivilegeEscalation to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.allowPrivilegeEscalation", "true",
				),
		},
		{
			Name: "Set controllerManager.securityContext.allowPrivilegeEscalation to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.allowPrivilegeEscalation", "false",
				),
		},
		{
			Name: "Set controllerManager.securityContext.capabilities.drop",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.capabilities.drop", "NET_ADMIN",
				),
		},
		{
			Name: "Set controllerManager.securityContext.readOnlyRootFilesystem to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.readOnlyRootFilesystem", "false",
				),
		},
		{
			Name: "Set controllerManager.securityContext.readOnlyRootFilesystem to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.readOnlyRootFilesystem", "true",
				),
		},
		{
			Name: "Set controllerManager.securityContext.runAsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.runAsGroup", "3000",
				),
		},
		{
			Name: "Set controllerManager.securityContext.runAsNonRoot to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.runAsNonRoot", "false",
				),
		},
		{
			Name: "Set controllerManager.securityContext.runAsNonRoot to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.runAsNonRoot", "true",
				),
		},
		{
			Name: "Set controllerManager.securityContext.runAsUser",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.securityContext.runAsUser", "2000",
				),
		},
		{
			Name: "Set controllerManager.podSecurityContext.fsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.podSecurityContext.fsGroup", "1000",
				),
		},
		{
			Name: "Set controllerManager.podSecurityContext.supplementalGroups",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"controllerManager.podSecurityContext.supplementalGroups", "1000",
				),
		},
		{
			Name: "Set controllerManager.extraRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("controllerManager.extraRules", "testExtraRules"),
		},

		// For Values.audit
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
					"audit.priorityClassName", "cluster-critical",
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
			Name: "Set audit.resources.limits",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.resources.limits.cpu", "900m",
				).
				SetValue(
					"audit.resources.limits.memory", "500Mi",
				),
		},
		{
			Name: "Set audit.resources.requests",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.resources.requests.cpu", "90m",
				).
				SetValue(
					"audit.resources.requests.memory", "250Mi",
				),
		},
		{
			Name: "Set audit.securityContext.allowPrivilegeEscalation to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.allowPrivilegeEscalation", "true",
				),
		},
		{
			Name: "Set audit.securityContext.allowPrivilegeEscalation to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.allowPrivilegeEscalation", "false",
				),
		},
		{
			Name: "Set audit.securityContext.capabilities.drop",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.capabilities.drop", "NET_ADMIN",
				),
		},
		{
			Name: "Set audit.securityContext.readOnlyRootFilesystem to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.readOnlyRootFilesystem", "false",
				),
		},
		{
			Name: "Set audit.securityContext.readOnlyRootFilesystem to true",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.readOnlyRootFilesystem", "true",
				),
		},
		{
			Name: "Set audit.securityContext.runAsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.runAsGroup", "3000",
				),
		},
		{
			Name: "Set audit.securityContext.runAsNonRoot to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.runAsNonRoot", "false",
				),
		},
		{
			Name: "Set audit.securityContext.runAsNonRoot to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.runAsNonRoot", "true",
				),
		},
		{
			Name: "Set audit.securityContext.runAsUser",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.securityContext.runAsUser", "2000",
				),
		},
		{
			Name: "Set audit.podSecurityContext.fsGroup",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.podSecurityContext.fsGroup", "1000",
				),
		},
		{
			Name: "Set audit.podSecurityContext.supplementalGroups",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.podSecurityContext.supplementalGroups", "1000",
				),
		},
		{
			Name: "Set audit.writeToRAMDisk to False",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.writeToRAMDisk", "false",
				),
		},
		{
			Name: "Set audit.writeToRAMDisk to True",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue(
					"audit.writeToRAMDisk", "true",
				),
		},
		{
			Name: "Set audit.extraRules",

			TemplateOptions: chart.NewTemplateOptions(DefaultReleaseName, DefaultNamespace).
				SetValue("audit.extraRules", "testExtraRules"),
		},
	},
}
