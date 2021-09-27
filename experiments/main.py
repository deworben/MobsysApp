import os
from pathlib import Path
import json
from youtube_dl import YoutubeDL
from pydub import AudioSegment
import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt


# BUG:
# 1. Currently only train set is being used.

# NOTE:
# 1. We may train on other categories of sound in the future.


# program configurations
categories = ["Laughter", "Chatter"]


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
    for c in categories:
        Path("./audio/" + c).mkdir(parents=True, exist_ok=True)
        downloader = YoutubeDL({ 'format':'m4a', 
                                    "outtmpl": "./audio/" + c + "/%(id)s.%(ext)s" })
        fails = 0
        for m in train_metadata[c]:
            if not Path("./audio/{c}/{m[0]}.m4a").exists():
                try:
                    downloader.extract_info(f"https://youtu.be/{m[0]}")
                except:
                    fails += 1
                    print(f"Download failed, total failures in category {c} is {fails}.")


# crop the audio to desired length
def crop():
    for c in categories:
        Path("./processed/" + c).mkdir(parents=True, exist_ok=True)
        for n in os.listdir(f"./audio/{c}"):
            print(f"Cropping {n} in {c}.")
            audio = AudioSegment.from_file(f"./audio/{c}/{n}")
            yid = n.rstrip(".m4a")
            start = 0
            end = 0
            for m in train_metadata[c]:
                if m[0] == yid:
                    start = m[1] * 1000
                    end = m[2] * 1000
            subsequence = audio[start:end]
            subsequence.export(f"./processed/{c}/{yid}.mp3", format="mp3")


# audio to mfcc features 
def mfcc():
    for c in categories:
        Path("./mfcc/" + c).mkdir(parents=True, exist_ok=True)
        for n in os.listdir(f"./processed/{c}"):
            print(f"Extracting MFCC for {n}")
            try:
                x, sr = librosa.load(f"./processed/{c}/{n}")
            except:
                print("MFCC cannot load.")
                continue
            n = n.rstrip(".mp3")
            with open(f"./mfcc/{c}/{n}.mfcc", "w+") as f:
                json.dump(librosa.feature.mfcc(x, sr=sr).tolist(), f)


# audio to spectrogram
def spectrogram():
    for c in categories:
        Path("./spectrogram/" + c).mkdir(parents=True, exist_ok=True)
        for n in os.listdir(f"./processed/{c}"):
            print(f"Extracting spectrogram for {n}")
            try:
                x, sr = librosa.load(f"./processed/{c}/{n}")
            except:
                print("Spectrogram cannot load.")
                continue
            n = n.rstrip(".mp3")
            with open(f"./spectrogram/{c}/{n}.spectro", "w+") as f:
                X = librosa.stft(x)
                json.dump(librosa.amplitude_to_db(abs(X)).tolist(), f)



# uncomment the following line to download raw audio files
# download()

# uncomment the following line to crop audio files
# crop()

# uncomment the following line to cache mfcc features
# mfcc()

# uncomment the following line to cache spectrogram features
# spectrogram()
