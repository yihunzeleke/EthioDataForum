library(rvest)
library(tidyverse)
library(RSelenium)
library(data.table)
library(netstat)

# url <- "https://dtm.iom.int/datasets" # IOM international data url
# url <- "https://dtm.iom.int/datasets?f%5B0%5D=dataset_region%3A146" # East and Horn Africa IOM data url

#url <- "https://dtm.iom.int/datasets?f%5B0%5D=dataset_country%3A63&f%5B1%5D=dataset_region%3A146" # url for Ethiopia IOM Data
url <- "https://dtm.iom.int/datasets?f%5B0%5D=dataset_country%3A63"
page <- read_html(url)

# Get the total page numbers
page_char <-  page %>% 
  html_elements(xpath = "//a[@class =  'page-link']") %>% # get all list of href 
  html_attr('href') %>% # get page of href element
  tail(1) # get the last page

pageNumbers <- gsub(".*page=([0-9]+).*", "\\1",page_char) %>% # Extract the value of the 'page' parameter
  as.numeric()

# Page sequence

pageSeq <- seq(from = 0, to = (pageNumbers), by = 1)

# Store data for all pages 

file_download_url_all <- c()
upload_date_all <- c()

for (i in pageSeq) {
  if (i == 0 ) {
    page <- read_html(url)
  } else {
    page <- read_html(paste0(url, '&start=', i))
  }
  file_download_url <- page %>% 
    html_nodes("span.file a") %>%
    html_attr("href") %>% 
    paste("https://dtm.iom.int", .,sep = "")
  
  upload_date = page %>% 
    html_elements(xpath = "//*[@class='date']") %>% 
    html_text() %>% 
    data.frame() %>% 
    set_names("raw_text") %>%  
    mutate(date_created = str_squish(raw_text)) %>% 
    mutate(date_created = str_extract(date_created, "\\b\\w{3} \\d{2} \\d{4}\\b")) %>% 
    pull(date_created)
  
  # append all 
  file_download_url_all <- append(file_download_url_all, file_download_url)
  upload_date_all <- append(upload_date_all, upload_date)
}

# Data frame

iom_ethiopia_df <- data.frame(
  "upload_date" = upload_date_all,
  "file_download_url_site" = file_download_url_all)
  # mutate(upload_date =  as.Date(upload_date, format = "%b %d %Y")) %>% 
  # mutate(upload_date = format(upload_date, "%m-%d-%Y"))

iom_ethiopia_df <- iom_ethiopia_df %>% 
  mutate(description = str_replace_all(file_download_url_site, "%20", " ")) %>% 
  mutate(description = str_replace_all(description, "%28", "(")) %>% 
  mutate(description = str_replace_all(description, "%29", ")")) %>% 
  mutate(description = gsub("https://dtm.iom.int/sites/g/files/tmzbdl1461/files/datasets/", "", description)) %>% 
  mutate(description = str_replace_all(description, ".xlsx", ""))

# Data export 
# Example data frame structure and how to export those all data chunks to csv or store for current r session

"Apr 02 2021" <- openxlsx::read.xlsx(iom_ethiopia_df['file_download_url_site'][[1]][1])
"Jun 07 2021" <- openxlsx::read.xlsx(iom_ethiopia_df['file_download_url_site'][[1]][2])
openxlsx::read.xlsx("https://dtm.iom.int/sites/g/files/tmzbdl1461/files/datasets/DTM%20Ethiopia%20Emergency%20Site%20Assessment%20Round%205.xlsx")

# Custom download progress callback function
download_progress <- function(n, ...) {
  cat(sprintf("\rDownloading: %3.1f%%", min(100, n / 100) * 100))
  flush.console()
}

progress_callback <- function(progress) {
  cat(sprintf("\rReading: %3.1f%%", progress * 100))
  flush.console()
}

# Define a function to read Excel file given a URL
read_excel_file <- function(url) {
  openxlsx::read.xlsx(url)
}

# Use map2 to iterate over the rows of the data frame
result_list <- map2(iom_ethiopia_df$file_download_url_site, iom_ethiopia_df$upload_date, ~ read_excel_file(.x))

# Assign the results to individual variables (optional)
list2env(setNames(result_list, iom_ethiopia_df$upload_date), envir = .GlobalEnv)


# Define a function to read Excel file given a URL and save it as a CSV file
read_and_save_csv <- function(url, date) {
  data <- openxlsx::read.xlsx(url)
  openxlsx::write.xlsx(data, file = paste0(here::here(),  "/iom_ethiopia/csv_files/", date, ".xlsx"))
}

# Use pwalk with list argument
pwalk(list(iom_ethiopia_df$file_download_url_site, iom_ethiopia_df$upload_date), read_and_save_csv)

