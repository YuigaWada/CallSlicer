#I'm a swift dev so i want to use lower camel case ... :(
# This code is uploaded at https://github.com/YuigaWada/GetBundleId

import urllib.request, json, re
from urllib.parse import urlparse


pattern = "id([0-9]+)"
header = "https://itunes.apple.com/lookup?id="
def get_bundleid(target_url):
    raw_url = remove_query(target_url)
    search_id = re.compile(pattern).search(raw_url)

    if not search_id:
        return None


    app_id = search_id.group(1)
    if app_id.isdecimal():
        json_url  = header+app_id

        # print("loading "+json_url+" ...")
        with urllib.request.urlopen(json_url) as url:
            data = json.loads(url.read().decode())

            results = []
            for result in data["results"]:
                results.append(result["bundleId"])

            return results

    return None

def remove_query(target_url):
    o = urlparse(target_url)
    return o.scheme + "://" + o.netloc + o.path

def main():
    print("Input URL of your target app (in the App Store): ")
    text = str(input().split())
    bundleids = get_bundleid(text)

    if bundleids:
        for bundleid in bundleids:
            print("\n\nBundleId: " + bundleid)
    else:
        print("invaild url")



main()
