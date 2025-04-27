#!/bin/bash

# ANSI color codes
export BOLD="\e[1m"
export RED="\e[31m"
export GREEN="\e[32m"
export YELLOW="\e[33m"
export BLUE="\e[34m"
export MAGENTA="\e[35m"
export CYAN="\e[36m"
export RESET="\e[0m"

# Function to display section headers
section() {
  echo -e "\n${BOLD}${CYAN}== $1 ==${RESET}\n"
}

# Function to display error messages and exit
error() {
  echo -e "${RED}ERROR: $1${RESET}" >&2
  exit 1
}

# Function to display success messages
success() {
  echo -e "${GREEN}✓ $1${RESET}"
}

# Function to display info messages
info() {
  echo -e "${BLUE}ℹ $1${RESET}"
}

# Function to display warning messages
warning() {
  echo -e "${YELLOW}⚠ $1${RESET}"
}

# Function to display progress messages
progress() {
  echo -e "${MAGENTA}→ $1${RESET}"
}
