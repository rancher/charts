package rancher_gatekeeper

import (
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
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

// podSecurityLabels
var defaultPodSecurityLabels = map[string]string{
	"pod-security.kubernetes.io/audit":           "restricted",
	"pod-security.kubernetes.io/audit-version":   "latest",
	"pod-security.kubernetes.io/warn":            "restricted",
	"pod-security.kubernetes.io/warn-version":    "latest",
	"pod-security.kubernetes.io/enforce":         "restricted",
	"pod-security.kubernetes.io/enforce-version": "v1.24",
}

var testPodSecurityLabels = map[string]string{
	"test": "testVal",
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

// for Values.podAnnotation
var testPodAnnotation = map[string]string{
	"test": "testVal",
}

// for Values.controllerManager.exepmtNamespaces

var testExemptNamespaces = []string{
	"test-ns1",
	"test-ns2",
	"test-ns3",
}

var defaultExemptNamespace = []string{
	"default",
}
