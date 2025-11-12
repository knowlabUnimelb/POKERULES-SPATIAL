# Compute stats on LogicalRulesData using Joe's code
rm(list = ls()) # Clear the global workspace
cat("\014")     # Clear the screen
graphics.off()

# Uncomment these if you haven't already installed them
#install.packages("sft")      # Install Joe's SFT package



# Load all of the installed packages
library(sft)      # sft
library(graphics)
library(here)

# Change the working directory
setwd("/Users/sarahmoneer/Dropbox/experiments/2015 POKERULES/Data Analysis (Using Toolbox)/RanalysisFiles_Hemifields")
#setwd(file.path("C:", "Users", "littled", "Dropbox", "Work", "POKERULES", "analysis", "2015 POKERULES", "Data Analysis (Using Toolbox)", "ranalysisfiles"))


# Subject information
dataPrefix <- "2017_PokeRules_ROT" # String at the beginning of data file
subjectNumber <- "309"

# Read data
datafilename <- paste(paste("R_analysis", dataPrefix, subjectNumber, sep = "_", collapse = NULL), ".dat", sep = "")
data <- read.table(datafilename, sep = "\t", header = FALSE, row.names = NULL)
names(data) = c("Subject", "Condition", "RT", "Correct", "Channel1", "Channel2")

# Separate out target category items
target <- data[data$Channel1 > 0 & data$Channel2 > 0, ]

hh <- target$RT[target$Channel1 == 2 & target$Channel2 == 2]
hl <- target$RT[target$Channel1 == 2 & target$Channel2 == 1]
lh <- target$RT[target$Channel1 == 1 & target$Channel2 == 2]
ll <- target$RT[target$Channel1 == 1 & target$Channel2 == 1]

# Test SIC
sicresults <- sic(hh, hl, lh, ll)

# Set up time
mint = 0
maxt = 5000
dt = 10
t <- seq(mint, maxt, dt)

# Get SIC function
f_sic <- sicresults$SIC(t)

# Plot SIC function
plot(t, f_sic, type = "l", main = paste("SIC", "Subject", subjectNumber),
     xlab = "time", ylab = "SIC(t)")
lines(t, rep(0, 1, length(t)))

# Print stochastic dominance test
cat("\014")     # Clear the screen
print(sicresults$Dominance)
# If Stochastic Dominance assumption is met: First 4 results shoudl be significant, Last 4 should not

# Print sic test results
sicresults$SICtest$positive

# Print sic test results
sicresults$SICtest$negative

# Print the MIC
sicresults$MIC