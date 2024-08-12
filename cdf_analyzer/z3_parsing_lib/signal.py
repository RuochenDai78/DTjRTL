class Signal(object):
    def __init__(self,name,type,module,lineno):
        self.name=name
        self.type=type
        self.module=module
        self.parents=list()
        self.lineno=lineno
        self.ctrl_depth=0
        self.lhs_signal=False
        self.dj_weight=float('inf')
        self.df_depth=0 #if is valid signal .than is 1 else 0

    def new_signal(self,lineno):
        signal=Signal(self.name,self.type,self.module)
        signal.lineno=lineno
        return signal
    def __lt__(self, other):
        return self.dj_weight<=other.dj_weight
    def __repr__(self):
        return f"{str(self.name)}(type:{self.type},module:{self.module},lineno:{self.lineno},depth:{self.ctrl_depth})<--{[str(i.name) for i in self.parents]}"