import logging
from azure.identity import DefaultAzureCredential
import json
import time
from requests import get, post
import requests

doc_intel_endpoint = "https://<your-doc-intel-name>.cognitiveservices.azure.com"

#v4.0
api_version = "2024-11-30"
model_id = "prebuilt-read"
api_path = "documentintelligence"

# Authenticate to Doc intelligence service using DefaultAzureCredential
credential = DefaultAzureCredential()
token = credential.get_token("https://cognitiveservices.azure.com/.default")

# Prepare to call the Doc Intel endpoint
endpoint = doc_intel_endpoint    
post_url = endpoint + "/" + api_path + "/documentModels/" + model_id + ":analyze?api-version=" + api_version

headers = {
    # Request headers
    'Content-Type': 'application/pdf',
    'Authorization': f'Bearer {token.token}',
    }

# read bytes from ./sample-layout.pdf and place it in the content variable
with open("./sample-layout.pdf", "rb") as f:
    content = f.read()

#################################################
# Request document analysis [POST]
#################################################
print ("\n[POST] Analyze document using: %s ..." % post_url)
resp = requests.post(url=post_url, data=content, headers=headers)
print("[RESPONSE] %d %s " % (resp.status_code, resp.headers))
if resp.status_code != 202:
    print("Failed, quitting")
    quit()

#################################################
# Request document analysis [GET]
#################################################
wait_sec = 25
  # Grab the results using the Url provided in the operation-location header
get_url = resp.headers["operation-location"]
print("\nWaiting %d seconds for results to be ready..." % wait_sec)
 # The API is async therefore the wait statement
time.sleep(wait_sec)
print("\n[GET] Analyze results using: %s ..." % get_url)
resp = requests.get(url=get_url, headers=headers)
print("\n[RESPONSE] %d %s " % (resp.status_code, resp.headers))
  # Grab the returned payload
resp_json = json.loads(resp.text)
status = resp_json["status"]

if status == "succeeded":
    results = resp_json
    print("Analysis succeeded, Writing results to file ./layout_results.json...")
    with open("./layout_results.json", "w") as f:
        json.dump(results, f, indent=2)
else:
    print("Failed, quitting")
    quit()


#################################################
# Delete document analysis result and submitted
# document from the service (purge)
#################################################

print ("\n[DELETE] Analyze results using: %s ..." % get_url)
resp = requests.delete(url=get_url, headers=headers)
print("\n[RESPONSE] %d %s " % (resp.status_code, resp.headers))

if resp.status_code != 204:
    print("Delete Failed, quitting")
    quit()
else:
    print("When a delete is successful, the HTTP return code is 204")


#################################################
# The following step is not necessary
# is just to show that the doc has been deleted
# The proof should be the 204 return code
# from the delete operation
#################################################

print("\nThe following step is NOT necessary, it is just for demonstration purposes")
print("The call below should return a 404 HTTP code, proving the results are gone")
print("[GET] Analyze results using: %s ..." % get_url)
resp = requests.get(url=get_url, headers=headers)
print("\n[RESPONSE] %d %s " % (resp.status_code, resp.headers))
if resp.status_code != 404:
    print("Inspect the return code, it should not be a 2XX")
    quit()
else:
    print("\nResults not found, as EXPECTED!")



print("\nDONE, all steps completed successfully")