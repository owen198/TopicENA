# ena_example.R
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages(c("rENA", "htmlwidgets", "htmltools", "devtools", "pkgload", "webshot2"))

library(rENA)

# Rscript topicena/ena_script.R ./demo/test_001/ena_input.csv ./demo/ 20

args <- commandArgs(trailingOnly = TRUE)
in_path <- normalizePath(args[1], mustWork = TRUE)
out_path <- normalizePath(args[2], mustWork = TRUE)
window_size_back <- as.integer(args[3])



message("argument[1]: ", in_path)
message("argument[2]: ", out_path)
message("argument[3]: ", window_size_back)


data <- read.csv(in_path) 

unitCols = c("Condition", "UserName")

headers <- colnames(data)
codesCols <- setdiff(
  headers,
  c("Condition", "ActivityNumber", "UserName", "text", "doc_id")
)

conversationCols = c(
  "Condition",
  "ActivityNumber"
)



groupsVar = "Condition"
groups = c("high", "low")



set.ena = ena(
  data = data,
  units = unitCols,
  codes = codesCols,
  conversation = conversationCols,
  window.size.back = window_size_back,
  groupVar = groupsVar,
  groups = groups,
  mean = TRUE
)





# high.lineweights = as.matrix(set.ena$line.weights$Condition$high)
# low.lineweights = as.matrix(set.ena$line.weights$Condition$low)

# high.mean = as.vector(colMeans(high.lineweights))
# low.mean = as.vector(colMeans(low.lineweights))

# ena.plot(set.ena, title = "High mean plot") |>
#   ena.plot.network(network = high.mean, colors = c("red"))

# ena.plot(set.ena, title = "Low mean plot") |>
#   ena.plot.network(network = low.mean, colors = c("blue"))

# subtracted.mean = high.mean - low.mean

# p = ena.plotter(
#   set.ena,
#   title = "Subtracted: High (red) - Low (blue)"
# ) |>
#   ena.plot.network(
#     network = subtracted.mean * 5,  # optional rescaling
#     colors = c("red", "blue")
#   )





# outfile  <- file.path(out_path, "ena_plot.png")

# p = ena.plotter(set.ena,
#                    mean = T,
#                    points = T,
#                    network = T,
#                    print.plots = T,
#                    groupVar = "Condition",
#                    groups = c("high","low"),
#                    subtractionMultiplier = 5)

p = ena.plotter(set.ena,
                   mean = T,
                   network = T,
                   print.plots = T,
                   groupVar = "Condition",
                   groups = c("high","low"),
                   subtractionMultiplier = 5)


save_ena_html_and_png <- function(p, out_dir=".", prefix="ena",
                                  width=1600, height=1200, zoom=2, delay=1) {

  for (g in names(p$plots)) {
    w <- p$plots[[g]]$plot

    html_file <- file.path(out_dir, sprintf("%s_%s.html", prefix, g))
    png_file  <- file.path(out_dir, sprintf("%s_%s.png",  prefix, g))

    htmlwidgets::saveWidget(
      widget = w,
      file = html_file,
      selfcontained = TRUE
    )

    webshot2::webshot(
      url    = normalizePath(html_file, winslash = "/"),
      file   = png_file,
      vwidth = width,
      vheight = height,
      zoom   = zoom,
      delay  = delay
    )
  }
}  

save_ena_html_and_png(p, out_dir=out_path, prefix="ena",
                      width=500, height=500, zoom=2, delay=1.5)



# message("Wrote: ", normalizePath(outfile, winslash = "/", mustWork = FALSE))
# message("Exists? ", file.exists(outfile))


# ena_first_points_d1 = as.matrix(set.ena$points$Condition$HDSE)[,1]
# ena_second_points_d1 = as.matrix(set.ena$points$Condition$LDSE)[,1]
# ena_first_points_d2 = as.matrix(set.ena$points$Condition$HDSE)[,2] 
# ena_second_points_d2 = as.matrix(set.ena$points$Condition$LDSE)[,2]
# t_test_d1 = t.test(ena_first_points_d1, ena_second_points_d1)
# t_test_d2 = t.test(ena_first_points_d2, ena_second_points_d2)
# t_test_d1
# t_test_d2


# mean(ena_first_points_d1)
# mean(ena_second_points_d1)
# mean(ena_first_points_d2)
# mean(ena_second_points_d2)
# sd(ena_first_points_d1)
# sd(ena_second_points_d1)
# sd(ena_first_points_d2)
# sd(ena_second_points_d2)
# length(ena_first_points_d1)
# length(ena_second_points_d1)
# length(ena_first_points_d2)
# length(ena_second_points_d2)