# ICT 2202 - Team Forensix

This is a user manual which provides you a guide on how to use our solution. 

## General Flow of Solution
1. Analyst will use Bash Bunny & load the Powershell scripts into Bash Bunny
2. When Bash Bunny is plugged into a targeted machine, the scripts are executed and collected information are stored in a folder called *loot* which is located in the Bash Bunny.
3. Analyst can disconnect Bash Bunny from targeted machine and & connect back to forensics workstation. 
4. Copy out *loot* folder from Bash Bunny to local workstation
5. Execute the *projectGUI.py* script & choose the *loot* folder.
6. Wait for the *projectGUI.py* script to be executed and Python Flask will start up. A Browser will pop up and our website(tool) will be displayed. 
7. Click on *the red button* to view the exfiltration of tool
8. Click on *the orange button* to view our ML prediction (Note: It may take some time for ML to predict... be patient...)
9. Click on *the green button* to view the graph for timeline analysis
10. Click on *the blue button* to view a force-directed graphs of all the extracted information 
