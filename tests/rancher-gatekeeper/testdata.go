package rancher_gatekeeper

import (
	adminReg "k8s.io/api/admissionregistration/v1"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// for Values.nodeSelector
var defaultNodeSelector = map[string]string{
	"kubernetes.io/os": "linux",
}

var testNodeSelector = map[string]string{
	"test": "testVal",
}

// for Values.tolerations
var defaultTolerations = []corev1.Toleration{
	{
		Key:      "cattle.io/os",
		Operator: corev1.TolerationOpEqual,
		Value:    "linux",
		Effect:   corev1.TaintEffectNoSchedule,
	},
}

var testTolerations = []corev1.Toleration{
	{
		Key:      "test",
		Operator: corev1.TolerationOpEqual,
		Value:    "test",
		Effect:   corev1.TaintEffectNoSchedule,
	},
	{
		Key:      "test1",
		Operator: corev1.TolerationOpExists,
		Value:    "test1",
		Effect:   corev1.TaintEffectNoExecute,
	},
}

// for Values.affinity
var testAffinity = &corev1.Affinity{
	NodeAffinity: &corev1.NodeAffinity{
		RequiredDuringSchedulingIgnoredDuringExecution: &corev1.NodeSelector{
			NodeSelectorTerms: []corev1.NodeSelectorTerm{
				{
					MatchExpressions: []corev1.NodeSelectorRequirement{
						{
							Key:      "test",
							Values:   []string{"test"},
							Operator: corev1.NodeSelectorOpIn,
						},
					},
				},
			},
		},
	},
}

var testDeploymentAffinity = &corev1.Affinity{
	PodAntiAffinity: &corev1.PodAntiAffinity{
		PreferredDuringSchedulingIgnoredDuringExecution: []corev1.WeightedPodAffinityTerm{
			{
				PodAffinityTerm: corev1.PodAffinityTerm{
					LabelSelector: &v1.LabelSelector{
						MatchExpressions: []v1.LabelSelectorRequirement{
							{
								Key:      "test",
								Operator: v1.LabelSelectorOpIn,
								Values:   []string{"test"},
							},
						},
					},
					TopologyKey: "testTopologyKey",
				},
			},
		},
	},
}

var testValidatingWebhookObjectSelector = &v1.LabelSelector{
	MatchExpressions: []v1.LabelSelectorRequirement{
		{
			Key:      "test",
			Operator: v1.LabelSelectorOpIn,
			Values:   []string{"test"},
		},
	},
}

var allowPrivilegeEscalationVal bool = false
var readOnlyRootFilesystemVal bool = true
var runAsGroupVal int64 = 999
var runAsNonRootVal bool = true
var runAsUserVal int64 = 1000

var testSecurityContext = &corev1.SecurityContext{
	Capabilities: &corev1.Capabilities{
		Drop: []corev1.Capability{"All"},
	},
	AllowPrivilegeEscalation: &allowPrivilegeEscalationVal,
	ReadOnlyRootFilesystem:   &readOnlyRootFilesystemVal,
	RunAsGroup:               &runAsGroupVal,
	RunAsNonRoot:             &runAsNonRootVal,
	RunAsUser:                &runAsUserVal,
}

var fsGroupsVal int64 = 1000
var supplementalGroupsVal = []int64{1000}
var testPodSecurityContext = &corev1.PodSecurityContext{
	FSGroup:            &fsGroupsVal,
	SupplementalGroups: supplementalGroupsVal,
}

// podSecurityLabels
var testPodSecurityLabels = []string{
	"pod-security.kubernetes.io/audit=restricted",
	"pod-security.kubernetes.io/audit-version=latest",
	"pod-security.kubernetes.io/warn=restricted",
	"pod-security.kubernetes.io/warn-version=latest",
	"pod-security.kubernetes.io/enforce=restricted",
	"pod-security.kubernetes.io/enforce-version=v1.24",
}

// for Values.resources
var testResources = corev1.ResourceRequirements{
	Limits: corev1.ResourceList{
		corev1.ResourceCPU:    *resource.NewQuantity(250, resource.DecimalSI),
		corev1.ResourceMemory: *resource.NewQuantity(64, resource.BinarySI),
	},
	Requests: corev1.ResourceList{
		corev1.ResourceCPU:    *resource.NewQuantity(500, resource.DecimalSI),
		corev1.ResourceMemory: *resource.NewQuantity(120, resource.BinarySI),
	},
}

// var testResources = corev1.ResourceRequirements{
// 	Limits: corev1.ResourceList{
// 		corev1.ResourceCPU:
// 	},
// }

var testWebhookAnnotations = map[string]string{
	"test/annotation":  "annotationVal",
	"test/annotation2": "annotationVal2",
}

// for Values.podAnnotation
var testPodAnnotation = map[string]string{
	"test/annotation":  "annotationVal",
	"test/annotation2": "annotationVal2",
}

var testPodLabels = map[string]string{
	"test/label1": "labelVal1",
	"test/label2": "labelVal2",
}

var testExtraNamespaces = []string{
	"test-ns1",
	"test-ns2",
}

// for Values.controllerManager

var testExemptNamespaces = []string{
	"testExempt-ns1",
	"testExempt-ns2",
	"testExempt-ns3",
}

var testExemptNamespacesPrefixes = []string{
	"testExemptNamespacesPrefixesNs1",
	"testExemptNamespacesPrefixesnsNs2",
	"testExemptNamespacesPrefixesnsNs3",
}
var testExemptNamespacesSuffixes = []string{
	"testExemptNamespacesSuffixesNs1",
	"testExemptNamespacesSuffixesnsNs2",
	"testExemptNamespacesSuffixesnsNs3",
}
var testDisabledBuiltins = []string{
	"{testBuiltin1}",
	"{testBuiltin2}",
}
var defaultExemptNamespace = []string{
	"default",
}

var testMetricsBackend = []string{
	"default",
}

var testPullSecrets = []corev1.LocalObjectReference{
	{
		Name: "testSecret",
	},
}
var testExtraRules = []rbacv1.PolicyRule{
	{
		APIGroups: []string{"*"},
		Verbs:     []string{"create", "patch", "delete"},
		Resources: []string{"pods", "deployments"},
	},
	{
		APIGroups: []string{"rbac.authorization.k8s.io"},
		Verbs:     []string{"create", "patch", "delete"},
		Resources: []string{"clusterroles"},
	},
}

var testTopologySpreadConstraints = []*corev1.TopologySpreadConstraint{
	{
		MaxSkew:           1,
		TopologyKey:       "topKey",
		WhenUnsatisfiable: corev1.DoNotSchedule,
		LabelSelector: &v1.LabelSelector{
			MatchLabels: map[string]string{
				"app": "k8s",
			},
		},
		MatchLabelKeys: []string{"apps", "tests"},
	},
	{
		MaxSkew:           4,
		TopologyKey:       "topKey",
		WhenUnsatisfiable: corev1.DoNotSchedule,
		LabelSelector: &v1.LabelSelector{
			MatchLabels: map[string]string{
				"app": "k8s-test",
			},
		},
		MatchLabelKeys: []string{"apps", "tests-k8s"},
	},
}

var testWebhookExemptNamespacesLabels = map[string][]string{
	"testkey":  []string{"testval1", "testval2"},
	"testkey2": []string{"testval3"},
}
var testWebhookCustomRules = []adminReg.RuleWithOperations{
	{
		Operations: []adminReg.OperationType{
			adminReg.OperationAll,
			adminReg.Connect,
			adminReg.Create,
			adminReg.Update,
			adminReg.Delete,
		},
		Rule: adminReg.Rule{
			APIGroups:   []string{"*"},
			APIVersions: []string{"v1"},
			Resources:   []string{"test"},
		},
	},
	{
		Operations: []adminReg.OperationType{
			adminReg.OperationAll,
			adminReg.Delete,
		},
		Rule: adminReg.Rule{
			APIGroups:   []string{""},
			APIVersions: []string{"v1"},
			Resources:   []string{"k8s"},
		},
	},
}
