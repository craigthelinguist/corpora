
# imports
import sys
import requests
from lxml import html
from lxml.cssselect import CSSSelector

# globals
__VERBOSE = False
__DEBUG = False
__OUTPUT = "morphemes-english.tsv"

# utility methods for prettying up names
def prettify_morpheme(string):
	for x in ["0","1","2","3","4","5","6","7","8","9"]:
		string = string.replace(x, "")
	return string

def prettify_definition(string):
	return string[1:-2]

# save the given morphemes and their definitions to __OUTPUT
def save(morphemes, definitions):
	global __OUTPUT
	global __VERBOSE

	# verbose
	if __VERBOSE:
		print("starting saving to " + __OUTPUT)

	# save
	with open(__OUTPUT, "w") as f:
		for morpheme, definition in zip(morphemes, definitions):
			f.write(morpheme + "\t" + definition + "\n")

	# verbose
	if __VERBOSE:
		print("finished saving to " + __OUTPUT)
		print(len(morphemes) + " morphemes total.")

# load all morphemes from one web page
def load(fpath):
	page = requests.get(fpath)
	tree = html.fromstring(page.text)

	# verbose
	global __VERBOSE
	if __VERBOSE:
		print("started loading " + fpath)

	# morphemes are the simplest units of meaning in a word
	# definitions explain how the morpheme contributes meaning to a word
	morphemes = []
	definitions = []

	# extract names
	names = tree.xpath('//a[@name]')
	for elem in names:
		name = prettify_morpheme(elem.attrib["name"])
		morphemes.append(name)

	# extract definitions
	entries = tree.find_class("entry")
	indices_to_del = []
	for i in range(len(entries)):
		elem_entry = entries[i]
		defs = elem_entry.find_class("define")
		if len(defs) == 0:
			indices_to_del.append(i)
		else:
			elem_def = defs[0]
			definition = elem_def.text_content()
			definition = prettify_definition(definition)
			definitions.append(definition)

	# delete these names because they are references to other names
	goodmorphemes = []
	for i in range(len(morphemes)):
		morph = morphemes[i]
		if i not in indices_to_del:
			goodmorphemes.append(morph)
	morphemes = goodmorphemes

	# verbose
	if __VERBOSE:
		print("finished loading " + fpath + " (" + str(len(morphemes)) + " morphemes)")

	# debugging
	if __DEBUG:
		if len(morphemes) != len(definitions):
			print("Error loading " + fpath)
			print(len(morphemes) + " morphemes, but " + str(len(definitions)) + " definitions")

	return morphemes, definitions

# load all morphemes & definitions from all pages and return
def load_all():

	# init stuff
	base = "http://www.cognatarium.com/cognatarium/?K="
	alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m",
			 "n","o","p","q","r","s","t","u","v","w","x","y","z"]
	morphemes = []
	definitions = []

	# load everything
	for char in alphabet:
		fpath = base + char
		m,d = load(fpath)
		morphemes += m
		definitions += d

	return morphemes, definitions

def main():

	# parse args	
	args = sys.argv
	#args[0] is morpheme-scraper.py
	i = 1
	while i < len(args):

		# parse argument
		arg = args[i]
		if not arg[0] == '-':
			print("Unknown argument: " + arg)
			print("Exiting....")
			sys.exit()
		if arg == "-v" or arg == "-verbose":
			global __VERBOSE
			__VERBOSE = True
		elif arg == "-d" or arg == "-debug":
			global __DEBUG
			__DEBUG = True
		elif arg == "-o" or arg == "-output":
			output_path = args[i+1]
			global __OUTPUT
			__OUTPUT = output_path
			i+=1

		# increase index
		i += 1

	'''
	OPTIONS:
		-v, -verbose : display what's happening at each stage
		-d, -debug : check and report on any bugs/inconsistencies
		-o, -output : specify custom filepath to output
	'''

	# load everything & save
	morphemes, definitions = load_all()
	save(morphemes, definitions)

if __name__ == '__main__':
	main()