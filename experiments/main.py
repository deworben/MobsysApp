from pathlib import Path
import json
from youtube_dl import YoutubeDL, downloader


# reading label descriptions
ontology = {}
ontology_ids = {}
with open("./audioset/ontology.json", "r") as f:
    ontology = json.load(f)
    ontology = { o["name"]: o for o in ontology }
    ontology_ids = { o["id"]: o["name"] for o in ontology.values() }


# reading train video metadata
train_metadata = {}
with open("./audioset/train_metadata.csv", "r") as f:
    line = f.readline()
    while line:
        items = line.strip().split(", ")
        labels = items[3].strip("\"").split(",")
        for l in labels:
            key = ontology_ids[l]
            if key in train_metadata:
                train_metadata[key].append((items[0], float(items[1]), float(items[2])))
            else:
                train_metadata[key] = [(items[0], float(items[1]), float(items[2]))]
        line = f.readline()


# reading test video metadata
test_metadata = {}
with open("./audioset/test_metadata.csv", "r") as f:
    line = f.readline()
    while line:
        items = line.strip().split(", ")
        labels = items[3].strip("\"").split(",")
        for l in labels:
            key = ontology_ids[l]
            if key in test_metadata:
                test_metadata[key].append((items[0], float(items[1]), float(items[2])))
            else:
                test_metadata[key] = [(items[0], float(items[1]), float(items[2]))]
        line = f.readline()


# download audio
def download():
    categories = ["Laughter", "Chatter"]

    for c in categories:
        Path("./audio/" + c).mkdir(parents=True, exist_ok=True)
        downloader = YoutubeDL({ 'format':'m4a', 
                                    "outtmpl": "./audio/" + c + "/%(id)s.%(ext)s" })
        fails = 0
        for m in train_metadata[c]:
            if not Path("./audio/" + c +  + m[0] + ".m4a").exists():
                try:
                    downloader.extract_info("https://youtu.be/" + m[0])
                except:
                    fails += 1
                    print(f"Download failed, total failures in category {c} is {fails}.")

# crop the audio to desired length
# def crop():



# uncomment the following line to download raw audio files
# download()



