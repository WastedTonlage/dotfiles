#!/usr/bin/python
# Convert normal http notation to a  curl command

import argparse

parser = argparse.ArgumentParser(description="Convert regular HTTP request notation to a cURL command")
parser.add_argument('infile', metavar='I', type=open, help="The HTTP request file to read from")

args = parser.parse_args()
request = args.infile.read()

lines = request.splitlines()

first = lines[0].split()
method = first[0]
url = first[1]

headers = ""
data = ""
splitline = False
for line in lines[1:]:
    if (not splitline):
        if (line == ""):
            splitline = True
        else:
            keyval = line.split( ": " )
            if (keyval[0] == "Host"):
                url = keyval[1] + url
            headers += "-H '" + line + "' "
    else:
        data += line

command = "curl -L -X {} {} -d '{}' {}".format(method, headers, data, url)
print(command)

