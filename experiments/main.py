# from tensorflow.python.keras.metrics import Precision, Recall
import librosa
from librosa.feature.spectral import mfcc
import numpy as np
import os
from collections import Counter
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses
from tensorflow import lite
import time



def train_CNN(X, y):
    train_count = int(0.8 * X.shape[0])
    X_train = X[:train_count]
    y_train = y[:train_count]
    X_test = X[train_count:]
    y_test = y[train_count:]

    model = models.Sequential()
    model.add(layers.Conv2D(
        128, (3, 3), activation='relu', input_shape=X[0].shape))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(256, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(256, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(300, activation='relu'))
    model.add(layers.Dense(2, activation="softmax"))

    model.summary()
    model.compile(optimizer=optimizers.Adam(learning_rate=0.001),
                  loss=losses.SparseCategoricalCrossentropy(from_logits=False),
                  metrics=['accuracy'])

    model.fit(X_train,
              y_train,
              epochs=30,
              batch_size=10,
              validation_data=(X_test, y_test))

    return model

def load_mfcc(fp, seg_len=1):
    seq, sr = librosa.load(fp)
    n_segs = int(seq.shape[0]/(seg_len*10000))
    seq = seq[:int(n_segs*10000)]
    frames = np.split(seq, n_segs)
    mfccs = [librosa.feature.mfcc(f, sr=sr) for f in frames]
    return mfccs


def load_train():
    true_folder = "./train/laugh"
    false_folder = "./train/talk"

    X = []
    y = []

    for n in os.listdir(true_folder):
        if ".m4a" not in n:
            continue
        mfccs = load_mfcc(true_folder + "/" + n)
        X += mfccs
        y += [ 1 for _ in range(len(mfccs)) ]

    for n in os.listdir(false_folder):
        if ".m4a" not in n:
            continue
        mfccs = load_mfcc(false_folder + "/" + n)
        X += mfccs
        y += [ 0 for _ in range(len(mfccs)) ]

    X = np.array(X)
    y = np.array(y)
    X = np.expand_dims(X, 3)
    P = np.random.permutation(len(X))
    X = X[P]
    y = y[P]
    return X, y


def load_test(fp):
    X = load_mfcc(fp)
    X = np.array(X)
    X = np.expand_dims(X, 3)
    return X


def export(clf, fp):
    tflite_path = "./tflite_models/" + fp
    cvt = lite.TFLiteConverter.from_keras_model(clf)
    M = cvt.convert()
    
    with open(tflite_path, "wb") as f:
        f.write(M)


X_train, y_train = load_train()
X_test = load_test("./test/Mixed.m4a")
print(Counter(y_train))

N = train_CNN(X_train, y_train)
P = np.argmax(N.predict(X_test), axis=-1)
print(P)

model_id = str(time.time_ns()+".tflite")
export(N, model_id)
print(f"TFLITE model saved at ./tflite_model/{model_id}")



