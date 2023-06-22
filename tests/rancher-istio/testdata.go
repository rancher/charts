package rancher_istio

import (
	autoscalingv2 "k8s.io/api/autoscaling/v2"
	corev1 "k8s.io/api/core/v1"
	policyv1 "k8s.io/api/policy/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
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

// for .Values.pilot.hpaSpec
var testHPASpec = &autoscalingv2.HorizontalPodAutoscalerSpec{
	MaxReplicas: 5,
	MinReplicas: int32Ptr(1),
	ScaleTargetRef: autoscalingv2.CrossVersionObjectReference{
		APIVersion: "apps/v1",
		Kind:       "Deployment",
		Name:       "istio-pilot",
	},
}

var testPodDisruptionBudget = &policyv1.PodDisruptionBudget{
	ObjectMeta: metav1.ObjectMeta{
		Name:      "example-pdb",
		Namespace: "default",
	},
	Spec: policyv1.PodDisruptionBudgetSpec{
		MaxUnavailable: &intstr.IntOrString{
			Type:   intstr.Int,
			IntVal: 1,
		},
		Selector: &metav1.LabelSelector{
			MatchLabels: map[string]string{
				"app": "test",
			},
		},
	},
}

var testIstioOverlay = ""

func int32Ptr(i int32) *int32 { return &i }
