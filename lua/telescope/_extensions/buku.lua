return require("telescope").register_extension {
  setup = function(ext_config)
  end,
  exports = {
    require("telescope._extensions.buku.bookmarks")
  }
}
