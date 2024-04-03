#include %A_LineFile%\..\..\..\SharedFunctions\json.ahk
#include *i %A_LineFile%\..\..\..\SharedFunctions\MemoryRead\Imports\IC_GameVersion32_Import.ahk
#include *i %A_LineFile%\..\..\..\SharedFunctions\MemoryRead\Imports\IC_GameVersion64_Import.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\SH_VersionHelper.ahk

class IC_MemoryUpdater_Class
{
    ImportsURLsFile := A_LineFile . "\..\ImportsURLs.json"
    PointerDBUrlsFile := A_LineFile . "\..\PointerDBURLs.json"
    CurrentPointersURLsFile := A_LineFile . "\..\CurrentPointersURLs.json"

    ImportsURLs := {}
    PointerDBUrls := {}
    CurrentPointersURLs := {}

    RecentRemoteFile := ""
    RecentFileLoc := ""

    ImportFileAmount := 0
    DownloadCompletePercent := 0

   
    ;Gets data from JSON file
    LoadObjectFromJSON( FileName )
    {
        FileRead, oData, %FileName%
        return JSON.parse( oData )
    }

    ;Writes beautified json (object) to a file (FileName)
    WriteObjectToJSON( FileName, ByRef object )
    {
        objectJSON := JSON.stringify( object )
        objectJSON := JSON.Beautify( objectJSON )
        return this.WriteObjectToFile(FileName, objectJSON)
    }

    ; Writes the object text to a file.
    WriteObjectToFile( FileName, ByRef object)
    {
        if(FileExist(FileName))
            FileDelete, %FileName%
        FileAppend, %object%, %FileName%
        return ErrorLevel
    }

    ; Loads the data from this class's json files into the class
    LoadAllRemoteLocationFiles()
    {
        this.LoadCurrentPointersURLs()
        this.LoadPointerDBURLs()
        this.LoadImportsURLs()
    }

    ; Load Current Pointer URLs from JSON
    LoadCurrentPointersURLs()
    {
         this.CurrentPointersURLs := this.LoadObjectFromJSON(this.CurrentPointersURLsFile)
    }

    ; Load Pointer Database URLs from JSON
    LoadPointerDBURLs()
    {
         this.PointerDBUrls := this.LoadObjectFromJSON(this.PointerDBUrlsFile)
    }

    ; Load Imports URLs from JSON
    LoadImportsURLs()
    {
         this.ImportsURLs := this.LoadObjectFromJSON(this.ImportsURLsFile)
    }

    ; Uses the url from ImportsURLs[importsKey] to download all Imports files.
    DownloadImports(importsKey)
    {
        this.ImportFileAmount := 0
        files := {}
        files["Imports-Download"] := {}
        ; load main API
        ; get folders
        ; add folders to folders tree
        ; add files to files tree
        ; caculate number of files
        errorCode := this.GetGithubFileTree(this.GitHubToAPILoc(this.ImportsURLs[importskey]), files["Imports-Download"])
        if(errorCode == -1)
        {
            GuiControl, MemoryUpdater:, ImportUpdatesAvailable, Download failed.
            Gui, MemoryUpdater:Show
            return
        }
        this.UpdateProgressBar(7)
        fullDirectory := A_LineFile . "\..\..\..\SharedFunctions\MemoryRead\Imports-Download\"
        If( InStr( FileExist(fullDirectory), "D") )
        {
	        MsgBox, 4, % "Error! Cannot create download directory because it already exists.`nDo you wish to delete it? (This cannot be undone)"
            IfMsgBox, Yes
            {
                FileRemoveDir, %fullDirectory% , True
            }
            else
            {
                return
            }
        }
        ; Download files to "\Imports-Download\" and set progress bar increments to be 93/number of files
        errorCode := this.DownloadImportFiles(files, fullDirectory . "\..\")
        if(errorCode == -1)
        {
            GuiControl, MemoryUpdater:, ImportUpdatesAvailable, Download failed.
            Gui, MemoryUpdater:Show
            return
        }
        fullImportsDirectory := A_LineFile . "\..\..\IC_Core\MemoryRead\Imports\"
        ; remove old \Imports\ Directory
        If( FileExist(fullImportsDirectory))
        {
            FileRemoveDir, %fullImportsDirectory% , True ; recursively remove old directory and files
        }
        ; Rename \Imports-Download\
        If( FileExist(fullDirectory))
        {
            FileMoveDir, %fullDirectory%, %fullImportsDirectory% , R ; rename downloaded directory
        }
    }

    ; Downloads file contents from a json object containing remote URL file and directory information.
    DownloadImportFiles(files, fullDirectory)
    {
        for k,v in files
        {
            if(IsObject(v))
            {
                try
                {
                    FileCreateDir, % fullDirectory . k
                }
                catch
                {
                    MsgBox, There was an error downloading imports. (Could not create directory)
                    return -1
                }
                errorCode := this.DownloadImportFiles(v, fullDirectory . k . "\" )
                if(errorCode == -1) ; failure detected
                    return -1
            }
            else
            {
                try
                {
                    remoteFile := this.GetRemoteFile(v)
                }
                catch
                {
                    MsgBox, There was an error downloading imports. (Could not download file)
                    return -1
                }
                try
                {
                    this.WriteObjectToFile( fullDirectory . k, remoteFile)
                }
                catch
                {
                    MsgBox, There was an error downloading imports. (Could not write file)
                    return -1
                }
                this.DownloadCompletePercent += (93 / this.ImportFileAmount)
                this.UpdateProgressBar(Min(100, 7+this.DownloadCompletePercent))
            }
        }
    }

    ; Retrieves the file structure using the Github API for a Github repo at remoteURL and stores it in files.
    GetGithubFileTree(remoteURL, ByRef files)
    {
        try
        {
            remoteFile := this.GetRemoteFile(remoteURL)
            remoteJSON := JSON.parse(remoteFile)
        }
        catch
        {
            return -1
        }
        for k,v in remoteJSON
        {
            if(v["type"] == "dir")
            {
                files[v["name"]] := {}
                errorcode := this.GetGithubFileTree(v["url"], files[v["name"]])
                if(errorcode == -1)
                    return -1
            }
            else if (v["type"] == "file")
            {
                files[v["name"]] := v["download_url"]
                this.ImportFileAmount++
            }
        }
    }

    ; Saves the pointersdb or currentpointer to the appropriate pointers file.
    DownloadPointer()
    {
        if(this.RecentFileLoc AND this.RecentRemoteFile AND this.RecentUpdated)
        {
            this.WriteObjectToFile(this.RecentFileLoc, this.RecentRemoteFile)
            this.UpdateProgressBar(100)
        }
        else if(this.RecentFileLoc AND this.RecentRemoteFile)
        {
            GuiControl, MemoryUpdater:, PointersUpdatesAvailable, Update complete. No Update required.
        }
        else if(!this.RecentRemoteFile)
        {
            GuiControl, MemoryUpdater:-0x200, PointersUpdatesAvailable,
            GuiControl, MemoryUpdater:, PointersUpdatesAvailable, Update failed. Could not load remote file. Check for pointer updates again and then try to re-download.
        }
    }

    ; Fills GUI Dropdown lists in with available options
    PopulateDropdownLists()
    {
        this.LoadAllRemoteLocationFiles()
        this.PopulateDownList("ImportsDrowndownList", this.ImportsURLS, False)
        this.PopulateDownList("PointerDBDrowndownList", this.PointerDBURLs)
        this.PopulateDownList("CurrentPointersDrowndownList", this.CurrentPointersURLs)
    }

    ; Fills the DropDownList listVar with the keys of jsonObj. updateURL attempts to find the raw URLs for certain domains (e.g. github, pastebin)
    PopulateDownList(listVar, jsonObj)
    {
        listValues := ""
        for k,v in jsonObj
        {
            listValues := listValues . "|" . k
        }
        listValues := listValues . "||" ; List must start with | and end with || to not have blank entries.
        GuiControl, MemoryUpdater:, %listVar%, %listValues%
        GuiControl, MemoryUpdater:choose, %listVar%, 1
    }

    ; Converts a regular URL (such as github repo link or pastebin link) to the location of the raw file.
    BaseURLToRawContentsURL(url)
    {
            if(InStr(url, "https://github.com/"))
                return this.GithubToRawLoc(url)
            else if(InStr(url, "https://pastebin.com/") AND !InStr(url, "/raw/"))
                return this.PasteBinToRawLoc(url)
            else
                return url
    }

    ; Returns whether the JSON contents of **fileLoc** is equivalent to the JSON contents of the file at ```url``` #url#. Stores remote file in classes' RecentRemoteFile variable.
    CheckJSONFileForUpdate(fileLoc, url)
    {
        try
        {
            FileRead, localFile, %fileLoc%
            remoteFile := this.GetRemoteFile(url)
            this.RecentRemoteFile := remoteFile
        }
        catch except
        {
            throw except
        }
        try
        {
            if remoteFile == ""
                throw
            val := JSON.parse(remotefile)
        }
        catch except
        {
            throw "Remote file not a valid pointer file."
        }
        remoteFile := JSON.Minify(remoteFile)
        localFile := JSON.Minify(localFile)
        if localFile == "" ; in the case the remote file exists and local file is null
            return true
        areEqual := InStr(remoteFile, localFile)
        return !areEqual
    }

    ; Checks for a pointer file update and notifies the user about the status. 
    CheckPointerForUpdate(localFileLoc, url)
    {
        GuiControl, MemoryUpdater:, PointersUpdatesAvailable, % "Checking..."
        try
        {
            hasUpdate := this.CheckJSONFileForUpdate(localFileLoc, this.BaseURLToRawContentsURL(url))
            this.RecentFileLoc := localFileLoc
            this.RecentUpdated := hasUpdate ? True : False
        }
        catch except
        {
            
            this.ShowUnexpectedError(except, "PointersUpdatesAvailable")
            return
        }
        this.UpdateTextForUpdate(hasUpdate, "PointersUpdatesAvailable")
    }

    ; Checks for updates to Imports and notifies the user about the status.
    CheckImportsForUpdate(url)
    {
        GuiControl, MemoryUpdater:, ImportUpdatesAvailable, % "Checking..."
        strEndLoc := StrLen(url)
        if(!InStr(url, "/",, strEndLoc))
            url := url . "/"
        VersionCheckURL32Bit := url . "IC_GameVersion32_Import.ahk"
        VersionCheckURL64Bit := url . "IC_GameVersion64_Import.ahk"
        if(InStr(url, "https://github.com/"))
        {
            VersionCheckURL32Bit := this.GithubToRawLoc(VersionCheckURL32Bit)
            VersionCheckURL64Bit := this.GithubToRawLoc(VersionCheckURL64Bit)
        }
        try
        {
            remoteFile32 := this.GetRemoteFile(VersionCheckURL32Bit) ; check for 32 bit file exists and grab it if it does
            hasUpdate32 := this.HasRemoteImportsUpdate(remoteFile32, 32) ; compare version to current version
            remoteFile64 := this.GetRemoteFile(VersionCheckURL64Bit)
            hasUpdate64 := this.HasRemoteImportsUpdate(remoteFile64, 64)
        }
        catch except
        {
            this.ShowUnexpectedError(except, "ImportUpdatesAvailable")
            return
        }
        version32 := this.GetGameVersionFromFile(remoteFile32) 
        version64 := this.GetGameVersionFromFile(remoteFile64)
        additionalInfo := "`nCurrent: " . (version64 ? (g_ImportsGameVersion64 . g_ImportsGameVersionPostFix64 . " (64-bit), Remote: " . version64) : (version32 ? (g_ImportsGameVersion32 . g_ImportsGameVersionPostFix32 . " (32-bit), Remote: " . version32) : g_ImportsGameVersion64 . g_ImportsGameVersionPostFix64 . " (64-bit), Remote: Unknown"))
        ; 64 bit update will override 32 bit update
        if(hasUpdate32)
            additionalInfo := "`nCurrent: " . g_ImportsGameVersion32 . g_ImportsGameVersionPostFix32 . " (32-bit), Remote: " . version32
        if(hasUpdate64)
            additionalInfo := "`nCurrent: " . g_ImportsGameVersion64 . g_ImportsGameVersionPostFix64 . " (64-bit), Remote: " . version64
        this.UpdateTextForUpdate((hasUpdate32 OR hasUpdate64), "ImportUpdatesAvailable", additionalInfo) ; Update user visible text to display status
    }

    ; Formats the exception message and displays it to the textLabel
    ShowUnexpectedError(except, textLabel)
    {
            descriptionStart := InStr(except.Message, "Description:") + StrLen("Description:")
            descriptionEnd := InStr(except.Message, "HelpFile:")
            httpMessage := LTrim(SubStr(except.Message, descriptionStart, descriptionEnd - descriptionStart))
            OutputDebug, % httpMessage ? httpMessage : except
            GuiControl, MemoryUpdater:-0x200, %textLabel%
            GuiControl, MemoryUpdater:, %textLabel%, % "Unexpected Error: " . (httpMessage ? httpMessage : except)
    }

    ; Compares the version contents of remoteFile to the imports for architecture (32/64 bit) and returns true remoteFile contains a newer version.
    HasRemoteImportsUpdate(ByRef remoteFile, architecture)
    {
        version := this.GetGameVersionFromFile(remoteFile)
        if(architecture == 32)
        {
            scriptImportsVersion := g_ImportsGameVersion32 . g_ImportsGameVersionPostFix32
            return SH_VersionHelper.IsVersionNewer(version, scriptImportsVersion)
        }
        else if (architecture == 64)
        {
            scriptImportsVersion := g_ImportsGameVersion64 . g_ImportsGameVersionPostFix64
            return SH_VersionHelper.IsVersionNewer(version, scriptImportsVersion)
        }
        else
        {
            return ""
        }
    }

    ; Parses the a text for gameversion and postfix and returns the resulting concatonated gameversion.
    GetGameVersionFromFile(ByRef remoteFile)
    {
        gameVersion := ""
        Loop, Parse, remoteFile, "`n"
        {
            if(InStr(A_LoopField, "g_ImportsGameVersionPostFix"))
            {
                gameVersion .= RTrim(LTrim(SubStr(A_LoopField, InStr(A_LoopField, "=") + 1)))
                break
            }
            else if(InStr(A_LoopField, "g_ImportsGameVersion"))
            {
                gameVersion := RTrim(LTrim(SubStr(A_LoopField, InStr(A_LoopField, "=") + 1)))
            }
        }
        return gameVersion
    }

    ; Updates textBoxToUpdate with a specified text based on whether a new update has been found.
    UpdateTextForUpdate(hasUpdate, textBoxToUpdate, additionalInfo := "")
    {
        test := StrLen(additionalInfo)
        if (StrLen(additionalInfo) > 20)
            GuiControl, MemoryUpdater:-0x200, %textBoxToUpdate%,
            ;additionalInfo := "`n" . additionalInfo
        if(hasUpdate == 0 AND textBoxToUpdate)
            GuiControl, MemoryUpdater:, %textBoxToUpdate%, No Update required . %additionalInfo%
        else if (hasUpdate == "")
            GuiControl, MemoryUpdater:, %textBoxToUpdate%, Unexpected Error
        else
            GuiControl, MemoryUpdater:, %textBoxToUpdate%, Update Available . %additionalInfo%
        Gui, MemoryUpdater:Show
    }

    ;Example:
        ; Converts
        ; https://github.com/mikebaldi/Idle-Champions/tree/main/SharedFunctions/MemoryRead/Imports/IC_GameVersion64_Import.ahk
        ; to
        ; https://raw.githubusercontent.com/mikebaldi/Idle-Champions/main/SharedFunctions/MemoryRead/Imports/IC_GameVersion64_Import.ahk
    ; Takes a github file URL and converts it to the corresponding raw file location.
    GithubToRawLoc(url)
    {
        original := "https://github.com/"
        replace := "https://raw.githubusercontent.com/"
        rawURL := StrReplace(url, original, replace,, 1)
        rawURL := StrReplace(rawURL, "/tree/", "/",, 1)
        rawURL := StrReplace(rawURL, "/blob/", "/",, 1)
        return rawURL
    }

    ; Converts a github repo URL into the API url that lists the contents of the repo.
    GitHubToAPILoc(url)
    {
        original := "https://github.com/"
        replace := "https://api.github.com/repos/"
        apiURL := StrReplace(url, original, replace,, 1) ; set domain to api domain
        treeStartLoc := InStr(apiURL, "/tree/") ; find where tree happens in URL 
        if (!treeStartLoc)
            return apiURL
        treeEndLoc := InStr(apiURL, "/",,treeStartLoc + 1, 2) ; find where /tree/branch/ ends
        urlLen := StrLen(apiURL)
        apiPart1 := SubStr(apiURL, 1, treeStartLoc)
        branch := SubStr(apiURL, treeStartLoc + StrLen("/tree/"), treeEndLoc - treeStartLoc - StrLen("/tree/")) 
        apiPart2 := SubStr(apiURL, treeEndLoc + 1, urlLen - treeEndLoc)
        apiURL := apiPart1 . "contents/" apiPart2 ; replace /tree/branch/ with /contents/ in url
        if(InStr(apiURL, "/",, StrLen(apiURL)))
            apiURL := SubStr(apiURL, 1, StrLen(apiURL) -1)
        apiURL := apiURL . "?recursive=1&ref=" . branch ; add recursive and branch to url
        return apiURL
    }

   ;Example:
        ; Converts
        ; https://pastebin.com/uEwzAqxm 
        ; to
        ; https://pastebin.com/raw/uEwzAqxm
    ; Takes a pastebin file URL and converts it to the corresponding raw file location.        
    PasteBinToRawLoc(url)
    {
        original := "https://pastebin.com/"
        replace := "https://pastebin.com/raw/"
        rawURL := StrReplace(url, original,  replace,, 1)
        return rawURL
    }

    ; Returns file at the url passed in.
    GetRemoteFile( url ) 
    {
        timeoutVal := 10000
        response := ""
        WR := ComObjCreate( "WinHttp.WinHttpRequest.5.1" )
        WR.SetTimeouts( timeoutVal, timeoutVal, timeoutVal, timeoutVal )  
        WR.SetProxy( 2, "127.0.0.1:9877" ) 
        WR.Open( "GET", url, true )
        WR.Send()
        WR.WaitForResponse( -1 )
        data := WR.ResponseText
        return data
    }

    ; Prompts the user for a URL and description and saves it to disk.
    PromptForURL(currLocation, currObject)
    {
        url := ""
        name := ""
        while(url == "")
        {
            InputBox, url, Location, Enter the URL of the %currLocation%.,,,125
            if(ErrorLevel == 1) ; canceled
                return
        }
        while(name == "")
        {
            InputBox, name, URL Description, Enter a name for the location.,,,125
            if(ErrorLevel == 1)
                return
        }
        this.AddURLToList(name, url, currObject)
    }

    ; Adds a name/URL to the dictionary with the name in currentObject and saves it to disk.
    AddURLToList(name, url, currObject)
    {
        if(!this.HasKey(currObject))
            return

        if(this[currObject].HasKey(name))
        {
            MsgBox, This name already exists. If you wish to replace it, please remove it from the list first and then add it again.
        }
        else
        {
            this[currObject][name] := url
            this.WriteNamedObjectToFile(currObject)
            this.PopulateDropdownLists()
        }
        return
    }

    ; Confirms choice with prompt and removes the name key from the currObject dictionary.
    RemoveURLFromList()
    {
        buttonPressed := A_GuiControl
        Gui, MemoryUpdater:Submit, NoHide
        name := ""
        currObject := ""
        global ImportsDrowndownList
        global PointerDBDrowndownList
        global CurrentPointersDrowndownList
        if(buttonPressed == "Updater_Remove_Imports")
        { 
            name := ImportsDrowndownList
            currObject := "ImportsURLs"
        }
        else if(buttonPressed == "Updater_Remove_PointerDB") 
        {
            name := PointerDBDrowndownList
            currObject := "PointerDBUrls"
        }
        else if(buttonPressed == "Updater_Remove_CurrentPointer") 
        {
            name := CurrentPointersDrowndownList
            currObject := "CurrentPointersURLs"
        }
        if(!this.HasKey(currObject))
            return
        MsgBox,4, Are you sure?, Are you sure you want to delete %name% from the list?
        IfMsgBox, Yes
        {
            thisObject := "this." . currObject
            this[currObject].Remove(name)
            this.WriteNamedObjectToFile(currObject)
            this.PopulateDropdownLists()
        }
        return
    }

    ; Writes object to json file if the string in currObject part of a list of objects.
    WriteNamedObjectToFile(currObject)
    {
        if(this.HasKey(currObject))
            this.WriteObjectToJSON(A_LineFile . "\..\" . currObject . ".json", this[currObject])
    }

    ; Sets the progress bar display to 0
    ResetDownloadProgressBar()
    {
        this.UpdateProgressBar(0)
    }

    ; Sets the progress bar display to the percent value 
    UpdateProgressBar(percent)
    {
        percent := Min(100,percent) ; cap bar at 100%
        GuiControl, MemoryUpdater:, Updater_Download_Progress_Bar, % percent
        GuiControl, MemoryUpdater:, Updater_Download_Progress_Text,
        if(percent >= 100)
            GuiControl, MemoryUpdater:, Updater_Download_Progress_Text, Done!

    }
}

global g_MemUpdater := new IC_MemoryUpdater_Class
g_MemUpdater.PopulateDropdownLists()