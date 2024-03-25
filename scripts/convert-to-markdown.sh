#!/usr/bin/env bash

set -euo pipefail

#@echo off

# Usage: ./<script-file>.sh -d <DIR> -e <EXT> -f <FILE> -s <true|false, skip run> -v <true|false, verbose>

DIR=''
EXT='docx'
FILE=''
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

printf "\nWorking directory: %s\n" "$(pwd)"

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
  cd "$DIR" || (printf "\nFailed to change to dir: %s\n" "$DIR" && exit 1)
  if [ "${SKIP_CONVERT}" != "true" ] || [ "$SKIP_CONVERT" != true ]; then
    printf "\nCreating: %s\n" "$fdir"
    mkdir -p "$fdir"
  fi
  new_dir="$DIR/$fdir"
  new_file=$(echo "${f%.*}.md" | sed -e "s^${DIR}^${new_dir}^1" -e "s/ /-/g")
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

if [ "$FILE" = '' ]; then
  if [ "$DIR" = '' ]; then
    DIR='.'
  fi
  printf "\nOutput directory: %s\n" "$DIR"
  IFS=$'\n'; set -f
  for f in $(find "$DIR" -name "*.$EXT"); do
    convertFile "$f"
  done
  unset IFS; set +f
else
  if [ "$DIR" = '' ]; then
    DIR=$(dirname "$FILE")
  fi
  printf "\nOutput directory: %s\n" "$DIR"
  EXT=$(getFileExtension "$FILE")
  convertFile "$FILE"
fi

printf "\nConverted %s files to markdown" "$convert_count"
printf "\nSUCCESS\n"
