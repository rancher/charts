package common

import (
	"fmt"
	"strings"

	"github.com/rancher/hull/pkg/checker"
	"github.com/rancher/hull/pkg/test"
	"github.com/rancher/wrangler/pkg/relatedresource"
	"github.com/stretchr/testify/assert"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Check that every Workload has a ServiceAccount deployed with it
var AllWorkloadsHaveServiceAccount = test.Checks{
	checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
		namespace := obj.GetNamespace()

		if namespace == "" {

			annotations := obj.GetAnnotations()

			if annotations["helm.sh/hook"] != "" {

				releaseNamespace, exists := checker.RenderValue[string](tc, ".Release.Namespace")
				if exists {
					namespace = releaseNamespace
				}
			}
		}

		key := relatedresource.NewKey(
			namespace,
			podTemplateSpec.Spec.ServiceAccountName,
		)
		checker.MapSet(tc, "ServiceAccountsToCheck", key, false)
	}),
	checker.PerResource(func(tc *checker.TestContext, serviceAccount *corev1.ServiceAccount) {
		key := checker.Key(serviceAccount)
		_, exists := checker.MapGet[string, relatedresource.Key, bool](tc, "ServiceAccountsToCheck", key)
		if !exists {
			// does not belong to any workload
			tc.T.Logf("warn: serviceaccount %s is not tied to any workload", key)
			return
		}
		checker.MapSet(tc, "ServiceAccountsToCheck", key, true)
	}),
	checker.Once(func(tc *checker.TestContext) {
		checker.MapFor(tc, "ServiceAccountsToCheck", func(key relatedresource.Key, exists bool) {
			assert.True(tc.T, exists, "serviceaccount %s is not in this chart", key)
		})
	}),
}

var AllWorkloadsHaveNodeSelectorsAndTolerationsForOS = test.Checks{
	checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
		nodeSelector := podTemplateSpec.Spec.NodeSelector
		betaOSVal, hasBetaOSAnnotation := nodeSelector["beta.kubernetes.io/os"]
		osVal, hasOSAnnotation := nodeSelector["kubernetes.io/os"]
		if hasBetaOSAnnotation && hasOSAnnotation {
			assert.Equal(tc.T, osVal, betaOSVal, fmt.Sprintf("%T %s is has conflicting values for nodeSelector beta.kubernetes.io/os or kubernetes.io/os", obj, checker.Key(obj)))
		}
		if hasBetaOSAnnotation {
			if betaOSVal == "windows" {
				checker.MapSet(tc, "Windows Workload", &podTemplateSpec, true)
			}
			tc.T.Logf("warn: beta.kubernetes.io/os nodeSelector has been deprecated but is used in %T %s", obj, checker.Key(obj))
			assert.Contains(tc.T, []string{"linux", "windows"}, betaOSVal, fmt.Sprintf("%T %s cannot have value for beta.kubernetes.io/os that is not 'linux' or 'windows': found %s", obj, checker.Key(obj), betaOSVal))
		}
		if hasOSAnnotation {
			if osVal == "windows" {
				checker.MapSet(tc, "Windows Workload", &obj, true)
			}
			assert.Contains(tc.T, []string{"linux", "windows"}, osVal, fmt.Sprintf("%T %s cannot have value for kubernetes.io/os that is not 'linux' or 'windows': found %s", obj, checker.Key(obj), osVal))
		}
		assert.False(tc.T, !hasBetaOSAnnotation && !hasOSAnnotation, fmt.Sprintf("%T %s is missing OS key for nodeSelector, expected to find either beta.kubernetes.io/os or kubernetes.io/os", obj, checker.Key(obj)))
	}),
	checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {
		isWindowsWorkload, _ := checker.MapGet[string, *metav1.Object, bool](tc, "Windows Workload", &obj)
		if isWindowsWorkload {
			// no need to check for tolerations
			return
		}
		tolerations := podTemplateSpec.Spec.Tolerations
		var foundToleration bool
		for _, toleration := range tolerations {
			if toleration.Key != "cattle.io/os" {
				continue
			}
			if toleration.Value != "linux" {
				continue
			}
			if toleration.Effect != "NoSchedule" {
				continue
			}
			if toleration.Operator != "Equal" {
				continue
			}
			foundToleration = true
		}
		assert.True(tc.T, foundToleration, "could not find toleration in workload %T %s that tolerates the NoSchedule 'cattle.io/os: linux' taint", obj, checker.Key(obj))
	}),
}

var AllContainerImagesShouldHaveSystemDefaultRegistryPrefix = test.Checks{
	checker.PerWorkload(func(tc *checker.TestContext, obj metav1.Object, podTemplateSpec corev1.PodTemplateSpec) {

		systemDefaultRegistry := GetSystemDefaultRegistry(tc)

		for _, container := range podTemplateSpec.Spec.Containers {

			if !strings.HasPrefix(container.Image, systemDefaultRegistry) {
				tc.T.Errorf("err: contianer %s of object %s does not have systemDefaultRegistry(%s) prefix for image(%s)",
					container.Name, obj.GetName(), systemDefaultRegistry, container.Image)
			}
		}
	}),
}

