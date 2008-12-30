#Makefile for documentation

XML_LANG	= en-US
DOC_TYPE	= Book
DOCNAME		= documentation
PRODUCT		= Documentation
BRAND		= fedora

#OTHER_LANGS	= as-IN bn-IN de-DE es-ES fr-FR gu-IN hi-IN it-IT ja-JP kn-IN ko-KR ml-IN mr-IN or-IN pa-IN pt-BR ru-RU si-LK ta-IN te-IN zh-CN zh-TW
TRANSLATIONS	= $(XML_LANG) $(OTHER_LANGS)

COMMON_CONFIG  = /usr/share/publican
include $(COMMON_CONFIG)/make/Makefile.common

html: clean html-en-US

release: clean html-single-en-US pdf-en-US
	@rsync -rltHvz --delete --rsh=ssh tmp/en-US/html-single/Common_Content/ puppetmanaged.org:/data/www/puppetmanaged.org/www/public_html/documentation/Common_Content/
	@rsync -rltHvz --delete --rsh=ssh tmp/en-US/html-single/images/ puppetmanaged.org:/data/www/puppetmanaged.org/www/public_html/documentation/images/
	@rsync --rsh=ssh tmp/en-US/html-single/index.html puppetmanaged.org:/data/www/puppetmanaged.org/www/public_html/documentation/git-module.html
	@rsync --rsh=ssh tmp/en-US/pdf/Git_Module.pdf puppetmanaged.org:/data/www/puppetmanaged.org/www/public_html/documentation/git-module.pdf

