# ICT 2202 - Team Forensix

This is a user manual which provides you a guide on how to use our solution. 

## Pre-requisites to use our Tool
```
1. Download Python3
2. Set your system's environment variable for Python3
```

## General Flow of Solution
1. Analyst will use Bash Bunny & load the Powershell scripts into Bash Bunny
2. When Bash Bunny is plugged into a targeted machine, the scripts are executed and collected information are stored in a folder called *loot* which is located in the Bash Bunny.
3. Analyst can disconnect Bash Bunny from targeted machine and & connect back to forensics workstation. 
4. Copy out *loot* folder from Bash Bunny to local workstation
5. Execute the *projectGUI.py* script & choose the *loot* folder.
6. Wait for the *projectGUI.py* script to be executed and Python Flask will start up. A Browser will pop up and our website(tool) will be displayed. 
7. Click on ***the red icon of Exfiltration*** to view the exfiltration of tool (to identify abnomality in user's activities)
8. Click on ***the orange icon of Machine Learning*** to view our ML prediction (Note: It may take some time for ML to predict... be patient...)
9. Click on ***the green icon of Timeline analysis*** to view the graph for timeline analysis
10. Click on ***the blue icon of Graph Analysis*** to view a force-directed graphs of all the extracted information 

## Dependencies & Softwares needed for this application
```
Syntax : 
python -m pip install <package> 
OR
python3 -m pip install <package>
OR
pip install <package>
OR
pip3 install <package>

List of packages to be installed:
Flask
plotly==4.2.1 (type the package name as plotly==4.2.1)
python-tk
scikit-learn
pandas
numpy
nltk
py2neo
```
You need to download Neo4J Desktop Application [at this link](https://neo4j.com/developer/neo4j-desktop/) in order to start the Graphical analysis service


## Extraction of information using Bash Bunny
1. Toggle the Bash Bunny’s switch position to the “lowest” position.
2. Sets the Bash Bunny into storage mode for uploading of files.
3. Navigate to the “Bash Bunny Drive” > “payload” > “switch2” directory.
    - This is the directory to upload all the powershell scripts.
4. Upload “runner.ps1”, “Browser-Extraction.ps1”, “Registry-Extraction” and “File-Extraction.ps1” to the current directory.
runner.ps1 will run the other three powershell scripts concurrently.
5. Open “payload.txt” and include this line “RUN WIN Powershell -nop -ex Bypass ".((gwmi win32_volume -f 'label=''BashBunny''').Name+'payloads\\$SWITCH_POSITION\runner.ps1')"” right after “# Run the run.ps1 script in the BashBunny”.
6. Instructs the Bash Bunny to run powershell with “Bypass” policy so that powershell scripts can be executed on the workstation.
7. runner.ps1 is to be executed when Bash Bunny is plugged into the device.
8. Remove the Bash Bunny and toggle its switch position to the “middle” position.
9. Sets the Bash Bunny into attacking mode to execute the files that are instructed to.
10. Plug into target’s workstation to begin digital artifacts extraction.
11. After the extraction is completed, the contents of the Bash Bunny will popped up in a File Explorer Window
12. Extracted information are found in the *loot* folder

## Exfiltration & Timeline Analysis
1. Copy the *loot* folder from Bash Bunny to your local workstation.
2. Download this repository as a ZIP file and after downloading, extract the contents.
3. Go to the directory that contains ***projectGUI.py*** script file
4. Use Command Prompt / Powershell to execute the script 
    > python / python3 .\projectGUI.py
5. Python Flask will be started and a browser will pop up showing our website (tool)
6. Click on the ***red icon*** to view our textual analysis on the user's activities. 
7. Head back to the main page of website & click on the **green icon** to view the timeline analysis on the user's browsing history. 
```
There are 3 colours in this graph: Green, Red, Blue.
Green - Indicating that the url is normal/does not indicate any malcious intent
Blue - Indicating that the url is good and unlikely to demonstrate any malicious intent
Red - Indicating that the url is bad and that the user may be visiting the website to conduct malicious intent
```
## Machine Learning
###### Re-training model with new data
