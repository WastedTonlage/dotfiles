#! /usr/bin/env python3.7
'''
Convert all repos from the Inwatec bitbucket to git from mercurial.
All repos which are already present in the same folder as this
program wont be downloaded, so to get the newest versions of the repos
delete all files in the folder, except for convertAll.py, author.txt,
passfile.txt and manualSub.txt.

The program will perform the conversion and ask for manual input on
the few things that cant be automated (primarily author and subrepo
mapping).

Some subrepos wont convert properly for unknown reasons. These
are placed in the file called manualSub.txt and the relations between
them must be created manually after conversion. 
'''
import requests
import json
import subprocess
import os
from requests import auth

with open("author.txt", "r") as authorFile:
    authorlines = authorFile.readlines()
authors = {}
for authorline in authorlines:
    matchpoint = authorline.find("\"=\"")
    authors[authorline[1:matchpoint]] = authorline[matchpoint + 3:-2]

def saveAuthorFile():
    output = ""
    for key, value in authors.items():
        output += '"' + key + '"="' + value + '"\n'
    with open("author.txt", "w") as authorFile:
        authorFile.write(output)

headers = {"content-type": "application/json"}

test = open("test.html", "w")
passwd = open("passFile.txt", "r").read()
manualFile = open("manualSub.txt", "w")
cont = True
repos = []
nextUrl = "https://api.bitbucket.org/2.0/repositories"
while cont:
    requestResponse = requests.get(nextUrl,auth=("akselmads", passwd[:-1]), headers = headers, params={'role': 'member'})
    print(requestResponse.status_code)
    response = json.loads(requestResponse.content.decode("utf-8")  )#Remove newline from passwd
    if ("next" in response.keys()):
        nextUrl = response["next"]
    else:
        cont = False
    print(response["values"][0]["name"])
    for repo in response[ "values" ]:
        if (isinstance(repo, int)):
            continue
        repos.append(repo)
    #print(repoText.content)
for repo in repos:
    print(repo["name"])

addedRepos=[]

def convertRepo(name):
    print("running convertRepo")
    if name in addedRepos:
        return
    for repo in repos:
        if (( not repo["name"].lower() == name.lower() ) or os.path.exists(repo[ "name" ] + "Git")):
            continue
        print(repo["name"])
        if (not os.path.exists(repo["name"])):
            for cloneOption in repo["links"]["clone"]:
                if (cloneOption["name"] == "https"):
                    print("hg clone \"" + cloneOption["href"] + '"')
                    subprocess.run(["hg", "clone", "https://" + cloneOption["href"][cloneOption["href"].find("@")+1:], repo["name"]])
                    break
        if not os.path.exists(repo["name"] + "Git"):
            os.mkdir(repo["name"] + "Git")
        if (os.path.exists(os.path.join(repo["name"], ".hgsub"))):
            hgsub = open(os.path.join(repo["name"], ".hgsub"), "r").readlines()
            mappingFile = open(repo["name"] + "_subrepo_mapping", "w")
            for submodule in hgsub:
                splitPoint = submodule.find(" = ")
                local = submodule[:splitPoint]
                remote = submodule[splitPoint + 3:]
                if remote[-1] == "\n":
                    remote = remote[:-1]
                if (not convertRepo(remote[3:]) ):
                    manualFile.write(repo["name"] + ": " + local + "=" + remote + "\n")
                mappingFile.write('"' + local + '"="' + remote + "Git\"\n")
            mappingFile.close()
        hgLogCommand = subprocess.Popen(["hg", "log"], cwd=repo["name"], stdout=subprocess.PIPE)
        grepCommand = subprocess.Popen(["grep", "user:"], stdin=hgLogCommand.stdout, stdout=subprocess.PIPE)
        sortCommand = subprocess.Popen(["sort"], stdin=grepCommand.stdout, stdout=subprocess.PIPE)
        uniqCommand = subprocess.Popen(["uniq"], stdin=sortCommand.stdout, stdout=subprocess.PIPE)
        repoAuthors = subprocess.check_output(["sed", "s/user: *//"], stdin=uniqCommand.stdout).decode("utf-8").splitlines()
        print(json.dumps(authors))
        for author in repoAuthors:
            if not author in authors:
                newAuthorName = input("Please enter a new mapping for user " + author + ": ") or author
                authors[author] = newAuthorName
        saveAuthorFile()
        subprocess.run(["git", "init"], cwd=repo["name"] + "Git")
        if (os.path.exists(os.path.join(repo["name"], ".hgsub"))):
            subprocess.run(["../fast-export/hg-fast-export.sh", "-r", "../" + repo["name"], "-A", "../author.txt", "--subrepo-map=../" + repo["name"] + "_subrepo_mapping"], cwd=repo["name"] + "Git")
        else:
            subprocess.run(["../fast-export/hg-fast-export.sh", "-r", "../" + repo["name"], "-A", "../author.txt"], cwd=repo["name"] + "Git")
        hasSubs = os.path.exists(os.path.join(repo["name"] + ".gitmodules"))
        #requests.post("https://api.bitbucket.org/2.0/repositories/akselmads" + repo["name"] + "Git", json={"scm":"git", "project": repo["project"]["key"]})
        #subprocess.run(["git", "remote", "add", "origin", ])
        #subprocess.run(["git", "push", "-u", "origin", "master"])
        addedRepos.append(name)
        return hasSubs
    print("ERROR: name not found: " + name)


for repo in repos:
    if (repo["scm"] == "git"):
        continue
    convertRepo(repo["name"])
