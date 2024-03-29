#!/bin/bash
set -euo pipefail

# Configuration placeholders
user_id="root"
pass="root"
platform_fqdn="localhost:9452"
update_marker="./.platform_updated"

# Performs a health check on the given URL
perform_health_check() {
  local health_check_url="http://${platform_fqdn}/server/api"
  # Capture the response and only output if there's a failure
  if ! curl --silent --head --fail "${health_check_url}" 2>/dev/null; then
    echo "Health check failed: Unable to connect to ${health_check_url}" >&2
    exit 1
  fi
}

# Converts login and password to a Basic Auth token
get_basic_auth_token() {
  local login="${1}"
  local password="${2}"
  local credentials="${login}:${password}"
  echo -n "${credentials}" | base64
}

# Fetches configuration data from the server
get_config() {
  local token="${1}"
  local config_url="http://${platform_fqdn}/server/api/v3/config"
  local config_response
  config_response=$(curl --silent --show-error --header "Authorization: ${token}" "${config_url}")

  # Ensure the response is valid JSON before passing to jq
  local config_data
  config_data=$(echo "${config_response}" | jq '.data' 2>/dev/null)
  echo "${config_data}"
}

# Obtains configuration data from the server using basic auth
fetch_auth_data() {
  local basic_auth_token
  basic_auth_token=$(get_basic_auth_token "${user_id}" "${pass}")
  local config_data
  config_data=$(get_config "Basic ${basic_auth_token}")

  # Exit if config data is empty
  if [[ -z "${config_data}" ]]; then
    echo "Failed to obtain configuration data" >&2
    exit 1
  fi

  local nodeId
  nodeId=$(echo "${config_data}" | jq -r '.node.nodeId')

  # Exit if nodeId is empty
  if [[ -z "${nodeId}" ]]; then
    echo "Failed to obtain nodeId" >&2
    exit 1
  fi

  echo "${basic_auth_token} ${nodeId}"
}

# Updates policy settings using the provided token and node ID
update_policy_settings() {
  local token="${1}"
  local nodeId="${2}"
  local update_url="http://${platform_fqdn}/server/api/v3/database/property"
  local update_payload='{"propertyId": "PID_POLICY", "property": {"rootSettings": {"values": {"enableUpdates": false, "updateSlot": "local", "updatePath": "https://updates.aparavi.com/updates-dia-aparavi", "updatePublicKeyPath": "https://updates.aparavi.com/public-keys/update_package_key/update_package_public_key.pem"}}}, "objectId": "'"${nodeId}"'"}'

  # Check if the update has already been applied
  if [[ -f "$update_marker" ]]; then
    echo "Update already applied, skipping..."
    return
  fi

  local update_response
  update_response=$(curl --silent --show-error --request POST --header "Content-Type: application/json" --header "Authorization: ${token}" --data "${update_payload}" "${update_url}")

  if [[ "${update_response}" == *"error"* ]]; then
    echo "Error updating policy settings: ${update_response}" >&2
    exit 1
  else
    echo "Policy settings update succeeded."
    # Mark the update as done
    touch "$update_marker"
  fi
}

main() {
  perform_health_check
  IFS=' ' read -r auth_token node_id <<< "$(fetch_auth_data)"
  update_policy_settings "Basic ${auth_token}" "${node_id}"
  exit 0
}

main

