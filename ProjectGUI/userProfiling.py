from py2neo import Graph, Node, Relationship
import pandas as pd


# MATCH (u:User)-[r]-(b)-[r2]-(c) WHERE c.file_extension = '.py' OR c.url CONTAINS 'python' RETURN u,r,b,r2,c

swInstallPath = "extracted_data\\PsCSV\\SoftwareInstalled.csv"
mruPath = "extracted_data\\PsCSV\\mru.csv"

chromeBookmarkPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\chromeBookmarks.csv"
chromeDownloadPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\chromeDownloads.csv"
chromeHistoryPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\chromeHistory.csv"
firefoxBookmarkPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\mozillaBookmarks.csv"
firefoxeDownloadPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\mozillaDownloads.csv"
firefoxHistoryPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\mozillaHistory.csv"
ieBookmarkPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\ieBookmarks.csv"
ieHistoryPath = "extracted_data\\History-5,11,2019,1,32,51,PM\\ieHistory.csv"

fileExPath = "extracted_data\\fileCSV\\getall.csv"

userAcc = "WeiHan The Analyst"

class MainNode:
    def __init__(self):
        self.components = []

    def add_component(self, regComp):
        self.components.append(regComp)

class RegSW:
    def __init__(self):
        self.softwares = []

    def add_swobj(self, swI):
        self.softwares.append(swI)

class RegMRU:
    def __init__(self):
        self.mru = []

    def add_mru(self, recentItem):
        self.mru.append(recentItem)

class FireChrome:
    def __init__(self):
        self.history = []
        self.bookmarks = []
        self.downloads = []

    def add_history(self, hist):
        self.history.append(hist)

    def add_bookmarks(self, bookm):
        self.bookmarks.append(bookm)

    def add_downloads(self, downl):
        self.downloads.append(downl)

class IntExplorer:
    def __init__(self):
        self.history = []
        self.bookmarks = []

    def add_history(self, hist):
        self.history.append(hist)

    def add_bookmarks(self, bookm):
        self.bookmarks.append(bookm)

class CompFiles:
    def __init__(self):
        self.files = []

    def add_files(self, extractedFiles):
        self.files.append(extractedFiles)

class SoftwareInstalled:
    def __init__(self, swName, swVersion, swPublisher, swInstallDate):
        self.name = swName
        self.version = swVersion
        self.publisher = swPublisher
        self.installDate = swInstallDate

class History:
    def __init__(self, url, title):
        self.url = url
        self.title = title

class IEHistory:
    def __init__(self, url):
        self.url = url

class Bookmarks:
    def __init__(self, url, title):
        self.url = url
        self.title = title

class Downloads:
    def __init__(self, name, source):
        self.name = name
        self.source = source

class ExFiles:
    def __init__(self, name, time, fullpath, size, hexsig, extn, magicmatch):
        self.name = name
        self.dateTime = time
        self.fullPath = fullpath
        self.sizeKB = size
        self.hexSig = hexsig
        self.extn = extn
        self.magicmatch = magicmatch

class DFGraph:
    def __init__(self):
        self.graph = Graph(password="ict2202")
        self.graph.delete_all()
        self.transaction = self.graph.begin()

    def clear_graph(self):
        self.graph.delete_all()

    def add_node(self, node):
        self.transaction.create(node)

    def add_relationship(self, relation):
        self.transaction.create(relation)

    def commit_tx(self):
        self.transaction.commit()

def registryGraph():
    registry = MainNode()
    regSW = RegSW()
    regMRU = RegMRU()
    swdf = pd.read_csv(swInstallPath)
    for index, row in swdf.iterrows():
        regSW.add_swobj(SoftwareInstalled(row['DisplayName'], row['DisplayVersion'], row['Publisher'], row['InstallDate']))
    mrudf = pd.read_csv(mruPath)
    for index, row in mrudf.iterrows():
        regMRU.add_mru(row['MRU'])
    registry.add_component(regSW)
    registry.add_component(regMRU)
    return registry

def browserGraph():
    browser = MainNode()
    chrome = FireChrome()
    firefox = FireChrome()
    ie = IntExplorer()
    chromeBookdf = pd.read_csv(chromeBookmarkPath, encoding = 'unicode_escape')
    for index, row in chromeBookdf.iterrows():
        chrome.add_bookmarks(Bookmarks(row['URL'], row['Title']))
    chromeHistdf = pd.read_csv(chromeHistoryPath, encoding = 'unicode_escape')
    for index, row in chromeHistdf.iterrows():
        chrome.add_history(History(row['URL'], row['Title']))
    chromeDldf = pd.read_csv(chromeDownloadPath, encoding = 'unicode_escape')
    for index, row in chromeDldf.iterrows():
        chrome.add_downloads(Downloads(row['Name'], row['Source']))
    ffBookdf = pd.read_csv(firefoxBookmarkPath, encoding = 'unicode_escape')
    for index, row in ffBookdf.iterrows():
        firefox.add_bookmarks(Bookmarks(row['URL'], row['Title']))
    ffHistdf = pd.read_csv(firefoxHistoryPath, encoding = 'unicode_escape')
    for index, row in ffHistdf.iterrows():
        firefox.add_history(History(row['URL'], row['Title']))
    ffDldf = pd.read_csv(firefoxeDownloadPath, encoding = 'unicode_escape')
    for index, row in ffDldf.iterrows():
        firefox.add_downloads(Downloads(row['Name'], row['Source']))
    ieBookdf = pd.read_csv(ieBookmarkPath, encoding = 'unicode_escape')
    for index, row in ieBookdf.iterrows():
        ie.add_bookmarks(Bookmarks(row['URL'], row['Title']))
    ieHistdf = pd.read_csv(ieHistoryPath, encoding = 'unicode_escape')
    for index, row in ieHistdf.iterrows():
        ie.add_history(IEHistory(row['URL']))
    browser.add_component(chrome)
    browser.add_component(firefox)
    browser.add_component(ie)
    return browser

def fileGraph():
    fileAnalysis = MainNode()
    compFiles = CompFiles()
    exFilesdf = pd.read_csv(fileExPath)
    for index, row in exFilesdf.iterrows():
        compFiles.add_files(ExFiles(row['Title'], row['Time'], row['FullPath'], row['LengthInKB'], row['HexSignature'], row['FileExtn'], row['Result']))
    fileAnalysis.add_component(compFiles)
    return fileAnalysis

if __name__ == "__main__":
    graph = DFGraph()
    user = Node("User", name=userAcc)
    graph.add_node(user)

    registry = registryGraph()
    swReg = Node("Registry", name="Software Installed")
    mruReg = Node("Registry", name="Most Recently Used")
    graph.add_node(Relationship(user, "Digital Traces By", swReg))
    graph.add_node(Relationship(user, "Digital Traces By", mruReg))
    for softwares in registry.components[0].softwares:
        graph.add_node(Relationship(swReg, "Extracted Info", Node("Softwares", name=softwares.name, version=softwares.version, publisher=softwares.publisher, install_date = softwares.installDate)))
    for index, mru in enumerate(registry.components[1].mru):
        graph.add_node(Relationship(mruReg, "Extracted Info", Node("MRU", name=mru, used_order=index+1)))

    browser = browserGraph()
    chrome = Node("Browser", name="Chrome")
    firefox = Node("Browser", name="Firefox")
    ie = Node("Browser", name="Internet Explorer")
    graph.add_node(Relationship(user, "Digital Traces By", chrome))
    graph.add_node(Relationship(user, "Digital Traces By", firefox))
    graph.add_node(Relationship(user, "Digital Traces By", ie))
    for history in browser.components[0].history:
        graph.add_node(Relationship(chrome, "Visits", Node("History", url=history.url, title=history.title)))
    for download in browser.components[0].downloads:
        graph.add_node(Relationship(chrome, "Downloads", Node("Downloads", name=download.name, source=download.source)))
    for bookmark in browser.components[0].bookmarks:
        graph.add_node(Relationship(chrome, "Favourites", Node("Bookmarks", url=bookmark.url, title=bookmark.title)))
    for history in browser.components[1].history:
        graph.add_node(Relationship(firefox, "Visits", Node("History", url=history.url, title=history.title)))
    for download in browser.components[1].downloads:
        graph.add_node(Relationship(firefox, "Downloads", Node("Downloads", name=download.name, source=download.source)))
    for bookmark in browser.components[1].bookmarks:
        graph.add_node(Relationship(firefox, "Favourites", Node("Bookmarks", url=bookmark.url, title=bookmark.title)))
    for history in browser.components[2].history:
        graph.add_node(Relationship(ie, "Visits", Node("History", url=history.url)))
    for bookmark in browser.components[2].bookmarks:
        graph.add_node(Relationship(ie, "Favourites", Node("Bookmarks", url=bookmark.url, title=bookmark.title)))

    fileAnalysis = fileGraph()
    sysFile = Node("Files in System", name="User Files")
    graph.add_node(Relationship(user, "Digital Traces By", sysFile))
    for files in fileAnalysis.components[0].files:
        graph.add_node(Relationship(sysFile, "Contains", Node("Files", name=files.name, date_time_accessed=files.dateTime, full_path=files.fullPath, size_KB=files.sizeKB, hex_signature=files.hexSig, file_extension=files.extn, magic_number_match=files.magicmatch)))

    graph.commit_tx()
