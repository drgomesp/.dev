.PHONY: openring

openring: 
	openring \
		-s https://danluu.com/atom.xml \
		-s https://emersion.fr/blog/rss.xml \
		-s https://drewdevault.com/feed.xml \
			< ./openring.dist \
			> ./themes/drgomesp/layouts/partials/openring.html

