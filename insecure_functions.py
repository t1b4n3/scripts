#!/bin/python3


import argparse, os, sys

# vulnerable and error prone functions 
vulnerable_functions = ["gets", "strcpy", "strcat", "sprintf", "scanf", "sscanf", "fscanf", "vscanf", "vsscanf", "vfscanf", 
                        "memcpy", "memmove", "memset", "bcopy", "bzero", "fgets", "read", "recv", "printf", "fprintf", "syslog", "vsprintf", 
                        "vfprintf", "system", "popen", "execl", "execv", "execle", "execve", "execlp", "execvp", "spawnl", "spawnlp", "spawnv", 
                        "spawnvp", "tmpnam", "tempnam", "mktemp", "strncpy", "strncat", "snprintf", "realpath",  "malloc", "calloc","realloc",
                        "free","strdup","strndup","asprintf","getline","getdelim","scanf","realpath","tmpnam","strcpy","strcat","sprintf","vsprintf",
                        "memcpy","memmove","fgets"]



def cmdline_arg():
    parser = argparse.ArgumentParser()  
    parser.add_argument('file', help="Requred* - Enter file name (source code)")
    args = parser.parse_args()
    return args.file

def file_exists(filepath):
    if os.path.exists(filepath) and os.path.isfile(filepath):
        return True
    return False

def search_for_insecure_functions(filepath):
    
    print("[+] Search for Vulnerable and Error Prone Functions")
    line_number = 1
    result = ''
    try: 
        with open(filepath, "r") as source_code:
            for line in source_code:
                for function in vulnerable_functions: 
                    if function in line:
                        result += f"Found {function} in Line {line_number}\n"
                    
                line_number += 1
    except None:
        ## will add later
        result = "error"

    return result


if __name__ == "__main__":
    file = cmdline_arg()
    if file_exists(file):
        result = search_for_insecure_functions(file)
        print(f"{result}")
    else:
        print("File Does not Exists")