#! /usr/bin/python3
from argparse import ArgumentParser
from Pyverilog.pyverilog.vparser.parser import parse
from os import mkdir
from cdf_analyzer.z3_parsing_lib.traverser import *
from cdf_analyzer.z3_parsing_lib.utils import *
import resource
import time
import json
from collections import defaultdict
def main(args):

    # # print(resource.getrlimit(resource.RLIMIT_STACK))
    # # print(sys.getrecursionlimit())
    # max_rec = 0x100000
    #
    # # May segfault without this line. 0x100 is a guess at the size of each stack frame.
    # resource.setrlimit(resource.RLIMIT_STACK, [0x100 * max_rec, resource.RLIM_INFINITY])
    # sys.setrecursionlimit(max_rec)


    start_time = time.time()
    if not args.pickle:
        print('\n[I] starting parser and data flow analysis...', file=stderr, flush=True)
        ast, directives = parse(args.file_list, preprocess_include=args.include, preprocess_define=args.define)
        dump_data(ast)
    else:
        ast=preload_data()

    """
    create directory
    """
    dir_number = 0
    while True:
        try:
            dir_name = f'{args.toplevel}_{dir_number}'
            mkdir(dir_name)
            break
        except FileExistsError:
            dir_number += 1
    """
    dump debug files
    """
    if args.dump_ast:
        with open(f'{dir_name}/{args.toplevel}_ast_data', 'w') as ast_file:
            ast.show(buf=ast_file)
    analyzer=Traverser(args.toplevel)
    analyzer.parse_node(ast)
    analyzer.resolve_instance(ast)
    ret_list,path_dict=analyzer.dump_cdf()
    json_dict=dict()

    for item in ret_list:
        if item[0] not in json_dict.keys():
            json_dict[item[0]]={}
            json_dict[item[0]]={item[3]:[{"var_name":item[1],"loc":f"d,{item[2]}"}]}
        else:
            if item[3] not in  json_dict[item[0]].keys():
                json_dict[item[0]][item[3]]=list()
                json_dict[item[0]][item[3]].append({"var_name":item[1],"loc":f"d,{item[2]}"})
            else:
                json_dict[item[0]][item[3]].append({"var_name": item[1], "loc": f"d,{item[2]}"})
    json_object = json.dumps(json_dict,indent=4)
    with open(f'{dir_name}/{args.toplevel}_ctrl_flow.json', 'w') as json_file:
        print(json_object,file=json_file)

    with open(f'{dir_name}/{args.toplevel}_ctrl_flow', 'w') as ctrl_file:
        for item in ret_list:
            print(f"module_name: {item[0]}, signal_name: {item[1]}, lineno: {item[2]}, ctrl_depth: {item[3]}, ",file=ctrl_file)
    with open(f'{dir_name}/{args.toplevel}_ctrl_path', 'w') as ctrl_path_file:
        for key,item in path_dict.items():
            print(key,file=ctrl_path_file)
            print(item,file=ctrl_path_file)


    ret_list,path_dict=analyzer.dump_df()
    json_dict=dict()

    for item in ret_list:
        if item[0] not in json_dict.keys():
            json_dict[item[0]]={}
            json_dict[item[0]]={item[3]:[{"var_name":item[1],"loc":f"d,{item[2]}"}]}
        else:
            if item[3] not in  json_dict[item[0]].keys():
                json_dict[item[0]][item[3]]=list()
                json_dict[item[0]][item[3]].append({"var_name":item[1],"loc":f"d,{item[2]}"})
            else:
                json_dict[item[0]][item[3]].append({"var_name": item[1], "loc": f"d,{item[2]}"})
    json_object = json.dumps(json_dict,indent=4)
    with open(f'{dir_name}/{args.toplevel}_dataflow_flow.json', 'w') as json_file:
        print(json_object,file=json_file)

    with open(f'{dir_name}/{args.toplevel}_dataflow_flow', 'w') as ctrl_file:
        for item in ret_list:
            print(f"module_name: {item[0]}, signal_name: {item[1]}, lineno: {item[2]}, dataflow_depth: {item[3]}, ",file=ctrl_file)
    with open(f'{dir_name}/{args.toplevel}_dataflow_flow', 'w') as ctrl_path_file:
        for key,item in path_dict.items():
            print(key,file=ctrl_path_file)
            print(item,file=ctrl_path_file)

    end_time = time.time()
    time_elapsed = end_time - start_time

    print("Time elapsed: ", time_elapsed, "seconds")


    with open(f'{dir_name}/{args.toplevel}_z3', 'w') as z3_file:
        for ass in analyzer.signal_list:
            print(ass,file=z3_file)

if __name__ == "__main__":

    parser = ArgumentParser()
    '''
    prerequisite for binding
    '''
    parser.add_argument("-I", "--include", \
                        action="append", default=[], \
                        help="Include path")
    parser.add_argument("-D", dest='define',
                        action='append', \
                        default=[], \
                        help='macro definition')
    parser.add_argument("--toplevel", action='store', type=str, \
                        default="toplevel", \
                        help="Toplevel module.")
    parser.add_argument("--no-reorder", action='store_true', \
                        default=False, \
                        help="No reordering of binding dataflow")
    parser.add_argument("--dump-ast", action='store_true', \
                        default=False, \
                        help="Dump file containing AST")
    parser.add_argument("--pickle", action='store_true', \
                        default=False, \
                        help="skip parsing")

    '''
    input file
    '''
    parser.add_argument("file_list", nargs='+')
    args = parser.parse_args()
    exit(main(args))

