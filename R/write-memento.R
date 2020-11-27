#' Write a memento file
#'
#' Read an archived file and write it to a local directory.
#'
#' @param url URL to retrieve information for.
#' @param date The date of the archive.
#' @param dir The directory in which to save the file.
#' @importFrom here here
#' @importFrom fs file_exists dir_create as_fs_path
#' @importFrom wayback read_memento
#' @importFrom readr write_lines
#' @return
#' The path of the created file, invisibly.
#' @export
write_memento <- function(url, date, dir) {
  path <- fs::path(dir, basename(url))
  if (!fs::file_exists(path)) {
    data <- wayback::read_memento(url, date, as = "text")
    fs::dir_create(dirname(path))
    readr::write_lines(data, path)
  }
  invisible(fs::as_fs_path(path))
}
