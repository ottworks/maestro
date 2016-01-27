local config = {}

config.module = "sqlite" --sqlite, mysqloo, or tmysql4
config.host = "localhost"
config.username = ""
config.password = ""
config.database = "maestro"
config.port = 3306
config.socket = ""

local tables = {} --Table names. Change these to have per-server data on a per-table basis.

tables.bans  = "maestro_bans"
tables.flags = "maestro_flags"
tables.items = "maestro_items"
tables.notes = "maestro_notes"
tables.perms = "maestro_perms"
tables.ranks = "maestro_ranks"
tables.users = "maestro_users"


config.tables = tables
maestro.config = config
