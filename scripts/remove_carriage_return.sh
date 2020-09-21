#! /bin/bash

if [ "$2" = "-f" ]; then
    force=TRUE
else 
    force=FALSE
fi
tmp="$(mktemp -d)"
find "$1" -type d | xargs -I% mkdir -p "${tmp}/%"
find "$1" -type f | while read -r file; do
   desc=$(file "$file")
   tmpfile="${tmp}/$file"
   if [[ "$desc" =~ 'with CRLF line terminators' || "$force" = 'TRUE' ]]; then
      echo "Converting file: $file"
      cat "$file" | tr -d '\r' > "$tmpfile"
      chmod --reference="$file" "$tmpfile"
      mv "$tmpfile" "$file"
   fi
done
