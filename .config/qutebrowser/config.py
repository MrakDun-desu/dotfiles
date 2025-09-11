config.load_autoconfig()

c.editor.command = ["ghostty", "-e", "nvim", "{file}"]
config.bind(",y", "spawn haruna {url}")
config.bind("J", "tab-prev")
config.bind("K", "tab-next")

