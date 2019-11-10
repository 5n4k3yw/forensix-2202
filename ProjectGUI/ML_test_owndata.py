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

#used to reproduce same result every time if the script is kept consistent
# otherwise each run will produce different results
np.random.seed(500)


#get training data from reading from csv
#do remember to change to the path of the csv that contains all of the information after going through textual analysis
testing_corpus = pd.read_csv("analysisoutput.csv",encoding='latin-1')#testing data
print("Read CSV file to be tested.... \n")
# Step 1 of Data Preprocessing : 
# Drop rows with any empty cells
testing_corpus.dropna(axis=0, how='any', thresh=None, subset=None, inplace=True)

# Step 2 of Data Preprocessing: 
#Change all the text to lower case. This is required as python interprets 'dog' and 'DOG' differently
testing_corpus['title'] = [entry.lower() for entry in testing_corpus['title']]


# Step 3 of Data Preprocessing: 
#Tokenization : In this each entry in the corpus will be broken into set of words
testing_corpus['title']= [word_tokenize(entry) for entry in testing_corpus['title']]


#Step 4 of Data Preprocessing:
# Check if word is not part of stop words list & check that word only contains alpha
# If true to both, then add the word to list of finalized words which will replace the original words in first column
# But in the event that there is no words in the list of finalized words, means that all of the words are stop words
# and we will remove that entry
for index,entry in enumerate(testing_corpus['title']):
    # Declaring Empty List to store the words that follow the rules for this step
    Final_words = []
    for word in entry:
        if word not in stopwords.words('english') and word.isalpha():
            Final_words.append(word)
    if len(Final_words) > 0:
        testing_corpus.loc[index,'title'] = str(Final_words)        
    else:
        # Delete row
        testing_corpus = testing_corpus.drop(index)

#load back vectorization that was first initialised when model is being trained
Tfidf_vect= pickle.load(open("vector.pickel", "rb"))
print("Loading TF-IDF Vectorization.... \n")

# Split dataset into training and testing, but since the value of parameter train_size == None, means all of the data 
# will be used for testing. 
# X are indepedent values (testing_corpus['filename']) which are the inputs to be analyzed
# & Y are dependent values (testing_corpus['value']) which are the outputs/results of the process
unseen_train_X, unseen_test_X, unseen_train_Y, unseen_test_Y = model_selection.train_test_split(testing_corpus['title'], testing_corpus['value'],train_size=None)
print("Testing Data is formed.... \n")

# normalize labels ( Encode labels with value between 0 and n_classes-1. )
Encoder = LabelEncoder()
# Fit label encoder (in this case, it will be our weightage values) and return encoded labels
unseen_test_Y = Encoder.fit_transform(unseen_test_Y)



# Transform the independent testing values into their vectorized form,
# so that each row will have a list of its unique int and associated value from TF-IDF
Test_X_Tfidf = Tfidf_vect.transform(unseen_test_X)



# load the saved trained model from disk
loaded_model = joblib.load('finalized_model.sav')
print("Loading Pre-trained Model.... \n")

#predicts the targeted values of unseen independent values
result = loaded_model.predict(Test_X_Tfidf)
print("Predicting classes....... \n")


# get Accuracy classification score.
# accuracy_score(Ground truth (correct) labels, Predicted labels, as returned by a classifier)
# Ground truth --> unseen dependent values
# Predicted labels --> whatever the model predicts
print("Accuracy of your analysis: ",accuracy_score(unseen_test_Y, result)*100)






