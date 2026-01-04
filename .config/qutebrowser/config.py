config.load_autoconfig()

c.auto_save.session = True
c.url.default_page = "startpage.com"
c.url.searchengines["DEFAULT"] = "startpage.com/sp/search?q={}"
c.editor.command = ["xdg-open", "{file}"]
config.bind(",y", "spawn haruna {url}")
config.bind("J", "tab-prev")
config.bind("K", "tab-next")

