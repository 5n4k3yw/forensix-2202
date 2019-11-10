#!/usr/bin/env python
# coding: utf-8

#https://medium.com/@bedigunjit/simple-guide-to-text-classification-nlp-using-svm-and-naive-bayes-with-python-421db3a72d34
import pandas as pd
import numpy as np
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import model_selection, naive_bayes
from sklearn.metrics import accuracy_score
import joblib # must pip install joblib to install as sklearn.externals.joblib is deprecated in 0.21 and will be removed in 0.23., import directly from joblib
import pickle
import sys

#used to reproduce same result every time if the script is kept consistent
# otherwise each run will produce different results
np.random.seed(500)


#get training data from reading from csv
training_corpus = pd.read_csv("analysisoutput_training.csv", encoding='latin-1') #training data
print("Reading CSV file to be analyzed.... \n")

# Step 1 of Data Preprocessing : 
# Drop rows with any empty cells
training_corpus.dropna(axis=0, how='any', thresh=None, subset=None, inplace=True)


# Step 2 of Data Preprocessing: 
#Change all the text to lower case. This is required as python interprets 'dog' and 'DOG' differently
training_corpus['title'] = [entry.lower() for entry in training_corpus['title']]


# Step 3 of Data Preprocessing: 
#Tokenization : In this each entry in the corpus will be broken into set of words
training_corpus['title']= [word_tokenize(entry) for entry in training_corpus['title']]

#Step 4 of Data Preprocessing:
# Check if title is not part of stop words list & check that title only contains alpha
# If true to both, then add the title to list of finalized words which will replace the original words in first column
# But in the event that there is no words in the list of finalized words, means that all of the words are stop words
# and we will remove that entry
for index,entry in enumerate(training_corpus['title']):
    # Declaring Empty List to store the words that follow the rules for this step
    Final_words = []
    for word in entry:
        if word not in stopwords.words('english') and word.isalpha():
            Final_words.append(word)
    if len(Final_words) > 0:
        training_corpus.loc[index,'title'] = str(Final_words)        
    else:
        # Delete row
        training_corpus = training_corpus.drop(index)

print(training_corpus['title'])
#Split dataset into training and testing, but since the value of parameter test_size == None, means all of the data 
# will be used for training. 
# X are indepedent values (training_corpus['title']) which are the inputs to be analyzed
# & Y are dependent values (training_corpus['value']) which are the outputs/results of the process
Train_X, Test_X, Train_Y, Test_Y = model_selection.train_test_split(training_corpus['title'], training_corpus['value'],test_size=None)
print("Training Data is formed....\n")

# normalize labels ( Encode labels with value between 0 and n_classes-1. )
Encoder = LabelEncoder()
# Fit label encoder (in this case, it will be our weightage values) and return encoded labels
Train_Y = Encoder.fit_transform(Train_Y)

# Uses Term Frequency — Inverse Document Vectorization to conduct title vectorizing with 5000 features
Tfidf_vect = TfidfVectorizer(max_features=5000)
# Fit the model with all of the data from dataset
Tfidf_vect.fit(training_corpus['title'])


# now pickle the vectorizatiom (save it so that we will be able to use the same vectorization
# to transform unseen data into documents)
pickle.dump(Tfidf_vect, open("vector.pickel", "wb"))
print("Saving TF-IDF Vectorization.... \n")

#Transform the independent training values into their vectorized form,
# so that each row will have a list of its unique int and associated value from TF-IDF
Train_X_Tfidf = Tfidf_vect.transform(Train_X)


# fit the training dataset on the NB classifier
Naive = naive_bayes.MultinomialNB()
Naive.fit(Train_X_Tfidf,Train_Y)
print("Training Machine Learning Model.... \n")

# save the trained model to disk (to be used later)
filename = 'finalized_model.sav'
joblib.dump(Naive, filename)
print("Saving Pre-trained Model.... \n")

