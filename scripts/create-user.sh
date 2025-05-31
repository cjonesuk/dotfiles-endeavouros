#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "CREATE USER"
echo

# --- Sanity Checks ---
# 1. Check if running as root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script must be run as root. Please use sudo." >&2
  exit 1
fi

# --- Get User Information ---
# 2. Prompt for username
read -r -p "Enter the username for the new user: " username

# Validate username
if [[ -z "$username" ]]; then
  echo "Username cannot be empty." >&2
  exit 1
fi

if [[ "$username" =~ [^a-zA-Z0-9_-] ]]; then
    echo "Username contains invalid characters. Only use letters, numbers, underscores, and hyphens." >&2
    exit 1
fi

# Check if user already exists
if id "$username" &>/dev/null; then
  echo "User '$username' already exists." >&2
  exit 1
fi

# 3. Prompt for password (silently)
read -r -s -p "Enter password for $username: " password
echo # Add a newline after the silent prompt
if [[ -z "$password" ]]; then
  echo "Password cannot be empty." >&2
  exit 1
fi

read -r -s -p "Confirm password: " password_confirm
echo # Add a newline
if [[ "$password" != "$password_confirm" ]]; then
  echo "Passwords do not match." >&2
  exit 1
fi

# --- Create User and Set Password ---
echo "Creating user '$username'..."

# Create the user:
# -m: Create the home directory.
# -k /dev/null: Use /dev/null as the skeleton directory. This ensures
#               that /etc/skel contents are NOT copied, resulting in an empty home dir.
# -s SHELL: Set the login shell.
# username: The name of the user.
if useradd -m -k /dev/null -s "$DEFAULT_SHELL" "$username"; then
  echo "User '$username' created successfully."
  echo "Home directory: /home/$username (should be empty)"
else
  echo "ERROR: Failed to create user '$username'." >&2
  exit 1
fi

# Set the password for the new user
echo "Setting password for '$username'..."
if echo "$username:$password" | chpasswd; then
  echo "Password for '$username' set successfully."
else
  echo "ERROR: Failed to set password for '$username'." >&2
  # Optional: Clean up by deleting the user if password setting fails
  # userdel -r "$username"
  # echo "User '$username' has been removed due to password setting failure."
  exit 1
fi


sudo usermod -aG datasharers $username

echo "--- User '$username' creation complete ---"

echo
echo "Done!"
echo
