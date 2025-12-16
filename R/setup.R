# nolint start
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
#if (!requireNamespace("gmsp", quietly = TRUE)) devtools::install_github("averriK/gmsp")
if (!requireNamespace("dsra", quietly = TRUE)) devtools::install_github("averriK/dsra")
if (!requireNamespace("NGR", quietly = TRUE)) devtools::install_github("averriK/NGR")
#if (!requireNamespace("newmark", quietly = TRUE)) devtools::install_github("averriK/newmark")

#library(newmark)
library(dsra)
library(NGR)
#library(gmsp)

library(data.table)
library(grid)
library(png)
library(knitr)
library(highcharter)
library(htmlwidgets)
library(webshot2)
# nolint end
# ======================================================================

ID_max <- "max"

# ======================================================================

buildEnvelope <- function(DT) {
  if (!inherits(DT, "data.table")) {
    DT <- as.data.table(DT)
  }

  if (!all(c("X", "Y", "ID") %in% names(DT))) {
    stop("DT must contain columns X, Y and ID")
  }

  # Remove any existing envelope IDs
  DT <- DT[!ID %in% c(".max", ".min")]

  # Ensure fill column exists and start with all FALSE
  if (!"fill" %in% names(DT)) {
    DT[, fill := FALSE]
  } else {
    DT[, fill := FALSE]
  }

  COLS <- names(DT)

  # Upper envelope: for each X, point with maximum Y among all IDs
  MAX <- DT[, .SD[which.max(Y)], by = X]
  MAX[, ID := ".max"]

  # Lower envelope: for each X, point with minimum Y among all IDs
  MIN <- DT[, .SD[which.min(Y)], by = X]
  MIN[, ID := ".min"]

  # Make sure MAX and MIN have exactly the same columns as DT
  for (N in COLS) {
    if (!N %in% names(MAX)) MAX[, (N) := NA]
    if (!N %in% names(MIN)) MIN[, (N) := NA]
  }
  setcolorder(MAX, COLS)
  setcolorder(MIN, COLS)

  # Mark only envelopes for fill shading
  MAX[, fill := TRUE]
  MIN[, fill := TRUE]

  DATA <- rbindlist(list(DT, MAX, MIN), use.names = TRUE)
  DATA[]
}

# ======================================================================

data_path <- file.path(root, "oq","data")

# Generic reader that stops if the file does not exist.
# Pass the desired reader function (e.g., readRDS, data.table::fread, yaml::read_yaml).
FileRead <- function(file, hint, read_fun, ...) {
  if (!file.exists(file)) {
    stop(paste0("Missing data: ", basename(file), ". ", hint))
  }
  read_fun(file, ...)
}

FILE <- file.path(root, "yml", "params.yml")
params <- FileRead(FILE, "Missing params.yml in yml/ folder", yaml::read_yaml)$params

FILE <- file.path(data_path, "UHSTable.Rds")
UHSTable <- FileRead(FILE, "Run oqt --uhs first", readRDS)

FILE <- file.path(data_path, "AEPTable.Rds")
AEPTable <- FileRead(FILE, "Run oqt --aep first", readRDS)

FILE <- file.path(data_path, "DnTable.Rds")
DnTable <- FileRead(FILE, "Run oqt --dn first", readRDS)

FILE <- file.path(data_path, "kmaxTable.Rds")
kmaxTable <- FileRead(FILE, "Run oqt --kmax first", readRDS)

FILE <- file.path(data_path, "ShearTable.Rds")
ShearTable <- FileRead(FILE, "Run oqt --dn first", readRDS)

# ======================================================================
# Fix fractiles ID
UHSTable[p=="0.1",p:="0.10"]
AEPTable[p=="0.1",p:="0.10"]
DnTable[p=="0.1",p:="0.10"]
kmaxTable[p=="0.1",p:="0.10"]

# ======================================================================


ID_gmdp <- UHSTable$ID |>  unique() 
TR_gmdp <- UHSTable$TR |>  unique() |>   sort()
Tn_gmdp <- UHSTable$Tn |>  unique() |>   sort()
p_gmdp <- UHSTable$p |> unique()
Tn_PGA <- min(UHSTable$Tn )
Vs30_gmdp <- UHSTable$Vs30 |>
  unique() |>
  as.numeric() |>
  sort()
Vref_gmdp <- UHSTable$Vref |>
  unique() |>
  as.numeric()

# ======================================================================
#
IDg_gmdp <- DnTable$IDg |> unique()
IDm_gmdp <- DnTable$IDm |> unique()
# Sort sections
IDg_gmdp <- IDg_gmdp[order(as.numeric(sub("^S", "", IDg_gmdp)))]

# Newmark Displacement Units
Dn_units <- "mm"
# Target Newmark Displacement (for kmax/kh) in Dn_units
Da_gmdp <- c(10, 100, 1000) # [mm]
# ======================================================================
p_TARGET <- NULL
S_TARGET <- NULL

NMAX <- 2500
PALETTE <-  "Set1"
DELAY <- 0.3


PAGE_WIDTH <- 8.27
PAGE_HEIGHT <- 11.69
FACTOR_WIDTH <- 1
FACTOR_HEIGHT <- 0.5
THIN_LINE_SIZE <- 0.65
MED_LINE_SIZE <- 1
THICK_LINE_SIZE <- 3.5


THIN_LINE_SIZE <- 0.75
MID_LINE_SIZE <- 1.5
THICK_LINE_SIZE <- 5

GG_THEME <- ggplot2::theme_light()
HC.THEME <- highcharter::hc_theme_hcrt()

if (knitr::is_html_output()) {
  FONT.SIZE.BODY <- 11
  FONT.SIZE.HEADER <- 12


} else {
  FONT.SIZE.BODY <- 10
  FONT.SIZE.HEADER <- 10
}


# nolint start
.buildFigure <- function(PLOT, DATA, DELAY = 0.3, imagesFolder = "_var", params = list(background = "white")) {
    FILE <- tempfile(tmpdir = imagesFolder, pattern = "fig", fileext = ".png")
    AUX <- tempfile(pattern = "fig", fileext = ".html")

    # Ensure cleanup of temporary files
    on.exit(
        {
            unlink(AUX)
        },
        add = TRUE
    )

    XDELAY <- max(DELAY, round(nrow(DATA) / 1500 * DELAY, digits = 2))
    htmlwidgets::saveWidget(widget = PLOT, background = params$background, file = AUX, selfcontained = TRUE)
    webshot2::webshot(delay = XDELAY, url = AUX, file = FILE)
    FIG <- knitr::include_graphics(path = FILE)

    return(FIG)
}

random_label <- function(prefix = "fig") {
    paste0(prefix, "_", as.character(as.numeric(Sys.time())), sample.int(1e95, 1)) # pick from 1..1e9
}



# nolint end

