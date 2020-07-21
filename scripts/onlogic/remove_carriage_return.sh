#! /bin/bash

find "$1" -type d | xargs -I% mkdir -p "/tmp/%"
find "$1" -type f | while read -r file; do
   desc=$(file "$file")
   if [[ "$desc" =~ 'ASCII text' && "$desc" =~ 'with CRLF line terminators' ]]; then
      echo "Converting file: $file"
      cat "$file" | tr -d '\r' > "/tmp/$file"
      mv "/tmp/$file" "$file"
   fi
done
