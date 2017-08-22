# Fetch raw data from web sources.

#####
# Setup
api_key <- list()
key_txt <- readLines("analysis/api_keys.txt")
for(key_line in key_txt) {
  api <- strsplit(key_line, ", ")[[1]]
  k <- api[[1]]
  v <- api[[2]]
  api_key[k] <- v
}



# 1. FRED US All employees manufacturing / all employees non-farm, 1939-2015 (ADH fig 1)





# 2. China's share of World Manufacturing Activity, 1990-2012 (ADH fig 2)



