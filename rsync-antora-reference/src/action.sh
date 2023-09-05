#!/bin/bash

__action_usage() {
  echo "usage: action.sh [OPTION]...

   --docs-username=USERNAME       the username used to connect to ssh
   --docs-host=HOST               the host to connect to ssh
   --docs-ssh-key=KEY             the private key used to connect to ssh
   --docs-ssh-host-key=HOST_KEY   the host key used to connect to ssh
   --dry-run                      signals that rsync should be in dry run mode
   --site-path=PATH               the local directory path to sync to the server
   --github-repository=REPO       the github repository (e.g. spring-projects/spring-security)
"
}

__action_usage_error() {
  echo "Error: $1" >&2
  __action_usage
  exit 1
}

__action() {
  local docs_username docs_host docs_ssh_key docs_ssh_host_key site_path github_repository valid_args
  local dry_run=false
  valid_args=$(getopt --options '' --long docs-username:,docs-host:,docs-ssh-key:,docs-ssh-host-key:,dry-run,site-path:,github-repository: -- "$@")
  if [[ $? -ne 0 ]]; then
    __action_usage
    exit 1;
  fi

  eval set -- "$valid_args"

  while [ : ]; do
    case "$1" in
      --docs-username)
          docs_username="$2"
          shift 2
          ;;
      --docs-host)
          docs_host="$2"
          shift 2
          ;;
      --docs-ssh-key)
          docs_ssh_key="$2"
          shift 2
          ;;
      --docs-ssh-host-key)
          docs_ssh_host_key="$2"
          shift 2
          ;;
      --dry-run)
          dry_run=true
          shift
          ;;
      --site-path)
          site_path="$2"
          shift 2
          ;;
      --github-repository)
          github_repository="$2"
          shift 2
          ;;
       --) shift;
          break
          ;;
      *)
        __action_usage_error "Invalid argument $1 $2"
        ;;
    esac
  done

  if [ -e $docs_username ]; then
    __action_usage_error "Missing option '--docs-username'"
  fi
  if [ -e $docs_host ]; then
    __action_usage_error "Missing option '--docs-host'"
  fi
  if [ -e $docs_ssh_key ]; then
    __action_usage_error "Missing option '--docs-ssh-key'"
  fi
  if [ -e $docs_ssh_host_key ]; then
    __action_usage_error "Missing option '--docs-ssh-host-key'"
  fi
  if [ -e $site_path ]; then
    __action_usage_error "Missing option '--site-path'"
  fi
  if [ -e $github_repository ]; then
    __action_usage_error "Missing option '--github-repository'"
  fi

  ## Extract repository_name from the owner/repository_name
  local github_repository_name=$(echo ${github_repository} | cut -d '/' -f 2)
  local ssh_private_key_path="$HOME/.ssh/${github_repository:-publish-docs}"
  local ssh_host="${docs_username}@${docs_host}"
  local ssh_host_path="/opt/www/domains/spring.io/docs/htdocs/$github_repository_name/reference/"

  (
    set -e
    set -f

    setup_ssh.sh --ssh-private-key-path "$ssh_private_key_path" --ssh-private-key "$docs_ssh_key" --ssh-known-hosts "$docs_ssh_host_key"
    rsync_docs.sh --ssh-host "$ssh_host" --ssh-host-path "$ssh_host_path" --local-path "$site_path" --ssh-private-key-path "$ssh_private_key_path" --dry-run "$dry_run"
  )
  exit_code=$?

  cleanup_ssh.sh --ssh-private-key-path "$ssh_private_key_path"

  exit $exit_code
}


__action "$@"