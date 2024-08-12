from __future__ import absolute_import
from __future__ import print_function
import inspect
from Pyverilog.pyverilog.vparser.ast import *
from sys import *
from z3 import *
from queue import PriorityQueue
from cdf_analyzer.z3_parsing_lib.signal import Signal
class FunctionCall(object):
    def __init__(self,name):
        self.name=name
        self.input=list()
        self.output=None
        self.function=None
        
        
class Traverser(object):
    def __init__(self,topmodule):
        self.topmodule=topmodule
        self.signal_dict=dict()
        self.module=None # module currently traversing
        self.ctrl_depth=0
        self.signal_list=list()
        self.cond_frame=list()
        self.label=0
        self.lhs_flag=False
        self.instance_module=None
        self.module_portlist=dict()#{module:[port1,port2,...]
        self.instance_name=None

    def parse_node(self,ast):
        # print(f"parsing type{type(ast)}",file=stderr)
        node_type=ast.get_type()
        return {
            "SensList":self.parse_SensList,
            "Always": self.parse_Non,
            "Wire":self.parse_Wire,
            "Reg":self.parse_Reg,
            "Input":self.parse_Input,
            "Output":self.parse_Output,
            "Assign":self.parse_Assign,
            "Function":self.parse_Function,
            "CasezStatement":self.parse_CasezStatement,
            # "Port": self.parse_Non,
            "Width": self.parse_Width,
            "NonblockingSubstitution":self.parse_NonblockingSubstitution,
            "InstanceList":self.parse_InstanceList,
            "Block":self.parse_Non,
            "CaseStatement":self.parse_CaseStatement,
            # "Instance":self.parse_Non,
            # "PortArg":self.parse_Non,
            "IntConst": self.parse_Non,
            # "Lvalue": self.parse_Non,
            "Identifier": self.parse_Non,
            # "Rvalue": self.parse_Non,
            # "Plus": self.parse_Non,
            # "SystemCall": self.parse_Non,
            # "And": self.parse_Non,
            # "Pointer": self.parse_Non,
            # "Concat": self.parse_Non,
            # "Partselect": self.parse_Non,
            # "Eq": self.parse_Non,
            "Parameter":self.parse_Parameter,
            "Ioport":self.parse_Non,
            "Source": self.parse_Non, ## continue
            "Description": self.parse_Non, ## continue
            "ModuleDef": self.parse_ModuleDef, ## define the current module
            "Paramlist": self.parse_Non, ## continue
            "Portlist": self.parse_Portlist,
            "Decl": self.parse_Non, ## continue
            # "GreaterEq": self.parse_Non,
            # "Unot":self.parse_Non,
            # "Or":self.parse_Non,
            # "Sra":self.parse_Non,
            # "Cond":self.parse_Non,
            # "Xor":self.parse_Non,
            # "LessEq":self.parse_Non,
            # "SensList":self.parse_Non,
            # "Sens":self.parse_Non,
            "Case": self.parse_Case,
            "BlockingSubstitution":self.parse_BlockingSubstitution,
            "IfStatement":self.parse_IfStatement,
            # "Uand":self.parse_Non,
            # "Uor":self.parse_Non,
            # "Times":self.parse_Non,
            # "NotEq":self.parse_Non,
            # "Minus":self.parse_Non,
            # "GreaterThan":self.parse_Non,
            # "LessThan":self.parse_Non,
            # "Sll":self.parse_Non,
            # "Srl":self.parse_Non,
            # "Ulnot":self.parse_Non,
            # "LConcat":self.parse_Non
        }.get(node_type,self.parse_default)(ast)
    def parse_ModuleDef(self,ast):
        self.module=ast.name
        for subtree in ast.children():
            self.parse_node(subtree)
    def parse_Portlist(self,ast):
        self.module_portlist[self.module]=list()
        for item in ast.ports:
            self.module_portlist[self.module].append(item.name)

    def parse_Output(self, ast):
        if ast.width:
            lsb = int(ast.width.lsb.value)
            msb = int(ast.width.msb.value)
            assert lsb <= msb, f"{ast.name} lsb>msb"
            width = msb - lsb + 1
        else:
            width = 1
        name = ast.name
        signal = Signal(f"{self.module}.{name}", "Output", self.module, ast.lineno)
        self.signal_dict[f"{self.module}.{name}"] = signal
        self.signal_list.append(signal)
        return

    def parse_Input(self, ast):
        if ast.width:
            lsb = int(ast.width.lsb.value)
            msb = int(ast.width.msb.value)
            assert lsb <= msb, f"{ast.name} lsb>msb"
            width = msb - lsb + 1
        else:
            width = 1
        name = ast.name
        signal = Signal(f"{self.module}.{name}", "Input", self.module, ast.lineno)  # new input
        self.signal_dict[f"{self.module}.{name}"] = signal  # add to signal dict
        self.signal_list.append(signal)  # add to signal list
        return

    def parse_Reg(self, ast):
        if ast.width:
            lsb = int(ast.width.lsb.value)
            msb = int(ast.width.msb.value)
            assert lsb <= msb, f"{ast.name} lsb>msb"
            width = msb - lsb + 1
        else:
            width = 1
        if ast.dimensions:
            # TODO need to handle the memory
            pass
        name = ast.name
        signal = Signal(f"{self.module}.{name}", "Reg", self.module,ast.lineno)
        ## keep unique
        if f"{self.module}.{name}" not in self.signal_dict.keys():
            self.signal_dict[f"{self.module}.{name}"] = signal
            self.signal_list.append(signal)
        return

    def parse_Wire(self, ast):
        if ast.width:
            lsb = int(ast.width.lsb.value)
            msb = int(ast.width.msb.value)
            assert lsb <= msb, f"{ast.name} lsb>msb"
            width = msb - lsb + 1
        else:
            width = 1
        name = ast.name
        signal = Signal(f"{self.module}.{name}", "Wire", self.module,ast.lineno)
        if f"{self.module}.{name}" not in self.signal_dict.keys():
            self.signal_dict[f"{self.module}.{name}"] = signal
            self.signal_list.append(signal)
        return

    def parse_Parameter(self,ast):
        signal=Signal(f"{self.module}.{ast.name}","Parameter",self.module,ast.lineno)
        ## don't need to add to signal list cause it has no dependencies
        self.signal_dict[f"{self.module}.{ast.name}"]=signal
        return

    def parse_Assign(self, ast):
        lhs = self._parse_Lvalue(ast.left.var)
        rhs = self._parse_Rvalue(ast.right.var)
        assert not self.cond_frame, False

        lhs.parents.append(rhs)

    def parse_BlockingSubstitution(self, ast):
        lhs = self._parse_Lvalue(ast.left.var)
        rhs = self._parse_Rvalue(ast.right.var)

        lhs.parents.append(rhs)
        for cond in self.cond_frame:
            lhs.parents.append(cond)


    def parse_NonblockingSubstitution(self, ast):
        lhs = self._parse_Lvalue(ast.left.var)
        rhs = self._parse_Rvalue(ast.right.var)

        lhs.parents.append(rhs)
        for cond in self.cond_frame:
            lhs.parents.append(cond)

    def parse_CaseStatement(self,ast):
        self.ctrl_depth+=1
        cond=self._parse_Rvalue(ast.comp)
        self.cond_frame.append(cond)
        for sub in ast.caselist:
            self.parse_node(sub)
        self.cond_frame.pop()
        self.ctrl_depth-=1
        return
    def parse_InstanceList(self,ast):
        #skip and handle in second round
        return
    def parse_Case(self,ast):
        for child in ast.children():
            self.parse_node(child)

    def parse_IfStatement(self,ast):
        self.ctrl_depth+=1
        cond_signal=self._parse_Rvalue(ast.cond)
        self.cond_frame.append(cond_signal)
        if ast.true_statement:
           self.parse_node(ast.true_statement)
        if ast.false_statement:
            self.parse_node(ast.false_statement)
        self.ctrl_depth-=1
        self.cond_frame.pop()
        return

    def parse_CasezStatement(self,ast):
        raise Exception


    def parse_Function(self,ast):
        raise Exception
        ##todo parse the function

    def parse_Non(self,ast):
        for subtree in ast.children():
            self.parse_node(subtree)
        return

    def parse_SensList(self,ast):
        return

    def parse_Width(self,ast):
        return

    def _parse_Lvalue(self, ast):
        node_type = ast.get_type()
        lhs= {
            "Identifier": self._parse_LHSIdentifier,
            "LConcat": self._parse_LHSConcat,
            "Concat": self._parse_LHSConcat, ## instance connection
            "Partselect":self._parse_LHSPartselect,
            "IntConst": self._parse_LHSConstant
        }.get(node_type, self.parse_default)(ast)
        return lhs

    def _parse_LHSIdentifier(self, ast):
        assert f"{self.module}.{ast.name}" in self.signal_dict.keys(), False
        orig=self.signal_dict[f"{self.module}.{ast.name}"]
        signal=Signal(f"{self.module}.{ast.name}",orig.type,self.module,ast.lineno)
        self.signal_list.append(signal)
        signal.lhs_signal = True
        orig.parents.append(signal)
        return signal
    def _parse_LHSPartselect(self,ast):
        lsb=self._parse_Lvalue(ast.lsb)
        msb=self._parse_Lvalue(ast.msb)
        var=self._parse_Lvalue(ast.var)

        signal=Signal(f"Partselect_{var.name}","LHSPartselect",self.module,ast.lineno)
        self.signal_list.append(signal)
        self.label += 1

        var.parents.append(signal)
        lsb.parents.append(signal)
        msb.parents.append(signal)

        return signal

    def _parse_LHSConcat(self,ast):
        signal=Signal(f"Concat_{self.label}","LHSConcat",self.module,ast.lineno)
        self.label+=1
        self.signal_list.append(signal)
        for i in ast.list:
            ret=self._parse_Lvalue(i)
            ret.parents.append(signal)
        return signal

    def _parse_LHSConstant(self, ast):
        signal=Signal(f"Constant_{self.label}","LHSConst",self.module,ast.lineno)
        self.signal_list.append(signal)
        self.label+=1
        return signal

    def _parse_Rvalue(self, ast):
        node_type = ast.get_type()
        return {
            "FunctionCall": self._parse_FunctionCall,
            "Identifier": self._parse_RHSIdentifier,
            "Concat": self._parse_Concat,
            "Partselect": self._parse_Partselect,
            "IntConst": self._parse_RHSConstant,
            "Pointer": self._parse_Pointer,
            "SystemCall": self._parse_SystemCall,
            "Plus": self._parse_BinaryOperator,
            "And": self._parse_BinaryOperator,
            "Eq": self._parse_BinaryOperator,
            "GreaterEq": self._parse_BinaryOperator,
            "Unot": self._parse_UnaryOperator,
            "Or": self._parse_BinaryOperator,
            "Sra": self._parse_BinaryOperator,
            "Cond": self._parse_Cond,
            "Xor": self._parse_BinaryOperator,
            "LessEq": self._parse_BinaryOperator,
            "Uand": self._parse_UnaryOperator,
            "Uor": self._parse_UnaryOperator,
            "Times": self._parse_BinaryOperator,
            "NotEq": self._parse_BinaryOperator,
            "Minus": self._parse_BinaryOperator,
            "GreaterThan": self._parse_BinaryOperator,
            "LessThan": self._parse_BinaryOperator,
            "Sll": self._parse_BinaryOperator,
            "Srl": self._parse_BinaryOperator,
            "Ulnot": self._parse_UnaryOperator,
            "LConcat": self._parse_Concat,
            "Land": self._parse_BinaryOperator,
            "Lor": self._parse_BinaryOperator,
            "Repeat": self._parse_Repeat
        }.get(node_type, self.parse_default)(ast)

    def _parse_RHSIdentifier(self, ast):
        assert f"{self.module}.{ast.name}" in self.signal_dict.keys(), False
        orig=self.signal_dict[f"{self.module}.{ast.name}"]
        signal=Signal(f"{self.module}.{ast.name}",orig.type,self.module,ast.lineno)
        self.signal_list.append(signal)
        signal.parents.append(orig)
        signal.df_depth=1
        signal.ctrl_depth=self.ctrl_depth
        return signal

    def _parse_RHSConstant(self, ast):
        signal=Signal(f"Constant_{self.label}","Const",self.module,ast.lineno)
        self.signal_list.append(signal)
        self.label+=1
        signal.ctrl_depth=self.ctrl_depth
        return signal


    def _parse_FunctionCall(self, ast):
        signal=Signal(f"{str(ast)}_FunctionCall","FunctionCall",self.module,ast.lineno)
        self.signal_list.append(signal)
        for arg in ast.args:
            ret=self._parse_Rvalue(arg)
            signal.parents.append(ret)
        return signal



    def _parse_Cond(self,ast):
        self.ctrl_depth+=1
        cond = self._parse_Rvalue(ast.cond)
        self.cond_frame.append(cond)
        signal=Signal(f"Cond_{self.label}","Cond",self.module,ast.lineno)
        signal.parents.append(cond)
        self.label+=1
        if ast.true_value:
            true=self._parse_Rvalue(ast.true_value)
            signal.parents.append(true)
        if ast.false_value:
            false=self._parse_Rvalue(ast.false_value)
            signal.parents.append(false)
        self.signal_list.append(signal)
        self.cond_frame.pop()
        self.ctrl_depth-=1
        return signal

    def _parse_Partselect(self,ast):
        lsb=self._parse_Rvalue(ast.lsb)
        msb=self._parse_Rvalue(ast.msb)
        var=self._parse_Rvalue(ast.var)

        signal=Signal(f"Partselect_{var.name}","Partselect",self.module,ast.lineno)
        self.signal_list.append(signal)
        self.label += 1


        signal.parents.append(msb)
        signal.parents.append(lsb)
        signal.parents.append(var)

        return signal
    def _parse_Repeat(self,ast):
        assert ast.times.get_type()=="IntConst",False
        times=self._parse_Rvalue(ast.times)
        value=self._parse_Rvalue(ast.value)

        signal=Signal(f"Repeat_{self.label}","Repeat",self.module,ast.lineno)
        self.signal_list.append(signal)
        self.label += 1

        signal.parents.append(times)
        signal.parents.append(value)
        return signal


    def _parse_Concat(self,ast):
        signal=Signal(f"Concat_{self.label}","Concat",self.module,ast.lineno)
        self.signal_list.append(signal)
        self.label+=1

        for i in ast.list:
            ret=self._parse_Rvalue(i)
            signal.parents.append(ret)


        return signal

    def _parse_Pointer(self,ast):
        ptr=self._parse_Rvalue(ast.ptr)
        var=self._parse_Rvalue(ast.var)

        signal=Signal(var.name,f"Pointer_{self.label}",self.module,ast.lineno)
        self.label+=1
        self.signal_list.append(signal)


        signal.parents.append(var)
        signal.parents.append(ptr)

        return signal


    def _parse_SystemCall(self,ast):
        raise Exception

    def _parse_BinaryOperator(self,ast):
        z3_lhs = self._parse_Rvalue(ast.left)
        z3_rhs = self._parse_Rvalue(ast.right)
        signal=Signal(f"{z3_lhs.name}_Op_{z3_rhs.name}","BinaryOperator",self.module,ast.lineno)
        self.signal_list.append(signal)

        signal.parents.append(z3_rhs)
        signal.parents.append(z3_lhs)

        return signal

    def _parse_UnaryOperator(self, ast):
        operand = self._parse_Rvalue(ast.right)
        signal = Signal(f"Op_{operand.name}", "UnaryOperator", self.module,ast.lineno)
        self.signal_list.append(signal)

        signal.parents.append(operand)

        return signal

    def parse_default(self,ast):
        raise Exception(f"unsupported {type(ast)}")






    def resolve_instance(self,ast):
        node_type = ast.get_type()
        if node_type  == "ModuleDef":
            self.module=ast.name
        if node_type ==  "InstanceList":
            self.instance_module = ast.module
        if node_type == "Instance":
            self.parse2_Instance(ast)

        for child in ast.children():
            self.resolve_instance(child)
    def parse2_Instance(self,ast):
        self.instance_name=ast.name
        for index,port in enumerate(ast.portlist):
            assert port.get_type()=="PortArg",False
            self.parse2_PortArg(port,index)

    def parse2_PortArg(self,ast,index):
        if not ast.portname:
            portname=self.module_portlist[self.instance_module][index]
        else:
            portname=ast.portname

        port = self.signal_dict[f"{self.instance_module}.{portname}"]

        if port.type =="Input":
            arg=self._parse_Rvalue(ast.argname)
            port.parents.append(arg)
        elif port.type =="Output":
            arg = self._parse_Lvalue(ast.argname)
            arg.parents.append(port)

        else:
            raise Exception



    def dump_cdf(self):
        ret_map=[]
        path_dict=dict()
        for signal in self.signal_list:
            if signal.type in ["Output","Reg","Wire"] and signal.lhs_signal:
                print(f"calculating signal {signal.name}",file=stderr)
                lineno=signal.lineno
                path,dest=self.shortest_path(signal)
                if not path and not dest:
                    continue
                #
                # assert path and dest,False

                print(f"Signal {(signal.name,signal.lineno)} Depth {dest.dj_weight}",file=stderr)
                path_dict[(signal.name,signal.lineno,dest.dj_weight)]=[]
                ret_map.append((signal.module,signal.name.split(".")[-1],signal.lineno,dest.dj_weight))
                current=dest
                while current in path.keys():
                    path_dict[(signal.name, signal.lineno, dest.dj_weight)].append(f"{(current.name,current.lineno)}-->")
                    print(f"{(current.name,current.lineno)}-->",end="",file=stderr)
                    current=path[current]
                path_dict[(signal.name, signal.lineno, dest.dj_weight)].append(f"{(current.name,current.lineno)}-->Output")
                print(f"{(current.name,current.lineno)}-->Output",file=stderr)
        return ret_map,path_dict

    def assign_controlflow_weight(self):
        for item in self.signal_list:
            if item.type not in ["Input","Output","Reg","Wire"]:
                item.ctrl_depth=0
        return

    def shortest_path(self,signal:Signal):
        self.clear_dj_weight()
        self.assign_controlflow_weight()
        queue = PriorityQueue()
        signal.dj_weight=signal.ctrl_depth
        queue.put((signal.ctrl_depth,signal))
        prev=dict()
        visited=[]
        while not queue.empty():

            u=queue.get()
            signal=u[1]
            visited.append(signal)
            if signal.type=="Input" and signal.module==self.topmodule:
                return (prev,signal)
            for par in signal.parents:
                if par.type== "Const":
                    continue
                if par not in visited:
                    new_distance=signal.dj_weight+par.ctrl_depth
                    if new_distance<par.dj_weight:
                        par.dj_weight=new_distance
                        prev[par]=signal
                        queue.put((par.dj_weight,par))
        return False,False
    def clear_dj_weight(self):
        for item in self.signal_list:
            item.dj_weight=float('inf')

    def dump_df(self):
        ret_map = []
        path_dict = dict()
        for signal in self.signal_list:
            if signal.type in ["Output", "Reg", "Wire"] and signal.lhs_signal:
                print(f"calculating signal {signal.name}", file=stderr)
                lineno = signal.lineno
                path, dest = self.shortest_dateflow_path(signal)
                if not path and not dest:
                    continue
                #
                # assert path and dest,False

                print(f"Signal {(signal.name, signal.lineno)} Depth {dest.dj_weight}", file=stderr)
                path_dict[(signal.name, signal.lineno, dest.dj_weight)] = []
                ret_map.append((signal.module, signal.name.split(".")[-1], signal.lineno, dest.dj_weight))
                current = dest
                while current in path.keys():
                    path_dict[(signal.name, signal.lineno, dest.dj_weight)].append(
                        f"{(current.name, current.lineno)}-->")
                    print(f"{(current.name, current.lineno)}-->", end="", file=stderr)
                    current = path[current]
                path_dict[(signal.name, signal.lineno, dest.dj_weight)].append(
                    f"{(current.name, current.lineno)}->Output")
                print(f"{(current.name, current.lineno)}->Output", file=stderr)
        return ret_map, path_dict


    def shortest_dateflow_path(self,signal:Signal):
        self.clear_dj_weight()
        queue = PriorityQueue()
        signal.dj_weight=signal.df_depth
        queue.put((signal.df_depth,signal))
        prev=dict()
        visited=[]
        while not queue.empty():

            u=queue.get()
            signal=u[1]
            visited.append(signal)
            if signal.type=="Input" and signal.module==self.topmodule:
                return (prev,signal)
            for par in signal.parents:
                if par.type== "Const":
                    continue
                if par not in visited:
                    new_distance=signal.dj_weight+par.df_depth
                    if new_distance<par.dj_weight:
                        par.dj_weight=new_distance
                        prev[par]=signal
                        queue.put((par.dj_weight,par))
        return False,False







