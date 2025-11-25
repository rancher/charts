package test

import (
	"regexp"
	"strings"
	"testing"

	v1 "k8s.io/api/rbac/v1"

	"github.com/stretchr/testify/assert"
	"gitlab.com/StackVista/DevOps/helm-charts/helmtestutil"
)

var requiredRules = []string{
	"events+get,list,watch",
	"nodes+get,list,watch",
	"pods+get,list,watch",
	"services+get,list,watch",
	"configmaps+create,get,patch,update",
}

var optionalRules = []string{
	"namespaces+get,list,watch",
	"componentstatuses+get,list,watch",
	"configmaps+list,watch", // get is already required
	"endpoints+get,list,watch",
	"persistentvolumeclaims+get,list,watch",
	"persistentvolumes+get,list,watch",
	"secrets+get,list,watch",
	"apps/daemonsets+get,list,watch",
	"apps/deployments+get,list,watch",
	"apps/replicasets+get,list,watch",
	"apps/statefulsets+get,list,watch",
	"extensions/ingresses+get,list,watch",
	"batch/cronjobs+get,list,watch",
	"batch/jobs+get,list,watch",
}

var roleDescriptionRegexp = regexp.MustCompile(`^((?P<group>\w+)/)?(?P<name>\w+)\+(?P<verbs>[\w,]+)`)

type Rule struct {
	Group        string
	ResourceName string
	Verb         string
}

func assertRuleExistence(t *testing.T, rules []v1.PolicyRule, roleDescription string, shouldBePresent bool) {
	match := roleDescriptionRegexp.FindStringSubmatch(roleDescription)
	assert.NotNil(t, match)

	var roleRules []Rule
	for _, rule := range rules {
		for _, group := range rule.APIGroups {
			for _, resource := range rule.Resources {
				for _, verb := range rule.Verbs {
					roleRules = append(roleRules, Rule{group, resource, verb})
				}
			}
		}
	}

	resGroup := match[roleDescriptionRegexp.SubexpIndex("group")]
	resName := match[roleDescriptionRegexp.SubexpIndex("name")]
	verbs := strings.Split(match[roleDescriptionRegexp.SubexpIndex("verbs")], ",")

	for _, verb := range verbs {
		requiredRule := Rule{resGroup, resName, verb}
		found := false
		for _, rule := range roleRules {
			if rule == requiredRule {
				found = true
				break
			}
		}
		if shouldBePresent {
			assert.Truef(t, found, "Rule %v has not been found", requiredRule)
		} else {
			assert.Falsef(t, found, "Rule %v should not be present", requiredRule)
		}
	}
}

func TestAllResourcesAreEnabled(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	assert.Contains(t, resources.ClusterRoles, "suse-observability-agent")
	assert.Contains(t, resources.Roles, "suse-observability-agent")
	rules := resources.ClusterRoles["suse-observability-agent"].Rules
	rules = append(rules, resources.Roles["suse-observability-agent"].Rules...)

	for _, requiredRole := range requiredRules {
		assertRuleExistence(t, rules, requiredRole, true)
	}
	// be default, everything is enabled, so all the optional roles should be present as well
	for _, optionalRule := range optionalRules {
		assertRuleExistence(t, rules, optionalRule, true)
	}
}

func TestMostOfResourcesAreDisabled(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/disable-all-resource.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	assert.Contains(t, resources.ClusterRoles, "suse-observability-agent")
	assert.Contains(t, resources.Roles, "suse-observability-agent")
	rules := resources.ClusterRoles["suse-observability-agent"].Rules
	rules = append(rules, resources.Roles["suse-observability-agent"].Rules...)

	for _, requiredRole := range requiredRules {
		assertRuleExistence(t, rules, requiredRole, true)
	}

	// we expect all optional resources to be removed from ClusterRole with the given values
	for _, optionalRule := range optionalRules {
		assertRuleExistence(t, rules, optionalRule, false)
	}
}

func TestNoClusterWideModificationRights(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/http-header-injector.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)
	assert.Contains(t, resources.ClusterRoles, "suse-observability-agent")
	illegalVerbs := []string{"create", "patch", "update", "delete"}

	for _, clusterRole := range resources.ClusterRoles {
		for _, rule := range clusterRole.Rules {
			for _, verb := range rule.Verbs {
				assert.NotContains(t, illegalVerbs, verb, "ClusterRole %s should not have %s verb for %s resource", clusterRole.Name, verb, rule.Resources)
			}
		}
	}
}

func TestServicePortChange(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/clustercheck_service_port_override.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	cluster_agent_service := resources.Services["suse-observability-agent-cluster-agent"]

	port := cluster_agent_service.Spec.Ports[0]
	assert.Equal(t, port.Name, "clusteragent")
	assert.Equal(t, port.Port, int32(8008))
	assert.Equal(t, port.TargetPort.IntVal, int32(9009))
}
