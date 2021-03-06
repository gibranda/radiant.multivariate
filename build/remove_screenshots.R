## based on https://gist.github.com/mages/1544009
cdir <- setwd("~/gh/radiant.multivariate/inst/app/tools/help")

## remove all local png files
list.files("./figures/", pattern = "*.png")
unlink("figures/*.png")
check <- list.files("./figures/", pattern = "*.png")
stopifnot(length(check) == 0)
cat("--", file="figures/place_holder.txt")

fn <- list.files(pattern="\\.(md|Rmd)$")
for (f in fn) {
  f <- fn[1]
  org <- readLines(f)
  changed <- gsub("figures_multivariate/", "https://radiant-rstats.github.io/docs/multivariate/figures_multivariate/", org)
  cat(changed, file=f, sep="\n")
}

setwd(cdir)
