config.load_autoconfig()

c.auto_save.session = True
c.url.default_page = "startpage.com"
c.editor.command = ["ghostty", "-e", "nvim", "{file}"]
config.bind(",y", "spawn haruna {url}")
config.bind("J", "tab-prev")
config.bind("K", "tab-next")

