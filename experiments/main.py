import os
from pathlib import Path
import json
from scipy.ndimage.measurements import label
from tensorflow.python.keras import activations
from youtube_dl import YoutubeDL
from pydub import AudioSegment
import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt
from sklearn import svm
from sklearn.model_selection import cross_val_score
from collections import Counter
import tensorflow as tf
from tensorflow.keras import datasets, layers, models, optimizers
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
import time


# BUG:
# 1. Currently only train set is being used.

# NOTE:
# 1. We may train on other categories of sound in the future.


# program configurations
categories = ["Laughter", "Chatter", "Narration, monologue"]


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
        fnames = os.listdir(f"./audio/{c}")
        for m in train_metadata[c]:
            fname = m[0] + ".m4a"
            if fname not in fnames:
                try:
                    downloader.extract_info(f"https://youtu.be/{m[0]}")
                except:
                    fails += 1
                    print(f"Download failed, total failures in category {c} is {fails}.")
        for m in test_metadata[c]:
            fname = m[0] + ".m4a"
            if fname not in fnames:
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


def load_mfcc():
    features = []
    labels = []
    min_len = 1000 
    for c in categories:
        for n in os.listdir(f"./mfcc/{c}"):
            with open(f"./mfcc/{c}/{n}", "r+") as f:
                feature = np.array(json.load(f))
                min_len = min(min_len, feature.shape[1])
                features.append(feature)
                labels.append(c == "Laughter")
    features = [ f[:,:min_len] for f in features ]
    return np.array(features), labels


def load_spectrogram():
    features = []
    labels = []
    min_len = 1000 
    min_max_scaler = preprocessing.MinMaxScaler()
    for c in categories:
        for n in os.listdir(f"./spectrogram/{c}"):
            with open(f"./spectrogram/{c}/{n}", "r+") as f:
                feature = np.array(json.load(f), dtype=np.float32)
                min_len = min(min_len, feature.shape[1])
                features.append(feature)
                labels.append(c=="Laughter")
    features = [ f[:,:min_len] for f in features ]
    features = [ min_max_scaler.fit_transform(f) for f in features]
    features = np.expand_dims(np.array(features), axis=3)
    print(features)
    return features, np.array(labels)


def svm_mfcc():
    Path("./model/SVM").mkdir(parents=True, exist_ok=True)
    X, y = load_mfcc()
    print(Counter(y))
    X = np.reshape(X, (len(X), -1))
    clf = svm.SVC()
    print(cross_val_score(clf, X, y, cv=10, scoring="precision"))
    print(cross_val_score(clf, X, y, cv=10, scoring="recall"))
    print(cross_val_score(clf, X, y, cv=10))

def cnn_spectro():
    Path("./model/CNN").mkdir(parents=True, exist_ok=True)

    X, y = load_spectrogram()
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=1)

    model = models.Sequential()
    model.add(layers.Conv2D(64, (3, 3), activation='relu', input_shape=(1025, 406, 1)))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(128, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(256, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(512, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(512, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(512, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(512, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(100, activation='relu'))
    model.add(layers.Dense(2, activation="softmax"))

    model.compile(optimizer= optimizers.Adam(learning_rate=0.001),
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=False),
              metrics=['accuracy'])

    history = model.fit(X_train, y_train, epochs=100, batch_size=30,
                    validation_data=(X_test, y_test))
    
    model.save(f"./model/CNN/{time.time_ns()}")

    
# uncomment the following line to download raw audio files
# download()

# uncomment the following line to crop audio files
# crop()

# uncomment the following line to cache mfcc features
# mfcc()

# uncomment the following line to cache spectrogram features
# spectrogram()


# load_mfcc()
# g, l = load_spectrogram()


# svm_mfcc()

cnn_spectro()