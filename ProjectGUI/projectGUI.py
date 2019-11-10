from flask import Flask, render_template, Markup, redirect
from tkinter import filedialog
from tkinter import *
from GUImethods import *
import webbrowser
from subprocess import Popen, PIPE, STDOUT, DEVNULL
import html
import sys

import os
try:
    os.remove("analysisoutput.csv") 
except:
    pass
try:
    os.remove("graphoutput.csv") 
except:
    pass
try:
    os.remove("fileoutput.csv") 
except:
    pass

root = Tk()
root.withdraw()
folder_selected = filedialog.askdirectory()

file_dict = consolidate_csv(folder_selected)
merge_csv_analysis(file_dict)
merge_csv_timeline(file_dict)

bad_list = []

with open('analysisoutput.csv', 'r') as results_csv:
    csv_filedict = csv.DictReader(results_csv)
    counter = 0
    sentiment_sum = 0
    for row in csv_filedict:
        if float(row['value']) > 0.95:
            bad_list.append([row['title'], row['value']])
        counter += 1
        sentiment_sum += float(row['value'])
    final_analysis = sentiment_sum/counter*100
    bad_list = sorted(bad_list, key=lambda x:float(x[1]), reverse=True)
        
timeline_graph = create_history_scatter('graphoutput.csv')


app = Flask(__name__, template_folder='gui_html')

@app.route('/')
def main_page():
    return render_template('index.html',  graph=Markup(timeline_graph))

@app.route('/timeline/')
def timeline_page():
    return render_template('timeline.html', history_graph=Markup(timeline_graph))

@app.route('/ml/')
def ml_page():
    ml_list_output = []

    with Popen([sys.executable or 'python','./ML_test_owndata.py'], stdin=DEVNULL, stdout=PIPE, stderr=STDOUT,
               bufsize=1, universal_newlines=True) as p:
        for line in p.stdout:
            ml_list_output.append(line)
    return render_template('ml.html', ml_output=ml_list_output)


@app.route('/exfiltration/')
def exfil_page():
    return render_template('exfiltration.html', counter=counter, sentiment=final_analysis, badlist=bad_list)


if __name__ == '__main__':
    webbrowser.open_new('http://127.0.0.1:5000')
    app.run()

