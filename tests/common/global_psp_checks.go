package common

import (
	"testing"

	"github.com/rancher/hull/pkg/checker"
	"github.com/rancher/hull/pkg/test"
	"github.com/stretchr/testify/assert"
	policyv1 "k8s.io/api/policy/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	rbacv1 "k8s.io/kubernetes/pkg/apis/rbac"
)

func EnsurePSPsExist(numExpectedPSPs int) test.Checks {
	return test.Checks{
		checker.OnResources(func(tc *checker.TestContext, pspList []*policyv1.PodSecurityPolicy) {

			pspsEnabled, _ := checker.RenderValue[bool](tc, ".Values.global.cattle.psp.enabled")

			if pspsEnabled {
				assert.Equal(tc.T, numExpectedPSPs, len(pspList),
					"total number of PSPs mismatch, expected:%d, got: %d",
					numExpectedPSPs, len(pspList))
			}

		}),

		onRoles(func(tc *checker.TestContext, objRules map[metav1.Object][]rbacv1.PolicyRule) {

			pspsEnabled, _ := checker.RenderValue[bool](tc, ".Values.global.cattle.psp.enabled")

			if !pspsEnabled {
				for obj, rules := range objRules {
					for _, rule := range rules {
						for _, resource := range rule.Resources {
							if resource == "podsecuritypolicies" {
								tc.T.Errorf("err: Role %s has reference to psp resources with psp disabled", obj.GetName())
								return
							}
						}
					}
				}
			}

		}),
	}
}

func onRoles(typeCheckFunc func(tc *checker.TestContext, rules map[metav1.Object][]rbacv1.PolicyRule)) checker.ChainedCheckFunc {
	return func(tc *checker.TestContext) checker.CheckFunc {
		return func(t *testing.T, objs struct {
			ClusterRoles []*rbacv1.ClusterRole
			Roles        []*rbacv1.Role
		}) {
			tc.T = t
			rules := make(map[metav1.Object][]rbacv1.PolicyRule)
			for _, obj := range objs.ClusterRoles {
				rules[obj] = obj.Rules
			}
			for _, obj := range objs.Roles {
				rules[obj] = obj.Rules
			}
			typeCheckFunc(tc, rules)
		}
	}
}
