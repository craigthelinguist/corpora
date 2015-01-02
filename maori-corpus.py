import wikipedia

def get_links(fname):
	''' Get all links in mi.wikipedia and save them in a file with
		the specified name. Takes several hrs to finish atm '''

	# set up, mi is Maori language wiki and hau kainga is the home page.
	wikipedia.set_lang("mi")
	to_visit = ["hau kainga"]

	# open file for writing
	f = open(fname, "w")
	for link in to_visit:
		f.write(link + "\n")
	write_count = 1

	# depth-first search on the links
	while len(to_visit) > 0:
		name = to_visit.pop()
		try:
			page = wikipedia.page(name)
			for link in page.links:
				if pages.insert(link):
					to_visit.append(link)
					write_count = write_count + 1

		except:
			# easier to sweep the wide array of possible errors under the rug.
			pass
		print(len(pages))

	# finished
	print ("Finished writing to file.")
	print ("found ", str(len(pages)), " pages")
	f.close()

def make_corpus(f_links, fname):
	''' Read the names of all links on mi.wikipedia, construct a list of unique words,
		and save to fname. '''
	
	valid_chars = ["a","e","i","o","u","ā","ē","ī","ō","ū",
				  "h","k","m","n","p","r","t","w","n","g"]

	# l might be unique since some iwi in the south (e.g.: Waitaha) have an 'l' in their orthography
	# we'll have to see if it's a problem....

	wikipedia.set_lang("mi")

	# load links
	links = []
	f = open(f_links, "r")
	for line in f:
		link = line.rstrip()
		links.append(link)
	f.close()

	# open file for writing
	f = open(fname, "w")
	print("Starting to write")

	wordset = set([])

	# make words
	for link in links:

		try:
			print(link)
			text = wikipedia.summary(link).split(" ")
			for word in text:

				# remove invalid characters
				word = word.lower()
				for char in word:
					if char not in valid_chars:
						word = word.replace(char, "")

				if len(word) > 0 and word not in wordset:
					wordset.add(word)
					f.write(word)
					f.write("\n")

			f.flush()
			print(len(wordset), " words")

		except wikipedia.WikipediaException:
			pass

	print("Finished writing")
	# close file
	f.close()