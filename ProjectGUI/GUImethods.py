from os import listdir, walk
import csv
import plotly.graph_objects as go
import datetime
from decimal import Decimal
import plotly
import re


def date_from_webkit(webkit_timestamp):
    epoch_start = datetime.datetime(1601,1,1)
    delta = datetime.timedelta(microseconds=int(webkit_timestamp))
    return datetime.datetime.timestamp(epoch_start + delta)

def roundTime(dt=None, roundTo=60):
   """Round a datetime object to any time lapse in seconds
   dt : datetime.datetime object, default now.
   roundTo : Closest number of seconds to round to, default 1 minute.
   Author: Thierry Husson 2012 - Use it as you want but don't blame me.
   """
   if dt == None : dt = datetime.datetime.now()
   seconds = (dt.replace(tzinfo=None) - dt.min).seconds
   rounding = (seconds+roundTo/2) // roundTo * roundTo
   return dt + datetime.timedelta(0,rounding-seconds,-dt.microsecond)

def get_str_date(string_of_date):
    date_string = string_of_date.split('/')
    date_string.extend(date_string[2].split(' '))
    del date_string[2]
    date_string.extend(date_string[3].split(':'))
    del date_string[3]

    if date_string[3] == 'AM' and date_string[4] == '12':
        date_string[4] = '0'
    elif date_string[3] == 'PM':
        if date_string[4] == '12':
            pass
        else:
            date_string[4] = str(int(date_string[4]) + 12)
    
    del date_string[3]

    string_list = [int(x) for x in date_string]

    date_time = datetime.datetime(string_list[2],string_list[0],string_list[1],string_list[3],string_list[4],string_list[5])
    return date_time

timeconverterswtich = 0

output1 = 'analysisoutput.csv'
output2 = 'graphoutput.csv'
output3 = 'fileoutput.csv'

def remove_ext(filename):
    max_length = 5
    name_len = len(filename)-1
    while name_len > 0 and max_length > 0:
        if filename[name_len] == '.':
            return name_len
        else:
            name_len -= 1
            max_length -= 1
    return -1

def consolidate_csv(path):
    f = {}
    for (dirpath, dirnames, filenames) in walk(path):
        for (dirpath2, dirnames2, filenames2) in walk(dirpath):
            for file in filenames2:
                file_path = dirpath2 + '/' + file
                f.update({file : file_path.replace('\\', '/')})
    return f


#GET ANALYSIS
def merge_csv_analysis(file_dict):
    usable_files = ['chromeHistory.csv', 'chromeDownloads.csv', 'chromeBookmarks.csv', 'mozillaHistory.csv', 'mozillaDownloads.csv', 'mozillaBookmarks.csv', 'getall.csv', 'ieBookmarks.csv']
    with open(output1, 'a', newline='') as csv_test:
        csv_writer = csv.writer(csv_test, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(['title', 'value'])
    for key, value in file_dict.items():
        if key in usable_files:
            count_sentiment(value)
        else:
            continue

def count_sentiment(targetcsv):
    #hardcoded paths to access the wordlist, the target csv, csv column and the output path
    wordlist = 'wordlist.csv'
    targetcsv_column = 'Title'
    return generateScores(wordlist, targetcsv, targetcsv_column, output1)

def generateScores(wordlist, targetcsv, targetcsv_column, output1):
    dict_of_words = {}

    with open(wordlist, 'r') as csv_word:
        csv_worddict = csv.DictReader(csv_word)
        for word in csv_worddict:
            dict_of_words.update({word['word']: {'normalized_value': word['normalized_weight']}})

    with open(targetcsv, 'r') as csv_file:
            csv_filedict = csv.DictReader(csv_file)
            with open(output1, 'a', newline='') as csv_test:
                csv_writer = csv.writer(csv_test, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                try:
                    for row in csv_filedict:
                        sentiment_value = 0

                        originalfilename = row[targetcsv_column]

                        filename = originalfilename

                        ext_ind = remove_ext(filename)
                        if ext_ind != -1:
                            filename = filename[:ext_ind]
                        filename = filename.replace('_', ' ').replace('-', ' ').replace('/', ' ').replace('.', ' ').replace('(', ' ').replace(')', ' ').replace('?', ' ').replace(';', ' ').replace(':', ' ').replace('|', ' ')
                        filename = filename.lower()
                        file_list = filename.split()
                        for word in file_list:
                            if word in dict_of_words.keys():
                                sentiment_value += float(dict_of_words[word]['normalized_value'])
                        if len(file_list) != 0:
                            calculated_weight = sentiment_value
                            if calculated_weight >= 1 :
                                calculated_weight = 1
                            csv_writer.writerow([originalfilename, (calculated_weight)])
                        
                        else:
                            continue
                except:
                    pass


    return


#EXTRACT HISTORY TIMELINE
def merge_csv_timeline(file_dict):
    global timeconverterswtich
    usable_files = ['chromeTimeline.csv', 'mozillaTimeline.csv']
    with open(output2, 'a', newline='') as csv_test:
        csv_writer = csv.writer(csv_test, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(['title', 'value','time','analysis', 'url'])
    for key, value in file_dict.items():
        if key in usable_files:
            if key == 'chromeTimeline.csv':
                timeconverterswtich = 1
            else:
                timeconverterswtich = 0
            count_sentiment_timeline(value)

def count_sentiment_timeline(targetcsv):
    #hardcoded paths to access the wordlist, the target csv, csv column and the output path
    wordlist = 'wordlist.csv'
    targetcsv_column = 'Title'
    return generateScores_timeline(wordlist, targetcsv, targetcsv_column, output2)

def generateScores_timeline(wordlist, targetcsv, targetcsv_column, output):
    dict_of_words = {}
    global timeconverterswtich

    with open(wordlist, 'r') as csv_word:
        csv_worddict = csv.DictReader(csv_word)
        for word in csv_worddict:
            dict_of_words.update({word['word']: {'normalized_value': word['normalized_weight']}})

    with open(targetcsv, 'r') as csv_file:
            csv_filedict = csv.DictReader(csv_file)
            with open(output, 'a', newline='') as csv_test:
                csv_writer = csv.writer(csv_test, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                for row in csv_filedict:
                    sentiment_value = 0

                    originalfilename = row[targetcsv_column]

                    filename = originalfilename

                    ext_ind = remove_ext(filename)
                    if ext_ind != -1:
                        filename = filename[:ext_ind]
                    filename = filename.replace('_', ' ').replace('-', ' ').replace('/', ' ').replace('.', ' ').replace('(', ' ').replace(')', ' ').replace('?', ' ').replace(';', ' ').replace(':', ' ').replace('|', ' ')
                    filename = filename.lower()
                    file_list = filename.split()
                    for word in file_list:
                        re.sub(r'\W+', '', word)
                        if word in dict_of_words.keys():
                            sentiment_value += float(dict_of_words[word]['normalized_value'])
                    if len(file_list) != 0:
                        calculated_weight = sentiment_value
                        if calculated_weight >= 1 :
                            calculated_weight = 1
                        if calculated_weight >= 0.7:
                            analysis = 1
                        elif calculated_weight < 0.3:
                            analysis = -1
                        else:
                            analysis = 0
                        if timeconverterswtich == 0:
                            csv_writer.writerow([originalfilename, (calculated_weight), row['Time'], str(analysis), row['URL']])
                        else:
                            csv_writer.writerow([originalfilename, (calculated_weight), ((date_from_webkit(row['Time']) * 1e6)), str(analysis), row['URL']])
                    else:
                        continue
        

    return
                
def create_history_scatter(graphcsv):
    with open(graphcsv, 'r') as csv_graph:
        csv_graphdict = csv.DictReader(csv_graph)
        
        x_bad = []
        y_bad = []
        bad_hover = []

        x_neutral = []
        y_neutral = []
        neutral_hover = []

        x_good = []
        y_good = []
        good_hover = []

        for item in csv_graphdict:
            timestamp = (float(item['time']))
            date_time = datetime.datetime.fromtimestamp(timestamp/1e6)
            date_time += datetime.timedelta(hours=9)

            if int(item['analysis']) == 1:
                x_bad.append(date_time.date())
                y_bad.append(date_time.replace(year=1,month=1,day=1))
                hover_string = 'Title: <b>'+ item['title'] + '</b>'
                hover_string += '<br>Date: <b>' + str(date_time.date()) + '</b><br>'
                hover_string += 'Time: <b>' + str(date_time.time()) + '</b>'
                bad_hover.append(hover_string)
            elif int(item['analysis']) == 0:
                x_neutral.append(date_time.date())
                y_neutral.append(date_time.replace(year=1,month=1,day=1))
                hover_string = 'Title: <b>'+ item['title'] + '</b>'
                hover_string += '<br>Date: <b>' + str(date_time.date()) + '</b><br>'
                hover_string += 'Time: <b>' + str(date_time.time()) + '</b>'
                neutral_hover.append(hover_string)
            else:
                x_good.append(date_time.date())
                y_good.append(date_time.replace(year=1,month=1,day=1))
                hover_string = 'Title: <b>'+ item['title'] + '</b>'
                hover_string += '<br>Date: <b>' + str(date_time.date()) + '</b><br>'
                hover_string += 'Time: <b>' + str(date_time.time()) + '</b>'
                good_hover.append(hover_string)

        layout = go.Layout(yaxis={'type': 'date','tickformat': '%H:%M:%S'})

        fig = go.Figure(
            layout=layout
        )


        fig.add_trace(go.Scatter(
            x=x_bad,
            y=y_bad,
            mode='markers',
            name="Malicious",
            hovertext=bad_hover,
            hoverinfo="text",
            marker=dict(
                color="red"
            ),
            
            showlegend=True
        ))
        fig.add_trace(go.Scatter(
            x=x_neutral,
            y=y_neutral,
            mode='markers',
            name="Neutral",
            hovertext=neutral_hover,
            hoverinfo="text",
            marker=dict(
                color="green"
            ),
            
            showlegend=True
        ))
        fig.add_trace(go.Scatter(
            x=x_good,
            y=y_good,
            mode='markers',
            name="Harmless",
            hovertext=good_hover,
            hoverinfo="text",
            marker=dict(
                color="blue"
            ),
            
            showlegend=True
        ))

        div_hist = plotly.offline.plot(fig, show_link=False, output_type="div", include_plotlyjs=True)

        # fig.show()

        return div_hist
