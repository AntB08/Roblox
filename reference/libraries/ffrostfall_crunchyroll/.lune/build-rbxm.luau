local process = require("@lune/process")

process.exec("rojo", { "build", "--output", "crunchyroll.rbxm" }, { stdio = "forward" })
