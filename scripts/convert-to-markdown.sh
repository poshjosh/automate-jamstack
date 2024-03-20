#!/usr/bin/env bash

set -euo pipefail

#@echo off

# Usage: ./<script-file>.sh -d <DIR> -e <EXT> -f <FILE> -s <true|false, skip run> -v <true|false, verbose>

function getScriptDir() {
  local script_path="${BASH_SOURCE[0]}"
  local script_dir;
  while [ -L "${script_path}" ]; do
    script_dir="$(cd -P "$(dirname "${script_path}")" >/dev/null 2>&1 && pwd)"
    script_path="$(readlink "${script_path}")"
    [[ ${script_path} != /* ]] && script_path="${script_dir}/${script_path}"
  done
  script_path="$(readlink -f "${script_path}")"
  cd -P "$(dirname -- "${script_path}")" >/dev/null 2>&1 && pwd
}

DIR=$(getScriptDir)
EXT='docx'
SKIP_CONVERT=false
VERBOSE=false

while getopts d:e:f:s:v: flag
do
    case "${flag}" in
        d) DIR=${OPTARG};;
        e) EXT=${OPTARG};;
        f) FILE=${OPTARG};;
        s) SKIP_CONVERT=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        *) exit 1;;
    esac
done

[ "${VERBOSE}" = "true" ] || [ "$VERBOSE" = true ] && set -o xtrace

dir="${DIR:-.}"

printf "\nWorking directory: %s\n" "$dir"

declare -i convert_count=0

unwanted_prefix="~$"

function getFileExtension() {
  filename=$(basename -- "$1")
  echo "${filename##*.}"
}

function convertFile() {
  local f="$1"
  printf "\nSource: %s" "$f"
  filename=$(basename "$f")
  if [[ "$filename" == "$unwanted_prefix"* ]]; then
    printf "\nSkipping conversion due to unwanted prefix: %s\n" "$f"
    return
  fi

  fdate=$(date -r "$f" "+%Y/%m/%d")
  fdir="blog/$fdate"
  cd "$dir" || (printf "\nFailed to change to dir: %s\n" "$dir" && exit 1)
  if [ "${SKIP_CONVERT}" != "true" ] || [ "$SKIP_CONVERT" != true ]; then
    printf "\nCreating: %s\n" "$dir"
    mkdir -p "$fdir"
  fi
  new_dir="$dir/$fdir"
  new_file=$(echo "${f%.*}.md" | sed -e "s^${dir}^${new_dir}^1" -e "s/ /-/g")
  new_filename=$(basename "$new_file")
  new_file="$new_dir/$new_filename"

  printf "\nTarget: %s\n" "$new_file"
  if [ "${SKIP_CONVERT}" = "true" ] || [ "$SKIP_CONVERT" = true ]; then
    printf "\nSkipping conversion because SKIP is true: %s\n" "$f"
  else
    if [[ "$EXT" == "txt" ]]; then
      cp "$f" "${new_file}"
    else
      pandoc --standalone --table-of-contents=true --from "$EXT" --to markdown_strict "$f" --output "$new_file"
    fi
  fi

  convert_count=$((convert_count+1))
}

if [ -z ${FILE+x} ] || [ "$FILE" == '' ]; then
  IFS=$'\n'; set -f
  for f in $(find "$dir" -name "*.$EXT"); do
    convertFile "$f"
  done
  unset IFS; set +f
else
  EXT=$(getFileExtension "$FILE")
  convertFile "$FILE"
fi

printf "\nConverted %s files to markdown" "$convert_count"
printf "\nSUCCESS\n"
