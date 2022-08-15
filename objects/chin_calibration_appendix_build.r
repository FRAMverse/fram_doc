library(tidyverse)

# Connect to calibration database
db <- "O:/code/Documentation/Chinook Base Period/CalibrationSupport_2021_Rd7.1_Final.mdb"

db_con <- DBI::dbConnect(drv = odbc::odbc(), .connection_string = paste0("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=", 
    db, ";"))

calib_db <- list(
            aeq = "AEQ", 
            basecohort = "BaseCohort",
            baseexploitationrate = "BaseExploitationRate",
            baseperiodcatch = "BasePeriodCatch",
            baseperiodcatchtot = "BasePeriodCatch_Tot",
            bpescapements = "BPEscapements",
            bpescapementstot = "BPEscapements_Tot",
            bpsizelimits = "BPSizeLimits",
            fishery = "Fishery",
            fisheryflag = "FisheryFlag",
            fisherymodelstockproportion = "FisheryModelStockproportion",
            fisherymodelstockproportiontot = "FisheryModelStockproportion_Tot",
            fishscalar = "FishScalar",
            growth = "Growth",
            imputerecoveries = "ImputeRecoveries",
            incidentalrate = "IncidentalRate",
            maturationrate = "MaturationRate",
            naturalmortality = "NaturalMortality",
            nonretention = "NonRetention",
            nonretentiontot = "NonRetention_Tot",
            proportiontreatynet = "ProportionTreatyNet",
            shakerinclusion = "ShakerInclusion",
            shakermortrate = "ShakerMortRate",
            sizelimits = "SizeLimits",
            stock = "Stock",
            summaryinfo = "SummaryInfo",
            surrogatefishbper = "SurrogateFishBPER",
            targetencounterrates = "TargetEncounterRates",
            terminalfisheryflag = "TerminalFisheryFlag",
            timestep = "TimeStep",
            weighting = "Weighting",
            whitematrate = "WhiteMatRate"
          ) |> 
          map(~collect(tbl(db_con, .x)))

DBI::dbDisconnect(db_con)

# AEQ

calib_db$aeq |> 
  select(2:5) |>   
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |> 
  rename(`Time Step` = TimeStep,
         `Stock Long Name` = StockLongName) |> 
  mutate(AEQ = round(AEQ, 4)) |> 
  select(1, 5, 2:4) |> 
  knitr::kable(caption = "Chinook AEQ") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinaeq.rds")

# BaseCohort

calib_db$basecohort |> 
  select(2:4) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |> 
  rename(`Stock Long Name` = StockLongName) |> 
  select(1, 4, 2:3) |> 
  mutate(Age = paste("Age", Age),
         BaseCohortSize = round(BaseCohortSize)) |> 
  pivot_wider(names_from = Age, values_from = BaseCohortSize) |> 
  knitr::kable(caption = "Chinook base period cohort abundances")  |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinbasecohort.rds")

# BaseExploitationRate

calib_db$baseexploitationrate |> 
  select(2:7) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |> 
  select(1, 7, 2:3, 8, 4:6) |> 
  mutate(ExploitationRate = round(ExploitationRate, 5),
         SubLegalEncounterRate = round(SubLegalEncounterRate, 5)) |> 
  rename(`Exploitation Rate` = ExploitationRate,
         `Sub-legal Encounter Rate` = SubLegalEncounterRate,
         `Time Step` = TimeStep,
         `Stock Long Name` = StockLongName,
         `Fishery Title` = FisheryTitle) |> 
  knitr::kable(caption = "Chinook base period exploitation rates")  |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinbaseexploitationrate.rds")

# BasePeriodCatch

calib_db$baseperiodcatch |> 
  select(5:6, 4, 7, 3) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |> 
  select(1, 6, 2:5) |> 
  mutate(ModelStockProportion = round(ModelStockProportion, 4)) |> 
  rename(`Base Period Catch` = BPCatch,
         `Model Stock Proportion` = ModelStockProportion,
         `Time Step` = TimeStep,
         `Fishery Title` = FisheryTitle) |> 
  knitr::kable(caption = "Chinook base period marked catch") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinbaseperiodcatch.rds")

# BasePeriodCatch_Tot

calib_db$baseperiodcatchtot |> 
  select(5:6, 4, 7, 3) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |> 
  select(1, 6, 2:5) |> 
  mutate(ModelStockProportion = round(ModelStockProportion, 4)) |> 
  rename(`Base Period Catch` = BPCatch,
         `Model Stock Proportion` = ModelStockProportion,
         `Time Step` = TimeStep,
         `Fishery Title` = FisheryTitle) |> 
  knitr::kable(caption = "Chinook base period total catch") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinbaseperiodcatch_tot.rds")

# BPEscapements

calib_db$bpescapements |> 
  select(3:4) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  select(1, 3, 2) |> 
  rename(`Marked Escapement` = Escapement) |> 
  left_join(calib_db$bpescapementstot |> select(3:4), by = "StockID") |> 
  rename(`Total Escapement` = Escapement,
         `Stock Long Name` = StockLongName) |> 
  knitr::kable(caption = "Chinook base period escapement")  |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinbpescapements.rds")

# BPSizeLimits

calib_db$bpsizelimits |> 
  select(2:4) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |> 
  rename(`Fishery Title` = FisheryTitle) |> 
  mutate(TimeStep = paste("Time Step", TimeStep)) |> 
  pivot_wider(names_from = TimeStep, values_from = MinimumSize) |> 
  knitr::kable(caption = "Chinook base period size limits (mm)")  |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinbpsizelimits.rds")

# Fishery

calib_db$fishery |> 
  select(3:5) |> 
  rename(`Fishery Name` = FisheryName,
         `Fishery Title` = FisheryTitle) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook fisheries")  |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinfishery.rds")

# FisheryFlag

calib_db$fisheryflag |> 
  select(2:3) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 3, 2) |> 
  rename(`Fishery Flag` = FishFlag,
         `Fishery Title` = FisheryTitle) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook fishery flags") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinfisheryflag.rds")

# FisheryModelStockproportion

calib_db$fisherymodelstockproportion |> 
  select(2:3) |> 
  rename(`Marked Model Stock Proportion` = ModelStockProportion) |> 
  left_join(calib_db$fisherymodelstockproportiontot |> select(2:3), by = "FisheryID") |> 
  rename(`Total Model Stock Proportion` = ModelStockProportion) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |> 
  rename(`Fishery Title` = FisheryTitle) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook fishery model stock proportion") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinfisherymodelstockproportion.rds")

# FishScalar

calib_db$fishscalar |> 
  select(2, 5, 4, 3) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1:2, 5, 3:4) |> 
  mutate(TimeStep = paste("Time Step", TimeStep)) |> 
  pivot_wider(names_from = TimeStep, values_from = FishScalar) |> 
  rename(`Fishing Year` = FishingYear,
         `Fishery Title` = FisheryTitle) |> 
  arrange(`Fishing Year`, FisheryID) |> 
  knitr::kable(caption = "Chinook fishery scalars") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinfishscalar.rds")

# Growth

calib_db$growth |> 
  select(3:17) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  select(1, 16, 2:15) |> 
  rename(`Linf Immature` = LImmature,
         `K Immature` = KImmature,
         `t0 Immature` = TImmature,
         `Age 2 CV Immature` = CV2Immature,
         `Age 3 CV Immature` = CV3Immature,
         `Age 4 CV Immature` = CV4Immature,
         `Age 5 CV Immature` = CV5Immature,
         `Linf Mature` = LMature,
         `K Mature` = KMature,
         `t0 Mature` = TMature,
         `Age 2 CV Mature` = CV2Mature,
         `Age 3 CV Mature` = CV3Mature,
         `Age 4 CV Mature` = CV4Mature,
         `Age 5 CV Mature` = CV5Mature,
         `Stock Long Name` = StockLongName) |> 
  mutate(across(c(`Age 2 CV Immature`:`Age 5 CV Immature`,
                  `Age 2 CV Mature`:`Age 5 CV Mature`),
                ~round(.x, 5))) |> 
  arrange(StockID) |> 
  knitr::kable(caption = "Chinook growth parameters") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchingrowth.rds")

# ImputeRecoveries

calib_db$imputerecoveries |> 
  select(2:6) |> 
  rename(`Surrogate FisheryID` = SurrogateFishery,
         `Surrogate Time Step` = SurrogateTimeStep,
         `Recipient FisheryID` = RecipientFishery,
         `Recipient Time Step` = RecipientTimeStep) |> 
  left_join(calib_db$fishery |> select(3, 5), by = c("Surrogate FisheryID" = "FisheryID")) |>
  rename(`Surrogate Fishery Name` = FisheryTitle) |> 
  left_join(calib_db$fishery |> select(3, 5), by = c("Recipient FisheryID" = "FisheryID")) |>
  rename(`Recipient Fishery Name` = FisheryTitle) |> 
  select(1:2, 6, 3:4, 7, 5) |> 
  knitr::kable(caption = "Chinook surrogate fishery and time step assignments") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinimputerecoveries.rds")

# IncidentalRate

calib_db$incidentalrate |> 
  select(2:4) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |> 
  rename(`Fishery Title` = FisheryTitle) |> 
  mutate(TimeStep = paste("Time Step", TimeStep)) |> 
  pivot_wider(names_from = TimeStep, values_from = IncidentalRate) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook incidental mortality rates") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinincidentalrate.rds")

# MaturationRate

calib_db$maturationrate |> 
  select(2:5) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  select(1, 5, 2:4) |> 
  rename(`Stock Long Name` = StockLongName) |> 
  mutate(TimeStep = paste("Time Step", TimeStep),
         MaturationRate = round(MaturationRate, 4)) |> 
  pivot_wider(names_from = TimeStep, values_from = MaturationRate) |> 
  arrange(StockID, Age) |> 
  knitr::kable(caption = "Chinook maturation rates") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinmaturationrate.rds")

# NaturalMortality

calib_db$naturalmortality |> 
  select(3:5) |> 
  mutate(TimeStep = paste("Time Step", TimeStep),
         NaturalMortalityRate = round(NaturalMortalityRate, 4)) |> 
  pivot_wider(names_from = TimeStep, values_from = NaturalMortalityRate) |> 
  arrange(Age) |> 
  knitr::kable(caption = "Chinook natural mortality rates") |> 
  kableExtra::kable_styling() |> 
  saveRDS("objects/framdoc_calibchinnaturalmortality.rds")

# NonRetention

calib_db$nonretention |> 
  select(4:8) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 6, 2:5) |> 
  mutate(across(CNRInput1:CNRInput2, ~round(.x))) |> 
  rename(`Time Step` = TimeStep,
         `Non-retention Flag` = NonRetentionFlag,
         `CNR Input 1` = CNRInput1,
         `CNR Input 2` = CNRInput2,
         `Fishery Title` = FisheryTitle) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook marked non-retention inputs") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinnonretention.rds")

# NonRetention_Tot

calib_db$nonretentiontot |> 
  select(4:8) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 6, 2:5) |> 
  mutate(across(CNRInput1:CNRInput2, ~round(.x))) |> 
  rename(`Time Step` = TimeStep,
         `Non-retention Flag` = NonRetentionFlag,
         `CNR Input 1` = CNRInput1,
         `CNR Input 2` = CNRInput2,
         `Fishery Title` = FisheryTitle) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook total non-retention inputs") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinnonretentiontot.rds")

# ProportionTreatyNet

calib_db$proportiontreatynet |> 
  select(2:4) |>
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |>
  rename(`Fishery Title` = FisheryTitle) |>
  mutate(TimeStep = paste("Time Step", TimeStep),
         PpnTreaty = round(PpnTreaty, 4)) |> 
  pivot_wider(names_from = TimeStep, values_from = PpnTreaty) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook proportion treaty net") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinproportiontreatynet.rds")

# ShakerInclusion

calib_db$shakerinclusion |> 
  select(2:4) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2, 5, 3) |> 
  rename(`Fishery Title` = FisheryTitle,
         `Stock Long Name` = StockLongName,
         `Shaker Inclusion Flag` = ShakerInclusionFlag) |> 
  arrange(StockID, FisheryID) |> 
  knitr::kable(caption = "Chinook shaker inclusion") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinshakerinclusion.rds")

# ShakerMortRate

calib_db$shakermortrate |> 
  select(3:5) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |> 
  mutate(TimeStep = paste("Time Step", TimeStep)) |> 
  pivot_wider(names_from = TimeStep, values_from = ShakerMortRate) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook shaker mortality rate") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinshakermortrate.rds")

# SizeLimits

calib_db$sizelimits |> 
  select(2:5) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1:2, 5, 3:4) |> 
  rename(`Fishery Title` = FisheryTitle) |> 
  mutate(TimeStep = paste("Time Step", TimeStep)) |> 
  arrange(TimeStep) |> 
  pivot_wider(names_from = TimeStep, values_from = MinimumSize) |> 
  arrange(FishingYear, FisheryID) |> 
  knitr::kable(caption = "Chinook size limits (mm)") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinsizelimits.rds")

# Stock

calib_db$stock |> 
  select(3, 6:7) |>
  rename(`Stock Name` = StockName,
         `Long Stock Name` = StockLongName) |> 
  arrange(StockID) |> 
  knitr::kable(caption = "Chinook calibration stocks") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinstocks.rds")

# SummaryInfo

calib_db$summaryinfo |> 
  select(2:ncol(calib_db$summaryinfo)) |>
  mutate(across(everything(), ~as.character(.x))) |> 
  pivot_longer(everything(), names_to = "Description", values_to = "Value") |> 
  mutate(Description = gsub("([A-Z])", " \\1", Description)) |> 
  knitr::kable(caption = "Chinook calibration summary information") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinsummaryinfo.rds")

# SurrogateFishBPER

calib_db$surrogatefishbper |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  select(1, 8, 2, 3, 7, 4:6) |> 
  rename(`Time Step` = TimeStep,
         `Exploitation Rate` = ExploitationRate,
         `Fishery Title` = FisheryTitle,
         `Stock Long Name` = StockLongName) |> 
  mutate(`Exploitation Rate` = round(`Exploitation Rate`, 4)) |> 
  arrange(StockID, Age, FisheryID, `Time Step`) |> 
  knitr::kable(caption = "Chinook surrogate base period exploitation rates") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinsurrogatefishbper.rds")

# TargetEncounterRates

calib_db$targetencounterrates |> 
  select(2:4) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |> 
  rename(`Fishery Title` = FisheryTitle) |> 
  mutate(TimeStep = paste("Time Step", TimeStep)) |> 
  pivot_wider(names_from = TimeStep, values_from = TargetEncounterRate) |> 
  arrange(FisheryID) |> 
  knitr::kable(caption = "Chinook target encounter rates") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchintargetencounterrates.rds")

# TerminalFisheryFlag

calib_db$terminalfisheryflag |> 
  select(3:5) |> 
  left_join(calib_db$fishery |> select(3, 5), by = "FisheryID") |>
  select(1, 4, 2:3) |> 
  rename(`Time Step` = TimeStep,
         `Terminal Flag` = TerminalFlag,
         `Fishery Title` = FisheryTitle) |> 
  arrange(FisheryID, `Time Step`) |> 
  knitr::kable(caption = "Chinook terminal fishery flag") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinterminalfisheryflag.rds")

# TimeStep

# From DB
# calib_db$timestep |> 
#   select(3:5) |> 
#   rename(`Time Step` = TimeStepID,
#          `Time Step Name` = TimeStepName,
#          `Time Step Title` = TimeStepTitle) |> 
#   arrange(`Time Step`) |> 
#   knitr::kable(caption = "Chinook time steps") |> 
#   kableExtra::kable_styling() |> 
#   kableExtra::scroll_box(width = "100%", height = "500px") |> 
#   saveRDS("objects/framdoc_calibchintimestep.rds")

# Built separate 
dplyr::tibble(
  `Time Step` = c(1:4),
  Months = c("Preceding October - April", "May - June", "July - September", "October - April")
  ) |> 
  knitr::kable(caption = "Chinook time steps") |> 
  kableExtra::kable_styling() |> 
  saveRDS("objects/framdoc_calibchintimestep.rds")

# Weighting

calib_db$weighting |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  select(1:2, 7, 3:6) |> 
  rename(`Brood Year` = BroodYear,
         `Stock Long Name` = StockLongName) |> 
  arrange(StockID, `Brood Year`, Stage) |> 
  knitr::kable(caption = "Chinook weighting") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinweighting.rds")

# WhiteMatRate

calib_db$whitematrate |> 
  select(2:5) |> 
  left_join(calib_db$stock |> select(3, 7), by = "StockID") |>
  select(1, 5, 2:4) |> 
  rename(`Time Step` = TimeStep,
         `Maturation Rate` = MaturationRate,
         `Stock Long Name` = StockLongName) |> 
  arrange(StockID, Age, `Time Step`) |> 
  knitr::kable(caption = "Chinook White River maturation rates") |> 
  kableExtra::kable_styling() |> 
  kableExtra::scroll_box(width = "100%", height = "500px") |> 
  saveRDS("objects/framdoc_calibchinwhitematrate.rds")
