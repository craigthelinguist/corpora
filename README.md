Generates a Māori-language corpus by parsing mi.wikipedia pages.

Uses the Wikipedia API for Python:
https://pypi.python.org/pypi/wikipedia/

Works in two steps:

1) Start at a page. Keep following links and build up the set of all pages on mi.wikipedia

2) Scan the words on each page and output to maori-corpus.txt
