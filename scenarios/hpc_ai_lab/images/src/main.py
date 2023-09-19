# imports
import os
import mlflow
import argparse
import zipfile

import torch
import torch.nn as nn
import torch.nn.functional as F

import pandas as pd
import matplotlib.pyplot as plt

from sklearn.metrics import accuracy_score
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from azure.storage.blob import BlobServiceClient


#from network import SimpleMLP

# define network(s)
class SimpleMLP(nn.Module):
    def __init__(self):
        super(SimpleMLP, self).__init__()
        self.l1 = nn.Linear(4, 16)
        self.l2 = nn.Linear(16, 16)
        self.l3 = nn.Linear(16, 3)

    def forward(self, x):
        x = F.relu(self.l1(x))
        x = F.relu(self.l2(x))
        x = F.softmax(self.l3(x), dim=1)

        return x

# define functions
def main(args):
    # read in data
    df = pd.read_csv(args.iris_csv)

    # process data
    X_train, X_test, y_train, y_test, enc = process_data(df, args.random_state)

    # train model
    model = train_model(args, X_train, X_test, y_train, y_test)

    # log model
    print(model)

    mlflow.pytorch.save_model(model, "model")
    mlflow.pytorch.log_model(model, "model")

    # evaluate model
    evaluate_model(model, X_train, X_test, y_train, y_test)

    upload_model(args)

def process_data(df, random_state):
    # split dataframe into X and y
    X = df.drop(["species"], axis=1)
    y = df["species"]

    # train/test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=random_state
    )

    X = df.drop(["species"], axis=1).values
    y = df["species"].values

    # label encode species
    enc = LabelEncoder()
    y = enc.fit_transform(y)

    # split into train and test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # initialize and fit scaler
    scaler = StandardScaler()
    scaler = scaler.fit(X_train)

    # apply to X data
    X_train = scaler.transform(X_train)
    X_test = scaler.transform(X_test)

    # move from numpy arrays to torch tensors
    X_train = torch.from_numpy(X_train).float()
    X_test = torch.from_numpy(X_test).float()

    # y tensors long for one-hot encoding
    y_train = torch.from_numpy(y_train).long()
    y_test = torch.from_numpy(y_test).long()

    # one-hot encode
    y_train = F.one_hot(y_train)
    y_test = F.one_hot(y_test)

    # return splits and encoder
    return X_train, X_test, y_train, y_test, enc

def train_model(args, X_train, X_test, y_train, y_test):
    # log parameters
    mlflow.log_param("learning_rate", args.lr)
    mlflow.log_param("epochs", args.epochs)

    # train model
    model = SimpleMLP()
    optimizer = torch.optim.Adam(model.parameters(), lr=args.lr)
    loss_fn = nn.CrossEntropyLoss()

    for epoch in range(args.epochs):
        # get predictions
        y_pred = model(X_train)

        # compute and log loss
        loss = loss_fn(y_pred, torch.max(y_train, 1)[1])
        mlflow.log_metric(f"loss", loss.item(), step=epoch)

        # torch stuff
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

    # return model
    return model

def evaluate_model(model, X_train, X_test, y_train, y_test):
    # compute and log training accuracy
    y_pred = model(X_train)
    y_pred = torch.max(y_pred, 1)[1]
    acc = accuracy_score(y_pred, torch.max(y_train, 1)[1])
    mlflow.log_metric("train_accuracy", acc)

    # compute and log test accuracy
    y_pred = model(X_test)
    y_pred = torch.max(y_pred, 1)[1]
    acc = accuracy_score(y_pred, torch.max(y_test, 1)[1])
    mlflow.log_metric("test_accuracy", acc)

def parse_args():
    # setup arg parser
    parser = argparse.ArgumentParser()

    # add arguments
    parser.add_argument("--iris-csv", type=str)
    parser.add_argument("--lr", type=float, default=0.1)
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--connectionString", type=str)
    parser.add_argument("--containerName", type=str)
    parser.add_argument("--random_state", type=int, default=42)


    # parse args
    args = parser.parse_args()

    # return args
    return args

def upload_model(args):
    print("uploading to blob storage...")
    #storageConnectionInformation
    connectionString = args.connectionString
    containerName = args.containerName

    
    # Establish connection with the blob storage account
    blob_service_client = BlobServiceClient.from_connection_string(connectionString)    
    container_client = blob_service_client.get_container_client(containerName)


    folder_path = "mlruns"
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            local_file_path = os.path.join(root, file)
            blob_name = os.path.relpath(local_file_path, folder_path)  # Blob name will be relative to the folder
            blob_client = container_client.get_blob_client(blob_name)
            
            with open(local_file_path, "rb") as data:
                blob_client.upload_blob(data)
                print(f"Uploaded {blob_name}")


# run script
if __name__ == "__main__":
    # add space in logs
    print("\n\n")
    print("*" * 60)

    # parse args
    args = parse_args()

    # run main function
    main(args)

    # add space in logs
    print("*" * 60)
    print("\n\n")