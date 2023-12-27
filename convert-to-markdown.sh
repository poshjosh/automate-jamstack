#!/bin/bash

printf "\nEnter extension of files to convert to markdown e.g pdf\n"

read FILE_EXTENSION

dir=$(pwd)

printf "\nWorking directory: %s\n" "$dir"

declare -i convert_count=0

IFS=$'\n'; set -f
for f in $(find "$dir" -name "*.$FILE_EXTENSION"); do
  printf "\nSource: %s" "$f"
  fdate=$(date -r "$f" "+%Y/%m/%d")
  fdir="blog/$fdate"
  cd "$dir" || exit 1
  mkdir -p "$fdir"
  new_dir="$dir/$fdir"
  new_file=$(echo "${f%.*}.md" | sed -e "s^${dir}^${new_dir}^g")
  new_filename=$(basename "$new_file")
  new_file="$new_dir/$new_filename"
  printf "\nTarget: %s\n" "$new_file"
  pandoc --standalone --table-of-contents=true --from "$FILE_EXTENSION" --to markdown_strict "$f" --output "$new_file"
  convert_count=$((convert_count+1))
done
unset IFS; set +f

printf "\nConverted %s files to markdown\n" "$convert_count"