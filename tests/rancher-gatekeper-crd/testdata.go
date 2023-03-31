package rancher_gatekeeper_crd

import (
	corev1 "k8s.io/api/core/v1"
)

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

var testSecurityContext = &corev1.SecurityContext{
	AllowPrivilegeEscalation: func() *bool { b := true; return &b }(),
	Capabilities: &corev1.Capabilities{
		Drop: []corev1.Capability{
			"ALL",
		},
	},
	Privileged: func() *bool { b := true; return &b }(),
	ReadOnlyRootFilesystem: func() *bool { b := true; return &b }(),
	RunAsNonRoot:           func() *bool { b := true; return &b }(),
	RunAsUser:              func() *int64 { i := int64(100); return &i }(),
}
