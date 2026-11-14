-- Zoxide integration
-- Press `Z` to jump to a frecent directory (interactive picker via fzf).
-- `update_db = true` adds every directory you visit in yazi to zoxide's
-- database, so yazi navigation feeds zoxide's frecency too.
require("zoxide"):setup {
	update_db = true,
}

-- Full border around the file manager.
-- Change to `type = ui.Border.PLAIN` for square corners.
require("full-border"):setup {
	type = ui.Border.ROUNDED,
}
