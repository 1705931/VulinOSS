import requests
from pprint import pprint
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--owner", "-o", type=str, dest="owner", required=False)
parser.add_argument("--reponame", "-r", type=str, dest="reponame", required=False)
args = parser.parse_args()
print(args)
owner = args.owner
repo_name = args.reponame

API_URL = "https://api.github.com"
r = requests.get(API_URL+"/repos/"+owner+"/"+repo_name+"/languages")
pprint(r.json())
