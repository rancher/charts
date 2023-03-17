package rancher_cis_benchmark

import (
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
)

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

// for Values.securityScanJob.tolerations
var testSecScanJobTolerations = []corev1.Toleration{
	{
		Key:      "test-scan1",
		Operator: corev1.TolerationOpEqual,
		Value:    "test-scan1",
		Effect:   corev1.TaintEffectNoSchedule,
	},
	{
		Key:      "test-scan2",
		Operator: corev1.TolerationOpExists,
		Value:    "test-scan2",
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
