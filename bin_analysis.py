import angr, claripy
import sys
from angrutils import plot_cfg, hook0
from angrutils.exploration import NormalizedSteps


if len(sys.argv) != 2:
    print("Usage: python bin_analysis.py <path_to_binary> (optional) <graph>")
    sys.exit(1)

binary = sys.argv[1]
proj = angr.Project(binary, auto_load_libs=False)
state = proj.factory.entry_state()


unsafe_functions = ["gets", "strcpy", "strcat", "sprintf", "scanf", "sscanf", "fscanf", "vscanf", "vsscanf", "vfscanf", 
                        "memcpy", "memmove", "memset", "bcopy", "bzero", "fgets", "read", "recv", "printf", "fprintf", "syslog", "vsprintf", 
                        "vfprintf", "system", "popen", "execl", "execv", "execle", "execve", "execlp", "execvp", "spawnl", "spawnlp", "spawnv", 
                        "spawnvp", "tmpnam", "tempnam", "mktemp", "strncpy", "strncat", "snprintf", "realpath",  "malloc", "calloc","realloc",
                        "free","strdup","strndup","asprintf","getline","getdelim","scanf","realpath","tmpnam","strcpy","strcat","sprintf","vsprintf",
                        "memcpy","memmove","fgets"]


main_func = None

def staticControlFlow(): 
    static_cfg_functions = set()
    cfg_fast = proj.analyses.CFGFast()
    global main_func
    main_func = cfg_fast.kb.functions['main'].addr
    func_info = None
    for func in cfg_fast.kb.functions.values():
        func_info = f"{func.name:} - {func.addr:#x}"
        static_cfg_functions.add(func_info)
    return static_cfg_functions
    
def dynamicControlFlow():
    dynamic_cfg_functions = set()
    #cfg_accurate = proj.analyses.CFGAccurate(starts=main_func)
    cfg_accurate = proj.analyses.CGFEmulated(keep_state=True, starts=main_func, fain_start=True)
    func_info = None
    return dynamic_cfg_functions

def checkFuncs(cfg_functions):
    avail_unsafe_funcs = set()  # Set to store found unsafe functions
    for func in cfg_functions:
        for unsafe in unsafe_functions:
            if unsafe in func:
                avail_unsafe_funcs.add(func)
    return avail_unsafe_funcs

def syb_exe():
    char_input = claripy.BVS("input", 8*1000)
    state = proj.factory.entry_state(stdin=char_input)

def main():
    cgf_functions = staticControlFlow()
    print("---------------------\nFunctions in binary")
    for func in cgf_functions:
        print(func)
    print("-------------------")

    unsafe = checkFuncs(cgf_functions)
    print("+++++++++++++++++++\nError Prone or Vulnerable Functions")
    for func in unsafe:
        print(func)
    print("+++++++++++++++++++")


    ###
    #print("Path Graph")
main()