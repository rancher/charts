package test

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gitlab.com/StackVista/DevOps/helm-charts/helmtestutil"
)

func TestCustomCertificatesConfigMapCreation(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-pem.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// The custom certificates ConfigMap should exist
	configMap, exists := resources.ConfigMaps["suse-observability-agent-custom-certificates"]
	require.True(t, exists, "custom certificates ConfigMap was not found")

	// The ConfigMap should contain the tls.pem key
	assert.Contains(t, configMap.Data, "tls.pem")

	// The ConfigMap should contain the expected certificate data
	certData := configMap.Data["tls.pem"]
	assert.Contains(t, certData, "-----BEGIN CERTIFICATE-----")
	assert.Contains(t, certData, "-----END CERTIFICATE-----")
	assert.Contains(t, certData, "MIICTjCCAbugAwIBAgIGAYLHmCCJMA0GCSqGSIb3DQEBCwUAMC4xLDAqBgNVBAMM")
}

func TestCustomCertificatesConfigMapNotCreatedWhenExternalConfigMap(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-configmap.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// The custom certificates ConfigMap should NOT exist when using external ConfigMap
	_, exists := resources.ConfigMaps["suse-observability-agent-custom-certificates"]
	assert.False(t, exists, "custom certificates ConfigMap should not be created when using external ConfigMap")
}

func TestCustomCertificatesConfigMapNotCreatedWhenDisabled(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// The custom certificates ConfigMap should NOT exist when disabled
	_, exists := resources.ConfigMaps["suse-observability-agent-custom-certificates"]
	assert.False(t, exists, "custom certificates ConfigMap should not be created when disabled")
}

func TestCustomCertificatesVolumeMountInDeployments(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-pem.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	expectedDeployments := []string{
		"suse-observability-agent-cluster-agent",
		"suse-observability-agent-checks-agent",
	}

	for _, deploymentName := range expectedDeployments {
		t.Run(deploymentName, func(t *testing.T) {
			deployment, exists := resources.Deployments[deploymentName]
			require.True(t, exists, "deployment %s was not found", deploymentName)

			// Check that custom-certificates volume is present
			var customCertsVolumeFound bool
			for _, volume := range deployment.Spec.Template.Spec.Volumes {
				if volume.Name == "custom-certificates" {
					customCertsVolumeFound = true
					assert.NotNil(t, volume.ConfigMap, "custom-certificates volume should be a ConfigMap")
					assert.Equal(t, "suse-observability-agent-custom-certificates", volume.ConfigMap.Name)
					break
				}
			}
			assert.True(t, customCertsVolumeFound, "custom-certificates volume not found in deployment %s", deploymentName)

			// Check that custom-certificates volume mount is present in containers
			for _, container := range deployment.Spec.Template.Spec.Containers {
				var customCertsVolumeMountFound bool
				for _, volumeMount := range container.VolumeMounts {
					if volumeMount.Name == "custom-certificates" {
						customCertsVolumeMountFound = true
						assert.Equal(t, "/etc/pki/tls/certs", volumeMount.MountPath)
						assert.True(t, volumeMount.ReadOnly)
						break
					}
				}
				assert.True(t, customCertsVolumeMountFound, "custom-certificates volume mount not found in container %s of deployment %s", container.Name, deploymentName)
			}
		})
	}
}

func TestCustomCertificatesVolumeMountInDaemonSets(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-pem.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	expectedDaemonSets := []string{
		"suse-observability-agent-node-agent",
		"suse-observability-agent-logs-agent",
	}

	for _, daemonSetName := range expectedDaemonSets {
		t.Run(daemonSetName, func(t *testing.T) {
			daemonSet, exists := resources.DaemonSets[daemonSetName]
			require.True(t, exists, "daemonset %s was not found", daemonSetName)

			// Check that custom-certificates volume is present
			var customCertsVolumeFound bool
			for _, volume := range daemonSet.Spec.Template.Spec.Volumes {
				if volume.Name == "custom-certificates" {
					customCertsVolumeFound = true
					assert.NotNil(t, volume.ConfigMap, "custom-certificates volume should be a ConfigMap")
					assert.Equal(t, "suse-observability-agent-custom-certificates", volume.ConfigMap.Name)
					break
				}
			}
			assert.True(t, customCertsVolumeFound, "custom-certificates volume not found in daemonset %s", daemonSetName)

			// Check that custom-certificates volume mount is present in containers
			for _, container := range daemonSet.Spec.Template.Spec.Containers {
				var customCertsVolumeMountFound bool
				for _, volumeMount := range container.VolumeMounts {
					if volumeMount.Name == "custom-certificates" {
						customCertsVolumeMountFound = true
						assert.Equal(t, "/etc/pki/tls/certs", volumeMount.MountPath)
						assert.True(t, volumeMount.ReadOnly)
						break
					}
				}
				assert.True(t, customCertsVolumeMountFound, "custom-certificates volume mount not found in container %s of daemonset %s", container.Name, daemonSetName)
			}
		})
	}
}

func TestCustomCertificatesVolumeWithExternalConfigMap(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-configmap.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// Test cluster agent deployment
	deployment, exists := resources.Deployments["suse-observability-agent-cluster-agent"]
	require.True(t, exists, "cluster agent deployment was not found")

	// Check that custom-certificates volume references the external ConfigMap
	var customCertsVolumeFound bool
	for _, volume := range deployment.Spec.Template.Spec.Volumes {
		if volume.Name == "custom-certificates" {
			customCertsVolumeFound = true
			assert.NotNil(t, volume.ConfigMap, "custom-certificates volume should be a ConfigMap")
			assert.Equal(t, "external-ca-certificates", volume.ConfigMap.Name)
			break
		}
	}
	assert.True(t, customCertsVolumeFound, "custom-certificates volume not found in cluster agent deployment")
}

func TestCustomCertificatesVolumesNotPresentWhenDisabled(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// Test cluster agent deployment
	deployment, exists := resources.Deployments["suse-observability-agent-cluster-agent"]
	require.True(t, exists, "cluster agent deployment was not found")

	// Check that custom-certificates volume is NOT present when disabled
	for _, volume := range deployment.Spec.Template.Spec.Volumes {
		assert.NotEqual(t, "custom-certificates", volume.Name, "custom-certificates volume should not be present when disabled")
	}

	// Check that custom-certificates volume mount is NOT present in containers
	for _, container := range deployment.Spec.Template.Spec.Containers {
		for _, volumeMount := range container.VolumeMounts {
			assert.NotEqual(t, "custom-certificates", volumeMount.Name, "custom-certificates volume mount should not be present when disabled")
		}
	}
}

func TestCustomCertificatesChecksumAnnotation(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-pem.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	expectedComponents := []string{
		"suse-observability-agent-cluster-agent",
		"suse-observability-agent-checks-agent",
	}

	for _, componentName := range expectedComponents {
		t.Run(componentName, func(t *testing.T) {
			deployment, exists := resources.Deployments[componentName]
			require.True(t, exists, "deployment %s was not found", componentName)

			// Check that checksum annotation is present
			annotations := deployment.Spec.Template.Annotations
			assert.Contains(t, annotations, "checksum/custom-certificates", "checksum annotation not found in deployment %s", componentName)

			// Check that checksum value is not empty
			checksum := annotations["checksum/custom-certificates"]
			assert.NotEmpty(t, checksum, "checksum annotation should not be empty in deployment %s", componentName)
		})
	}

	// Test daemonsets
	expectedDaemonSets := []string{
		"suse-observability-agent-node-agent",
		"suse-observability-agent-logs-agent",
	}

	for _, daemonSetName := range expectedDaemonSets {
		t.Run(daemonSetName, func(t *testing.T) {
			daemonSet, exists := resources.DaemonSets[daemonSetName]
			require.True(t, exists, "daemonset %s was not found", daemonSetName)

			// Check that checksum annotation is present
			annotations := daemonSet.Spec.Template.Annotations
			assert.Contains(t, annotations, "checksum/custom-certificates", "checksum annotation not found in daemonset %s", daemonSetName)

			// Check that checksum value is not empty
			checksum := annotations["checksum/custom-certificates"]
			assert.NotEmpty(t, checksum, "checksum annotation should not be empty in daemonset %s", daemonSetName)
		})
	}
}

func TestCustomCertificatesChecksumAnnotationNotPresentWhenExternalConfigMap(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml", "values/custom-certificates-configmap.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// Test cluster agent deployment
	deployment, exists := resources.Deployments["suse-observability-agent-cluster-agent"]
	require.True(t, exists, "cluster agent deployment was not found")

	// Check that checksum annotation is NOT present when using external ConfigMap
	annotations := deployment.Spec.Template.Annotations
	assert.NotContains(t, annotations, "checksum/custom-certificates", "checksum annotation should not be present when using external ConfigMap")
}

func TestCustomCertificatesChecksumAnnotationNotPresentWhenDisabled(t *testing.T) {
	output := helmtestutil.RenderHelmTemplate(t, "suse-observability-agent", "values/minimal.yaml")
	resources := helmtestutil.NewKubernetesResources(t, output)

	// Test cluster agent deployment
	deployment, exists := resources.Deployments["suse-observability-agent-cluster-agent"]
	require.True(t, exists, "cluster agent deployment was not found")

	// Check that checksum annotation is NOT present when disabled
	annotations := deployment.Spec.Template.Annotations
	assert.NotContains(t, annotations, "checksum/custom-certificates", "checksum annotation should not be present when disabled")
}

func TestCustomCertificatesValidationFailsWhenBothConfigMapAndPemDataProvided(t *testing.T) {
	// Get current directory and navigate to parent (chart root)
	curDir, err := os.Getwd()
	require.NoError(t, err)
	chartDir := filepath.Join(curDir, "..")

	// Run helm template command directly to test validation failure
	cmd := exec.Command("helm", "template", "test-release", ".",
		"--values", "test/values/minimal.yaml",
		"--values", "test/values/custom-certificates-both-invalid.yaml")
	cmd.Dir = chartDir

	// This should fail with our validation error
	output, err := cmd.CombinedOutput()

	// Verify the command failed as expected
	require.Error(t, err, "Expected Helm template rendering to fail when both configMapName and pemData are provided")

	// Verify the error contains our validation message
	errorOutput := string(output)
	assert.Contains(t, errorOutput, "Both global.customCertificates.configMapName and global.customCertificates.pemData are provided", "Error message should contain validation text")
}
