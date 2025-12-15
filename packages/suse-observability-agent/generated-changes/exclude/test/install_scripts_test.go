package test

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestGetImages(t *testing.T) {
	curDir, err := os.Getwd()
	require.NoError(t, err)
	images := strings.Split(RunGetImagesScript(t, filepath.Join(curDir, "..")), "\n")
	require.Equal(t, 9, len(
		slices.DeleteFunc(
			images,
			func(e string) bool {
				return e == ""
			}),
	), images)
}

func TestChangeImageRepo(t *testing.T) {
	curDir, err := os.Getwd()
	require.NoError(t, err)

	tmpDir, err := os.MkdirTemp("/tmp", "install-scripts")
	require.NoError(t, err)
	defer os.RemoveAll(tmpDir)

	err = exec.Command("cp", "-a", filepath.Join(curDir, ".."), tmpDir).Run()
	require.NoError(t, err)

	helmDir := filepath.Join(tmpDir, "suse-observability-agent")

	targetReg := "reg"
	targetRepo := "repo"
	currentImages := RunGetImagesScript(t, helmDir)
	expectedImages := strings.ReplaceAll(currentImages, "quay.io/stackstate", fmt.Sprintf("%s/%s", targetReg, targetRepo))
	RunChangeImageScript(t, helmDir, targetReg, targetRepo)
	renamedImages := RunGetImagesScript(t, helmDir)
	require.Equal(t, expectedImages, renamedImages)
}

func RunGetImagesScript(t *testing.T, dir string) string {
	cmd := exec.Command(filepath.Join(dir, "installation", "o11y-agent-get-images.sh"))
	stdout, err := cmd.Output()

	require.NoError(t, err)
	return string(stdout)
}

func RunChangeImageScript(t *testing.T, dir, registry, repository string) {
	cmd := exec.Command(filepath.Join(dir, "maintenance", "change-image-source.sh"), "-g", registry, "-p", repository)
	var outb, errb bytes.Buffer
	cmd.Stdout = &outb
	cmd.Stderr = &errb
	err := cmd.Run()
	if err != nil {
		t.Fatalf("Error running change-image-source.sh: %v\nstderr: %s\nstdout: %s", err, errb.String(), outb.String())
	}
	require.NoError(t, err)
}
