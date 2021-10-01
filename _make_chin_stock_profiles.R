
f <- "objects/2017ChinFRAMBP_StockProfilesJul24_2017xlsx.xlsx"

(f_sheets_to_read <- readxl::excel_sheets(f)[18:130])

form_fields <- readxl::read_excel(f, sheet = f_sheets_to_read[1], range = "A2:A10", col_names = "v1") |> 
  dplyr::mutate(v1 = stringr::str_remove(v1, ":")) |> unlist() |> as.character()

form_fields[4] <- "Calibration CWT Groups"
form_fields[6] <- "Accounted in Terminal Rund (TR/TAA)"

stock_profiles <- purrr::map_dfr(
  f_sheets_to_read,
  ~readxl::read_excel(f, .x, range = "B2:B10", col_names = "v") |>
    tibble::rownames_to_column("row") |> 
    tidyr::pivot_wider(names_from = row, values_from = v)
  ) |> 
  purrr::set_names(form_fields)

saveRDS(stock_profiles, "objects/chin_stock_profiles.rds")


# stock_profiles |>  
#   dplyr::mutate(
#     dplyr::across(1:3, factor)
#   ) |> 
#   DT::datatable(
#     class = "compact row-border",
#     filter = "top",
#     rownames = FALSE,
#     options = list(
#       dom = "ltp",
#       autowidth = TRUE,
#       scrollX=TRUE,
#       pageLength = 3
#       ,columnDefs = list(
#         list(color = "pink", targets = 2:5)
#       )
#     )
#   )
# 
