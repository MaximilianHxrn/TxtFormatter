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
            if (!(line.rfind("#", 0) == 0))
            {
                temp.push_back(line);
            }
            else
            {
                cout << line << endl;
            }
        }
        myfile.close();
    }
    else
    {
        printf("%s is not open.", fileName);
    }
    return temp;
}

std::string get_current_dir()
{
    char buff[FILENAME_MAX]; //create string buffer to hold path
    GetCurrentDir(buff, FILENAME_MAX);
    string current_working_dir(buff);
    return current_working_dir;
}

const string directory = get_current_dir();
list<string> bad_words = readDict(directory + "\\resources\\bad_words.txt");
list<string> good_words = readDict(directory + "\\resources\\good_words.txt");
list<string> function_names = readDict(directory + "\\resources\\function_names.txt");
bool UnsafeMode = false;
bool badWordFound = false;

void replaceAll(std::string &subject, const std::string &search, const std::string &replace)
{
    string temp_for_search = subject;
    if (UnsafeMode)
    {
        transform(temp_for_search.begin(), temp_for_search.end(), temp_for_search.begin(), ::toupper);
    }
    // Copied from:
    // https://stackoverflow.com/a/3418285/10821617
    size_t pos = 0;
    while ((pos = temp_for_search.find(search, pos)) != std::string::npos)
    {
        subject.replace(pos, search.length(), replace);
        pos += replace.length();
    }
}

std::string process(string temp)
{
    string next_help = "NEXT = 0";
    string next_help2 = "Next = 0";
    string temp_for_search = temp;
    if (UnsafeMode)
    {
        transform(temp_for_search.begin(), temp_for_search.end(), temp_for_search.begin(), ::toupper);
    }
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
                    replaceAll(temp, bad_word, good_word);
                    break;
                }
            }
        }
    }
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
                    replaceAll(temp, search_function.c_str(), new_function);
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
                    replaceAll(temp, search_function2.c_str(), good_word + "() then");
                }
            }
        }
    }
    return temp;
}

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

void processFolder(string folder)
{
    // Copied from:
    // https://stackoverflow.com/questions/67273/how-do-you-iterate-through-every-file-directory-recursively-in-standard-c
    string process_path;
    string search_path;
    bool singleFile = hasEnding(folder, ".al");
    if (singleFile)
    {
        process_path = folder;
        search_path = folder;
    }
    else
    {
        process_path = folder + "\\";
        search_path = folder + "\\*";
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
                processFile(temp.c_str());
            }
        } while (::FindNextFileA(hFind, &fd));
        ::FindClose(hFind);
    }
}

int main(int argc, char const *argv[])
{
    cout << "Formatting..." << endl;
    if (strcmp(argv[2], "True") == 0)
    {
        UnsafeMode = true;
    }
    auto t1 = std::chrono::high_resolution_clock::now();
    processFolder(argv[1]);
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