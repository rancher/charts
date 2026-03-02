package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gitlab.com/StackVista/DevOps/helm-charts/helmtestutil"
)

func TestSecret(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/secrets.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// the secret exists
	secret, exists := resources.Secrets["suse-observability-agent-secrets"]
	require.True(t, exists, "secret was not found")

	// the secret contains the STS_API_KEY
	assert.Contains(t, secret.Data, "STS_API_KEY")
	// the secret contains the STS_API_KEY value
	assert.Equal(t, string(secret.Data["STS_API_KEY"]), "test_api_key")

	// the secret contains the STS_CLUSTER_AGENT_AUTH_TOKEN key
	assert.Contains(t, secret.Data, "STS_CLUSTER_AGENT_AUTH_TOKEN")
	// the secret contains the STS_CLUSTER_AGENT_AUTH_TOKEN value
	assert.Equal(t, string(secret.Data["STS_CLUSTER_AGENT_AUTH_TOKEN"]), "test_cluster_auth_token")
}

func TestMissingApiKey(t *testing.T) {
	error := helmtestutil.RenderHelmTemplateError(t, "suse-observability-agent", "values/minimal.yaml", "values/no_api_key.yaml")
	assert.Contains(t, error.Error(), "Please provide an api key.")
}

func TestMissingApiKeyDoesRenderWithLegacySecret(t *testing.T) {
	helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/no_api_key_with_legacy_secret.yaml")
}

func TestMissingApiKeyDoesRenderWithGlobalSecret(t *testing.T) {
	helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/no_api_key_with_global_secret.yaml")
}

func TestExtraEnvSecrets(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/secrets.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// the secret exists
	secret, exists := resources.Secrets["suse-observability-agent-secrets"]
	require.True(t, exists, "secret was not found")

	// the secret contains the extra env key
	assert.Contains(t, secret.Data, "test_extra_secret_key")
	// the secret contains the extra env value
	assert.Equal(t,
		string(secret.Data["test_extra_secret_key"]), "test_extra_secret_value")
}

func TestEnvVarFromSecretRefDeployments(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/secrets.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	for deploymentName, deployment := range resources.Deployments {
		if deploymentName == "suse-observability-agent-rbac-agent" {
			continue
		}
		t.Run(deploymentName, func(t *testing.T) {
			t.Logf("Processing deployment: %s", deploymentName)

			podSpec := deployment.Spec.Template.Spec
			for _, container := range podSpec.Containers {
				t.Logf("Checking container: %s in daemonset: %s", container.Name, deploymentName)
				var envVarFound bool

				for _, env := range container.Env {
					if env.Name == "test_extra_secret_key" {
						envVarFound = true
						// ensure the environment variable is configured to pull its value from an external source
						require.NotNil(t, env.ValueFrom, "env.ValueFrom is nil for %s in deployment %s", env.Name, deploymentName)
						// ensure the ValueFrom field specifically contains a SecretKeyRef, meaning the value is fetched from a Kubernetes Secret
						require.NotNil(t, env.ValueFrom.SecretKeyRef, "env.ValueFrom.SecretKeyRef is nil for %s in deployment %s", env.Name, deploymentName)
						// ensure the secret reference points to the correct secret
						assert.Equal(t, "suse-observability-agent-secrets", env.ValueFrom.SecretKeyRef.Name, "secret name mismatch for %s in deployment %s", env.Name, deploymentName)
						// ensure the key used in the secret reference is the expected one
						assert.Equal(t, "test_extra_secret_key", env.ValueFrom.SecretKeyRef.Key, "secret key mismatch for %s in deployment %s", env.Name, deploymentName)
					}
				}
				// ensure the environment variable was found in the container.
				assert.True(t, envVarFound, "Container %s in deployment %s does not have environment variable test_extra_secret_key", container.Name, deploymentName)
			}
		})
	}
}

func TestEnvVarFromSecretRefDaemonSets(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/secrets.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	for daemonsetName, daemonset := range resources.DaemonSets {
		t.Run(daemonsetName, func(t *testing.T) {

			// Skip the logs-agent daemonset as it does not provide env variables of this type.
			if daemonsetName == "suse-observability-agent-logs-agent" {
				t.Logf("Skipping env var check for daemonset: %s", daemonsetName)
				t.Skip("Skipping logs-agent as it does not provide Extra env vars")
			}

			t.Logf("Processing daemonset: %s", daemonsetName)

			podSpec := daemonset.Spec.Template.Spec
			for _, container := range podSpec.Containers {
				t.Logf("Checking container: %s in daemonset: %s", container.Name, daemonsetName)
				var envVarFound bool

				for _, env := range container.Env {
					if env.Name == "test_extra_secret_key" {
						envVarFound = true
						// ensure the environment variable is configured to pull its value from an external source
						require.NotNil(t, env.ValueFrom, "env.ValueFrom is nil for %s in daemonset %s", env.Name, daemonsetName)
						// ensure the ValueFrom field specifically contains a SecretKeyRef, meaning the value is fetched from a Kubernetes Secret
						require.NotNil(t, env.ValueFrom.SecretKeyRef, "env.ValueFrom.SecretKeyRef is nil for %s in daemonset %s", env.Name, daemonsetName)
						// ensure the secret reference points to the correct secret ("suse-observability-agent-secrets").
						assert.Equal(t, "suse-observability-agent-secrets", env.ValueFrom.SecretKeyRef.Name, "secret name mismatch for %s in daemonset %s", env.Name, daemonsetName)
						// ensure the key used in the secret reference is the expected one ("test_extra_secret_key").
						assert.Equal(t, "test_extra_secret_key", env.ValueFrom.SecretKeyRef.Key, "secret key mismatch for %s in daemonset %s", env.Name, daemonsetName)
					}
				}
				// ensure the environment variable was found in the container.
				assert.True(t, envVarFound, "Container %s in daemonset %s does not have environment variable test_extra_secret_key", container.Name, daemonsetName)
			}
		})
	}
}
