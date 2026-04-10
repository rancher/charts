#!/bin/bash
set -e

ACTION_FILE=".github/actions/dependencies/action.yaml"
TEMP_DIR=$(mktemp -d)

# Package mapping: package_name:binary_path:yaml_display_name
declare -A PACKAGES=(
  ["docker"]="/usr/bin/docker:Docker"
  ["jq"]="/usr/bin/jq:jq"
  ["git"]="/usr/bin/git:git"
  ["make"]="/usr/bin/make:make"
  ["go"]="/usr/bin/go:go"
  ["patch"]="/usr/bin/patch:patch"
  ["gawk"]="/usr/bin/gawk:gawk"
)

# GitHub release packages: package_name:install_path:yaml_display_name:repo:asset_pattern
declare -A GITHUB_PACKAGES=(
  ["yq"]="/usr/bin/yq:yq:mikefarah/yq:yq_linux_amd64"
  ["gh"]="/usr/bin/gh:gh:cli/cli:gh_{VERSION}_linux_amd64.tar.gz"
)

echo "================================================================="
echo "Dependency Version Update Script"
echo "================================================================="
echo ""

# Function to extract current values from YAML
get_current_version() {
  local display_name=$1
  grep -A 5 "name: Install $display_name" "$ACTION_FILE" | \
    grep "PACKAGE_VERSION:" | \
    sed 's/.*PACKAGE_VERSION: "\(.*\)"/\1/'
}

get_current_checksum() {
  local display_name=$1
  grep -A 5 "name: Install $display_name" "$ACTION_FILE" | \
    grep "EXPECTED_CHECKSUM:" | \
    sed 's/.*EXPECTED_CHECKSUM: "\(.*\)"/\1/'
}

get_current_yq_version() {
  local display_name=$1
  grep -A 5 "name: Install $display_name" "$ACTION_FILE" | \
    grep "YQ_VERSION:" | \
    sed 's/.*YQ_VERSION: "\(.*\)"/\1/'
}

get_current_gh_version() {
  local display_name=$1
  grep -A 5 "name: Install $display_name" "$ACTION_FILE" | \
    grep "GH_VERSION:" | \
    sed 's/.*GH_VERSION: "\(.*\)"/\1/'
}

# Step 1: Launch all docker containers in parallel
echo "Step 1: Fetching latest versions from BCI container..."
echo ""

pids=()
for pkg in "${!PACKAGES[@]}"; do
  IFS=':' read -r binary_path display_name <<< "${PACKAGES[$pkg]}"

  (
    docker run --rm --name "bci-base_$pkg" registry.suse.com/bci/bci-base:latest bash -c "
      zypper --non-interactive refresh &>/dev/null
      zypper --non-interactive install $pkg &>/dev/null
      rpm -q $pkg
      sha256sum $binary_path | cut -d' ' -f1
    " > "$TEMP_DIR/$pkg.txt" 2>&1

    # Read results and print completion
    version=$(head -1 "$TEMP_DIR/$pkg.txt")
    checksum=$(tail -1 "$TEMP_DIR/$pkg.txt")

    echo "bci-base_$pkg container finished:"
    echo "$pkg version: $version"
    echo "$pkg checksum: $checksum"
    echo "----------------------------------------------"
  ) &

  pids+=($!)
done

# Fetch GitHub release packages in parallel
for pkg in "${!GITHUB_PACKAGES[@]}"; do
  IFS=':' read -r install_path display_name repo asset_pattern <<< "${GITHUB_PACKAGES[$pkg]}"

  (
    # Get latest release version from GitHub API
    latest_version=$(curl -s https://api.github.com/repos/$repo/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

    # Remove 'v' prefix if present for gh version number
    version_number=${latest_version#v}

    # Replace {VERSION} placeholder in asset pattern
    asset_name=$(echo "$asset_pattern" | sed "s/{VERSION}/$version_number/g")

    # Download asset and calculate checksum
    docker run --rm registry.suse.com/bci/bci-base:latest bash -c "
      curl -sL https://github.com/$repo/releases/download/${latest_version}/${asset_name} -o /tmp/${pkg}_asset
      echo \"$latest_version\"
      sha256sum /tmp/${pkg}_asset | cut -d' ' -f1
    " > "$TEMP_DIR/$pkg.txt" 2>&1

    # Read results and print completion
    version=$(head -1 "$TEMP_DIR/$pkg.txt")
    checksum=$(tail -1 "$TEMP_DIR/$pkg.txt")

    echo "github-release_$pkg container finished:"
    echo "$pkg version: $version"
    echo "$pkg checksum: $checksum"
    echo "----------------------------------------------"
  ) &

  pids+=($!)
done

# Wait for all background jobs to complete
echo "Fetching in parallel (7 zypper + $(echo ${#GITHUB_PACKAGES[@]}) github packages)..."
echo ""

for pid in "${pids[@]}"; do
  wait "$pid"
done

echo ""
echo "All fetches completed!"
echo ""

# Step 2: Parse results and build comparison table
declare -A CURRENT_VERSIONS
declare -A CURRENT_CHECKSUMS
declare -A NEW_VERSIONS
declare -A NEW_CHECKSUMS

for pkg in "${!PACKAGES[@]}"; do
  IFS=':' read -r binary_path display_name <<< "${PACKAGES[$pkg]}"

  # Get current values from YAML
  CURRENT_VERSIONS[$pkg]=$(get_current_version "$display_name")
  CURRENT_CHECKSUMS[$pkg]=$(get_current_checksum "$display_name")

  # Get new values from docker output
  NEW_VERSIONS[$pkg]=$(head -1 "$TEMP_DIR/$pkg.txt")
  NEW_CHECKSUMS[$pkg]=$(tail -1 "$TEMP_DIR/$pkg.txt")
done

# Parse GitHub release packages
for pkg in "${!GITHUB_PACKAGES[@]}"; do
  IFS=':' read -r install_path display_name repo asset_pattern <<< "${GITHUB_PACKAGES[$pkg]}"

  # Get current values from YAML (use package-specific version getter)
  if [[ "$pkg" == "yq" ]]; then
    CURRENT_VERSIONS[$pkg]=$(get_current_yq_version "$display_name")
  elif [[ "$pkg" == "gh" ]]; then
    CURRENT_VERSIONS[$pkg]=$(get_current_gh_version "$display_name")
  fi
  CURRENT_CHECKSUMS[$pkg]=$(get_current_checksum "$display_name")

  # Get new values from docker output
  NEW_VERSIONS[$pkg]=$(head -1 "$TEMP_DIR/$pkg.txt")
  NEW_CHECKSUMS[$pkg]=$(tail -1 "$TEMP_DIR/$pkg.txt")
done

# Display comparison table
echo "================================================================="
echo "Dependency Comparison"
echo "================================================================="
echo ""

printf "%-8s | %-30s | %-30s | %-13s\n" "Package" "Current Version" "Latest Version" "Should Update"
printf "%s\n" "--------------------------------------------------------------------------------------------"

CHANGES_DETECTED=0
for pkg in docker jq git make go patch gawk yq gh; do
  current_ver="${CURRENT_VERSIONS[$pkg]}"
  new_ver="${NEW_VERSIONS[$pkg]}"
  current_sum="${CURRENT_CHECKSUMS[$pkg]}"
  new_sum="${NEW_CHECKSUMS[$pkg]}"

  # Detect changes
  if [[ "$current_ver" != "$new_ver" ]] || [[ "$current_sum" != "$new_sum" ]]; then
    CHANGES_DETECTED=1
    should_update="yes"
  else
    should_update="no"
  fi

  # Truncate for display (keep first 30 chars for version)
  current_ver_short="${current_ver:0:30}"
  new_ver_short="${new_ver:0:30}"

  printf "%-8s | %-30s | %-30s | %-13s\n" \
    "$pkg" \
    "$current_ver_short" \
    "$new_ver_short" \
    "$should_update"
done

echo ""

# Step 3: Ask for confirmation
if [[ $CHANGES_DETECTED -eq 0 ]]; then
  echo "================================================================="
  echo "✓ No changes detected. All packages are up to date."
  echo "================================================================="
  rm -rf "$TEMP_DIR"
  exit 0
fi

echo "================================================================="
read -p "Apply these changes to $ACTION_FILE? [(Y)es/(n)o]: " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted. No changes made."
  rm -rf "$TEMP_DIR"
  exit 0
fi

# Cleanup temp directory
rm -rf "$TEMP_DIR"

# Step 4: Apply changes
echo ""
echo "Applying changes..."

for pkg in "${!PACKAGES[@]}"; do
  IFS=':' read -r binary_path display_name <<< "${PACKAGES[$pkg]}"

  current_ver="${CURRENT_VERSIONS[$pkg]}"
  new_ver="${NEW_VERSIONS[$pkg]}"
  current_sum="${CURRENT_CHECKSUMS[$pkg]}"
  new_sum="${NEW_CHECKSUMS[$pkg]}"

  if [[ "$current_ver" != "$new_ver" ]] || [[ "$current_sum" != "$new_sum" ]]; then
    echo "  Updating $pkg..."

    # Escape special characters for sed
    current_ver_escaped=$(echo "$current_ver" | sed 's/[\/&]/\\&/g')
    new_ver_escaped=$(echo "$new_ver" | sed 's/[\/&]/\\&/g')
    current_sum_escaped=$(echo "$current_sum" | sed 's/[\/&]/\\&/g')
    new_sum_escaped=$(echo "$new_sum" | sed 's/[\/&]/\\&/g')

    # Update version
    sed -i "/- name: Install $display_name/,/BINARY_PATH:/ s/PACKAGE_VERSION: \"$current_ver_escaped\"/PACKAGE_VERSION: \"$new_ver_escaped\"/" "$ACTION_FILE"

    # Update checksum
    sed -i "/- name: Install $display_name/,/BINARY_PATH:/ s/EXPECTED_CHECKSUM: \"$current_sum_escaped\"/EXPECTED_CHECKSUM: \"$new_sum_escaped\"/" "$ACTION_FILE"
  fi
done

# Update GitHub release packages
for pkg in "${!GITHUB_PACKAGES[@]}"; do
  IFS=':' read -r install_path display_name repo asset_pattern <<< "${GITHUB_PACKAGES[$pkg]}"

  current_ver="${CURRENT_VERSIONS[$pkg]}"
  new_ver="${NEW_VERSIONS[$pkg]}"
  current_sum="${CURRENT_CHECKSUMS[$pkg]}"
  new_sum="${NEW_CHECKSUMS[$pkg]}"

  if [[ "$current_ver" != "$new_ver" ]] || [[ "$current_sum" != "$new_sum" ]]; then
    echo "  Updating $pkg..."

    # Escape special characters for sed
    current_ver_escaped=$(echo "$current_ver" | sed 's/[\/&]/\\&/g')
    new_ver_escaped=$(echo "$new_ver" | sed 's/[\/&]/\\&/g')
    current_sum_escaped=$(echo "$current_sum" | sed 's/[\/&]/\\&/g')
    new_sum_escaped=$(echo "$new_sum" | sed 's/[\/&]/\\&/g')

    # Determine version variable name based on package
    if [[ "$pkg" == "yq" ]]; then
      version_var="YQ_VERSION"
    elif [[ "$pkg" == "gh" ]]; then
      version_var="GH_VERSION"
    fi

    # Update version
    sed -i "/- name: Install $display_name/,/INSTALL_PATH:/ s/${version_var}: \"$current_ver_escaped\"/${version_var}: \"$new_ver_escaped\"/" "$ACTION_FILE"

    # Update checksum
    sed -i "/- name: Install $display_name/,/INSTALL_PATH:/ s/EXPECTED_CHECKSUM: \"$current_sum_escaped\"/EXPECTED_CHECKSUM: \"$new_sum_escaped\"/" "$ACTION_FILE"
  fi
done

echo ""
echo "================================================================="
echo "✓ Changes applied successfully!"
echo "================================================================="
echo ""
echo "Review changes with:"
echo "  git diff $ACTION_FILE"
echo ""
echo "Test the changes with:"
echo "  act -j test-dependencies --container-architecture linux/amd64"
echo ""
