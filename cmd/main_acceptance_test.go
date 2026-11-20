//go:build acceptance

package main

import (
	"os"
	"os/exec"
	"testing"
)

func TestAcceptance_Add_PrintsOutput(t *testing.T) {
	binary := dummyBinary(t)

	cmd := exec.Command(binary)
	output, err := cmd.CombinedOutput()

	if err != nil {
		t.Fatalf("Failed to run command: %v", err)
	}

	expected := "5 + 3 = 8\n"
	if string(output) != expected {
		t.Errorf("Expected output %q, but got %q", expected, string(output))
	}
}

func dummyBinary(t *testing.T) string {
	t.Helper()
	binary := os.Getenv("DUMMY_BINARY")

	if binary == "" {
		t.Fatal("DUMMY_BINARY environment variable is not set; run via make test-acceptance")
	}

	return binary
}
