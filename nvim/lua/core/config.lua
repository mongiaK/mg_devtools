local _M = {}

function _M:load_global_config()
    local sep = "/"
    local home = os.getenv("HOME")

    self.mg_cachedir = home .. sep .. ".cache" .. sep .. "nvim" .. sep
    self.mg_datadir = string.format("%s/site/", vim.fn.stdpath("data"))

    self.home = home
end

_M:load_global_config()

return _M
