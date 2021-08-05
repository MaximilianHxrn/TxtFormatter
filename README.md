# TxtFormatter
This tool formats wrong C/AL code to correct AL code

www.singhammer.com

#####Aufbau des Codes
Imports und Namespace Deklarationen
```C++
#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include <windows.h>
#include <sstream>
#include <regex>
#include <chrono>
#include <process.h>
#include <thread>

#ifdef WINDOWS
#include <direct.h>
#define GetCurrentDir _getcwd
#else
#include <unistd.h>
#define GetCurrentDir getcwd
#endif

using namespace std;
```

Dies Funktion nimmt als Parameter den Dateinamen. Von dort aus wird Zeile für Zeile die Datei eingelesen und in einem Dictionary gespeichert. Diese Funktion wird für die Dateien "good_words", "bad_words" und "function_names" verwendet.
```C++
list<string> readDict(string fileName)
{
    // Copied from:
    // https://gist.github.com/stevedoyle/1319089
    list<string> temp;
    string line;
    ifstream myfile(fileName);
    if (myfile.is_open())
    {
        while (myfile.good())
        {
            getline(myfile, line);
            temp.push_back(line);
        }
        myfile.close();
    }
    else
    {
        printf("%s is not open.", fileName);
    }
    return temp;
}
```
Um Platz zu sparen und leserlich Dateien einzulesen, holt sich diese Funktion das derzeitige "working directory". Von dort aus kann man einfacher die Dateien ansteuern.
```C++
std::string get_current_dir()
{
    char buff[FILENAME_MAX]; //create string buffer to hold path
    GetCurrentDir(buff, FILENAME_MAX);
    string current_working_dir(buff);
    return current_working_dir;
}

const string directory = get_current_dir();
list<string> bad_words = readDict(directory + "\\resources\\bad_words.txt"); // Einlesen
list<string> good_words = readDict(directory + "\\resources\\good_words.txt"); // Einlesen
list<string> function_names = readDict(directory + "\\resources\\function_names.txt"); // Einlesen
string UnsafeMode;
bool badWordFound = false;
```
Diese Funktion verwendet einen Algorithmus von StackOverflow, um die Standard-Funktionalität von std::str.replace() effizienter zu nutzen und jedes Auftreten eines Wortes zu ersetzen.
```C++
string replaceAll(std::string &str, const std::string &from, const std::string &to)
{
    // Copied from:
    // https://stackoverflow.com/a/3418285/10821617
    string temp_for_search = str;
    if (UnsafeMode == "True")
    {
        transform(temp_for_search.begin(), temp_for_search.end(), temp_for_search.begin(), ::toupper);
    }
    size_t start_pos = 0;
    while ((start_pos = temp_for_search.find(from, start_pos)) != std::string::npos)
    {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
    }

    return str;
}
```
process() ist die eigentlich wichtige Funktion dieses Tools. Hier werden bestimmte Kriterien überprüft
```C++
std::string process(string temp)
{
    string next_help = "NEXT = 0";
    string next_help2 = "Next = 0";
    string temp_for_search = temp;
    if (UnsafeMode == "True")
    {
        transform(temp_for_search.begin(), temp_for_search.end(), temp_for_search.begin(), ::toupper);
    }

```
Dieser Teil sucht aus der Liste von "bad_words" ein Auftreten in der Datei. Findet er einen Eintrag, dann werden alle Auftreten in der Datei ersetzt mit dem richtigen Wort aus "good_words".
```C++
    for (string bad_word : bad_words)
    {
        if (temp_for_search.find(bad_word) != string::npos)
        {
            for (string good_word : good_words)
            {
                string good_word_for_check = good_word;
                transform(bad_word.begin(), bad_word.end(), bad_word.begin(), ::toupper);
                transform(good_word_for_check.begin(), good_word_for_check.end(), good_word_for_check.begin(), ::toupper);
                if (bad_word == good_word_for_check)
                {
                    badWordFound = true;
                    temp = replaceAll(temp, bad_word, good_word);
                    break;
                }
            }
        }
    }
```
Dieser Ausschnitt läuft, wenn alle Wörter richtig geschrieben sind. Hierbei wird überprüft, ob Funktionsaufrufe noch Klammern benötigen und fügt diese ein (Beispiel: Record.Find; --> Record.Find(); ).
```C++    
    for (string function_name : function_names)
    {
        string search_function = function_name + ";";
        string search_function2 = function_name + " then";
        if (temp.find(search_function.c_str()) != string::npos)
        {
            for (string good_word : good_words)
            {
                if (function_name == good_word)
                {
                    badWordFound = true;
                    string new_function = good_word + "();";
                    if (function_name == next_help.c_str() || function_name == next_help2.c_str())
                    {
                        new_function = "Next() = 0;";
                    }
                    temp = replaceAll(temp, search_function.c_str(), new_function);
                }
            }
        }
        else if (temp.find(search_function2.c_str()) != string::npos)
        {
            for (string good_word : good_words)
            {
                if (function_name == good_word)
                {
                    badWordFound = true;
                    string new_function = good_word + "() then";
                    temp = replaceAll(temp, search_function2.c_str(), new_function);
                }
            }
        }
    }
```
Nachdem die Formatierung abgeschlossen ist, wird der formatierte string zurückgegeben.
```C++
    return temp;
```
Dieser Teil ist die "Mutter-Funktion" von process(). Hier wird die Datei eingelesen und das Ergebnis von process() einbehalten.
```C++
void processFile(string fileName)
{
    string line;
    ifstream myfile(fileName);
    stringstream os;
    if (myfile.is_open())
    {
        string line;
        while (getline(myfile, line))
        {
            os << line << endl;
        }
    }
    else
    {
        printf("%s is not open.", fileName.c_str());
    }
    string temp = os.str();
    temp = process(temp.substr(0, temp.size() - 1));
```
Dieser Teil ist speziell für Reports gedacht. Er sucht ein Auftreten von
```AL
column()
{
}
```
, welches mit
```AL
column() { }
``` 
ersetzt wird.
```C++
    // Copied from:
    // https://stackoverflow.com/questions/11508798/conditionally-replace-regex-matches-in-string
    string temp_for_check = temp;
    temp = regex_replace(temp, regex("\\)\n\\s*\\{\n\\s*\\}"), ") { }");
    if (temp != temp_for_check)
    {
        badWordFound = true;
    }
    if (badWordFound)
    {
        ofstream write;
        write.open(fileName, ios::out | ios::binary);
        write << temp;
        write.close();
    }
}
```

hasEnding() ist eine Helferfunktion die aus Performance-Zwecken eingebaut ist. Sie überprüftdie Endung eines String auf Gleichheit mit einem weiteren Paramter. In diesem Fall wird auf ".al" geprüft.
```C++
bool hasEnding(std::string const &fullString, std::string const &ending)
{
    if (fullString.length() >= ending.length())
    {
        return (0 == fullString.compare(fullString.length() - ending.length(), ending.length(), ending));
    }
    else
    {
        return false;
    }
}
```
processFolder() ist die "Mutter-Funktion" von processFile() und kümmert sich um die Ordnerstruktur. Sie ist die eigentliche Funktion, die aus der main() aufgerufen wird.
```C++
void processFolder(string folder)
{
    // Copied from:
    // https://stackoverflow.com/questions/67273/how-do-you-iterate-through-every-file-directory-recursively-in-standard-c
    string process_path;
    string search_path;
```
Sie überprüft anfänglich, ob es sich um eine Datei handelt oder einen Ordner und je nachdem, wird dann die Suchfunktion angepasst...
```C++
    bool singleFile = hasEnding(folder, ".al");
    if (singleFile)
    {
        process_path = folder;
        search_path = folder;
    }
    else
    {
        process_path = folder + "\\Objects\\";
        search_path = folder + "\\Objects\\*";
    }
    WIN32_FIND_DATAA fd;
    HANDLE hFind = ::FindFirstFileA(search_path.c_str(), &fd);
    if (hFind != INVALID_HANDLE_VALUE)
    {
        do
        {
            if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
            {         
                string temp;
                if (singleFile)
                {
                    temp = process_path;
                }
                else
                {
                    std::string ws(fd.cFileName);
                    std::string s(ws.begin(), ws.end());
                    temp = process_path + s;
                }
```
Wurde etwas gefunden, wird die Datei verarbeitet.
```C++       
                processFile(temp.c_str()); 
```
```C++                    
            }
        } while (::FindNextFileA(hFind, &fd));
        ::FindClose(hFind);
    }
}
```      
Die Main-Funktion liest per Parameter den Pfad ein und ob es sich, um den UnsafeMode handelt. Der UnsafeMode ist case insensitive und findet auch Auftreten von fInDsEt() --> FindSet().
Zusätzlich wurde ein Timer eingebaut, den man später in VS Code sieht. Er hat keinen wirklichen Nutzen, sondern diente ursprünglich zum Debugging, wurde dann aus ästethischen Gründen beibehalten.
```C++
int main(int argc, char const *argv[])
{
    string s(argv[1]);
    UnsafeMode = argv[2];
    cout << "Formatting..." << endl;
    auto t1 = std::chrono::high_resolution_clock::now();
    processFolder(s);
    auto t2 = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::seconds>(t2 - t1).count();
    if (duration == 0)
    {
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
        std::cout << "\nExecution-Time: " << duration << " milliseconds.\n"
                  << endl;
    }
    else
    {
        std::cout << "\nExecution-Time: " << duration << " seconds.\n"
                  << endl;
    }
    chrono::milliseconds dura(500);
    this_thread::sleep_for(dura);
    return 0;
}
```