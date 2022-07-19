require("httr")
require("jsonlite")
require("plotly")
library(tidyverse)
library(plotly)
library(htmlwidgets)
options(warn = -1)
require("anytime")

repeat {

mat <- matrix(ncol = 0, nrow = 0)
all_p <- data.frame(mat)
i <- 0

cat("Amount of players to compare: ")
qtyp <- readLines("stdin", 1)

while (i < qtyp) {

cat("\nPlayer ", i+1, " Name: ")
name1 <- readLines("stdin", 1)
cat("Player ", i+1, " Steam ID: ")
mysteam1 <- readLines("stdin", 1)

p1 <- paste0("https://aoe2.net/api/player/ratinghistory?game=aoe2de&leaderboard_id=3&steam_id=",mysteam1,"&count=1000")
p1 <- GET(p1)
p1_text <- content(p1, "text")
p1_json <- fromJSON(p1_text, flatten = TRUE)
p1 <- as.data.frame(p1_json)
p1 <- cbind(p1, player = name1)

all_p <- rbind(all_p, p1)
i <- i + 1
}
all_p <- mutate(all_p, Date = anydate(timestamp))
fig <- plot_ly(data = all_p, x = ~Date, y = ~rating, color = ~player,  mode = 'lines+markers', type = "scatter") 

widget_file_size <- function(fig) {
  d <- tempdir()
  withr::with_dir(d, htmlwidgets::saveWidget(fig, "index.html"))
  f <- file.path(d, "index.html")
  mb <- round(file.info(f)$size / 1e6, 3)
  message("File is: ", mb," MB")

}

fig
saveWidget(fig, "eloPlotly.html", selfcontained = F, libdir = "lib")

cat("\nFile saved to: ", getwd(), ". Start again? Y/N: ", sep = "")
fin <- readLines("stdin", 1)

if (fin == "N" || fin == "n"){
break
}
}
