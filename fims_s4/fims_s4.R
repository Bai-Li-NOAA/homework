# S3, S4, and Reference class (RC) examples are from Advanced R: http://adv-r.had.co.nz/OO-essentials.html

# Install required packages ---------------------------------------

required_pkg <- c(
  "sloop", 
  "stats4",
  "lobstr"
)
pkg_to_install <- required_pkg[!(required_pkg %in%
                                   installed.packages()[, "Package"])]
if (length(pkg_to_install)) install.packages(pkg_to_install)
invisible(lapply(required_pkg, library, character.only = TRUE))

remotes::install_github("NOAA-FIMS/FIMS")
library(FIMS)
# S3 example ------------------------------------------------------
df <- data.frame(x = 1:10, y = letters[1:10])
sloop::otype(df) #> [1] "S3"
base::isS4(df) #> [1] FALSE
base::mode(df) #> [1] "list"
inherits(df, "envRefClass") #> [1] FALSE

sloop::otype(df$x) #> [1] "base"
sloop::otype(df$y) #> [1] "base"

sloop::ftype(mean) #> [1] "s3"      "generic"
base::isS4(mean) #> [1] FALSE
base::inherits(mean, "envRefClass") #> [1] FALSE

# S4 example ------------------------------------------------------

# From example(mle)
y <- c(26, 17, 13, 12, 20, 5, 9, 8, 5, 4, 8)
nLL <- function(lambda) - sum(dpois(y, lambda, log = TRUE))
fit <- stats4::mle(nLL, start = list(lambda = 5), nobs = length(y))

sloop::otype(fit) #> [1] "S4"
base::isS4(fit) #> [1] TRUE
base::mode(fit) #> [1] "S4"
base::inherits(fit, "envRefClass") #> [1] FALSE

# An S4 generic
isS4(stats4::nobs) #> [1] TRUE
sloop::ftype(stats4::nobs) #> [1] "s4"      "generic"
base::isS4(stats4::nobs) #> [1] TRUE
base::inherits(stats4::nobs, "envRefClass") #> [1] FALSE

# Reference class example -----------------------------------------

Account <- setRefClass("Account",
                       fields = list(balance = "numeric"))
sloop::otype(Account) #> [1] "RC"
base::isS4(Account) #> [1] TRUE
base::inherits(Account, "envRefClass") #> [1] FALSE

a <- Account$new(balance = 100)
sloop::otype(a) #> [1] "RC"
base::isS4(a) #> [1] TRUE
base::mode(a) #> [1] "S4"
base::inherits(a, "envRefClass") #> [1] TRUE

# FIMS example ----------------------------------------------------

## data
age_frame <- FIMS::FIMSFrameAge(data_mile1)

sloop::otype(age_frame) #> [1] "S4"
base::isS4(age_frame) #> [1] TRUE
base::mode(age_frame) #> [1] "S4"
base::inherits(age_frame, "envRefClass") #> [1] FALSE

fims_frame <- FIMS::FIMSFrame(data_mile1)

sloop::otype(fims_frame) #> [1] "S4"
base::isS4(fims_frame) #> [1] TRUE
base::mode(fims_frame) #> [1] "S4"
base::inherits(fims_frame, "envRefClass") #> [1] FALSE

## fims
fims <- Rcpp::Module("fims", PACKAGE = "FIMS")

sloop::otype(fims) #> [1] "S4"
base::isS4(fims) #> [1] TRUE
base::mode(fims) #> [1] "S4"
base::inherits(fims, "envRefClass") #> [1] FALSE

## ewaa
ewaa_growth <- new(fims$EWAAgrowth)

ewaa_data <- age_frame@weightatage

sloop::otype(ewaa_data) #> [1] "S3"
base::isS4(ewaa_data) #> [1] FALSE
base::mode(ewaa_data) #> [1] "list"
base::inherits(ewaa_data, "envRefClass") #> [1] FALSE


ewaa_growth$ages <- unique(ewaa_data$age)

sloop::otype(ewaa_growth$ages) #> [1] "base"
sloop::otype(ewaa_growth) #> [1] "RC"
base::isS4(ewaa_growth) #> [1] TRUE
base::mode(ewaa_growth) #> [1] "S4"
base::inherits(ewaa_growth, "envRefClass") #> [1] TRUE

## fleet
selectivity_fleet1 <- new(fims$LogisticSelectivity)

sloop::otype(selectivity_fleet1) #> [1] "RC"
base::isS4(selectivity_fleet1) #> [1] TRUE
base::mode(selectivity_fleet1) #> [1] "S4"
base::inherits(selectivity_fleet1, "envRefClass") #> [1] TRUE

fleet <- new(fims$Fleet)

fleet$SetObservedAgeCompData(1)
sloop::otype(fleet) #> [1] "RC"
base::isS4(fleet) #> [1] TRUE
base::mode(fleet) #> [1] "S4"
base::inherits(fleet, "envRefClass") #> [1] TRUE

## recruitment
recruitment <- new(fims$BevertonHoltRecruitment)
recruitment$steep$value <- 0.75
recruitment$steep$is_random_effect <- TRUE
recruitment$steep$estimated <- TRUE
recruitment$rzero$value <- 1000000

sloop::otype(recruitment) #> [1] "RC"
base::isS4(recruitment) #> [1] TRUE
base::mode(recruitment) #> [1] "S4"
base::inherits(recruitment, "envRefClass") #> [1] TRUE

sloop::otype(recruitment$steep) #> [1] "RC"
base::isS4(recruitment$steep) #> [1] TRUE
base::mode(recruitment$steep) #> [1] "S4"
base::inherits(recruitment$steep, "envRefClass") #> [1] TRUE

sloop::otype(recruitment$steep$value) #> [1] "base"
base::isS4(recruitment$steep$value) #> [1] FALSE
base::mode(recruitment$steep$value) #> [1] "numeric"
base::inherits(recruitment$steep$value, "envRefClass") #> [1] FALSE

# Check object size
lobstr::obj_size(recruitment) #> 3.34 MB

