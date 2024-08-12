import pickle
def preload_data():
	with open('ast.pkl', 'rb') as f:
		ast = pickle.load(f)
	return ast
def dump_data(ast):
	with open('ast.pkl', 'wb') as f:
		pickle.dump(ast,f)