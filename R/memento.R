#' Write a memento file
#'
#' Read an archived file and write it to a local directory.
#'
#' @param url URL to retrieve information for.
#' @param date The date of the archive.
#' @param dir The directory in which to save the file.
#' @importFrom here here
#' @importFrom fs file_exists dir_create as_fs_path
#' @importFrom readr write_lines
#' @return
#' The path of the created file, invisibly.
#' @export
write_memento <- function(url, date, dir) {
  path <- fs::path(dir, basename(url))
  if (!fs::file_exists(path)) {
    data <- read_memento(url, date, as = "text", encoding = "UTF-8")
    fs::dir_create(dirname(path))
    readr::write_lines(data, path)
  }
  invisible(fs::as_fs_path(path))
}

#' Read a file from the Time Travel API
#'
#' This function is adapted from the hrbrmstr/wayback package on GitHub.
#'
#' @param url URL to retrieve information for
#' @param date Date to use when checking for availability. If you don't
#'   pass in a valid R "time-y" object, you will need to ensure the character
#'   string you provide is in a valid subset of `YYYYMMDDhhmmss`.
#' @param as How you want the content returned. One of "`text`", "`raw`" or
#'   "`parsed`" (it uses [httr::content()] to do the heavy lifting).
#' @param ... Additional arguments passed to [httr::content()].
#' @source <https://github.com/hrbrmstr/wayback/blob/master/R/mementoweb.r>
#' @importFrom httr GET stop_for_status content
#' @importFrom glue glue
#' @return The content from the GET request.
#' @export
read_memento <- function(url, date = format(Sys.Date(), "%Y"),
                         as = c("text", "raw", "parsed"), ...) {
  as <- match.arg(as, c("text", "raw", "parsed"))
  if (is.null(timestamp)) {
    timestamp <- format(Sys.Date(), "%Y")
  }
  if (is.character(timestamp) && (timestamp == "")) {
    timestamp <- format(Sys.Date(), "%Y")
  }
  if (inherits(timestamp, "POSIXct")) {
    timestamp <- format(timestamp, "%Y%m%d%H%M%S")
  }
  url <- glue::glue("http://timetravel.mementoweb.org/memento/{date}/{span}")
  res <- httr::GET(url)
  httr::stop_for_status(res)
  httr::content(res, as = as)
}
