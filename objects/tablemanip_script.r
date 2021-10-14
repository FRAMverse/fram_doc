mydbstring <- "C:/Data/Valid2020_Round_7.1.1.mdb"

library(dplyr)

# Connect to database
#open a connection to a FRAM project file database
  db_con <- DBI::dbConnect(
    drv = odbc::odbc(),
    .connection_string = paste0("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=",mydbstring,";")
    )

# Read Stock Table
tbl(db_con, "Stock") %>% 
  filter(Species == "CHINOOK") %>% 
  select(StockID, StockName, StockLongName) %>% 
  collect() %>% 
  knitr::kable(caption = "Chinook stocks") %>%
  kableExtra::kable_styling() %>%
  kableExtra::scroll_box(width = "100%", height = "500px") %>%
  saveRDS("objects/framvs_doc_lu_stock_chin2.rds")

# Read update - can add dynamic update from database later
chin4ap <- read.csv("C:/Data/chin_ap4_udate.csv", check.names = FALSE)

# Read fishery table
tbl(db_con, "Fishery") %>% 
  filter(Species == "CHINOOK") %>% 
  select(FisheryID, FisheryName, FisheryTitle) %>%
  collect() %>%
  left_join(chin4ap[,c(1,3:4)], by = "FisheryID") %>%
  arrange(FisheryID) %>%
  knitr::kable(caption = "Chinook fisheries") %>%
  kableExtra::kable_styling() %>%
  kableExtra::scroll_box(width = "100%", height = "500px") %>%
  saveRDS("objects/framvs_doc_lu_fishery_chin2.rds")

#newer tables from MB with added fields
read_excel("O:/lit/fram_documents/fram_coho_fisheries_MBtable.xlsx") %>%
  knitr::kable(caption = "Coho fisheries") %>%
  kable_styling() %>%
  kableExtra::scroll_box(width = "100%", height = "500px") %>%
  saveRDS("objects/framvs_doc_lu_fishery_coho.rds")
read_excel("O:/lit/fram_documents/fram_coho_stocks_MBtable.xlsx") %>%
  knitr::kable(caption = "Coho stocks") %>%
  kable_styling() %>%
  kableExtra::scroll_box(width = "100%", height = "500px") %>%
  saveRDS("objects/framvs_doc_lu_stock_coho.rds")