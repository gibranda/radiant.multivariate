#' Attribute based brand maps
#'
#' @details See \url{https://radiant-rstats.github.io/docs/multivariate/pmap.html} for an example in Radiant
#'
#' @param dataset Dataset name (string). This can be a dataframe in the global environment or an element in an r_data list from Radiant
#' @param brand A character variable with brand names
#' @param attr Names of numeric variables
#' @param pref Names of numeric brand preference measures
#' @param nr_dim Number of dimensions
#' @param data_filter Expression entered in, e.g., Data > View to filter the dataset in Radiant. The expression should be a string (e.g., "price > 10000")
#'
#' @return A list of all variables defined in the function as an object of class pmap
#'
#' @examples
#' result <- pmap("computer","brand","high_end:business")
#'
#' @seealso \code{\link{summary.pmap}} to summarize results
#' @seealso \code{\link{plot.pmap}} to plot results
#'
#' @importFrom psych principal
#'
#' @export
pmap <- function(dataset, brand, attr,
                 pref = "",
                 nr_dim = 2,
                 data_filter = "") {

	nr_dim <- as.numeric(nr_dim)
	vars <- c(brand,attr)
	dat <- getdata(dataset, vars, filt = data_filter)

	brands <- dat[,1] %>% as.character %>% gsub("^\\s+|\\s+$", "", .)
	f_data <- dat[,-1]
	nrObs <- nrow(dat)

	# in case : is used
	if (length(attr) < ncol(f_data)) attr <- colnames(f_data)

	fres <- sshhr( psych::principal(cov(f_data), nfactors=nr_dim,
	               rotate='varimax', scores=FALSE, oblique.scores=FALSE) )

	m <- as.data.frame(fres$loadings[,colnames(fres$loadings)]) %>% as.matrix
	cscm <- m %*% solve(crossprod(m))
	# store in fres so you can re-use save_factors
	fres$scores <- scale(as.matrix(f_data), center = TRUE, scale = TRUE) %*% cscm
	rownames(fres$scores) <- brands

	if (!is_empty(pref)) {
		vars <- c(vars, pref)
		pref_cor <- sshhr(getdata(dataset, pref, filt = data_filter)) %>%
								  cor(fres$scores) %>%
								  data.frame
		pref_cor$communalities <- rowSums(pref_cor^2)
	}

	rm(f_data, m, cscm)

	if (!is_string(dataset)) dataset <- deparse(substitute(dataset)) %>% set_attr("df", TRUE)

	as.list(environment()) %>% add_class(c("pmap","full_factor"))
}

#' Summary method for the pmap function
#'
#' @details See \url{https://radiant-rstats.github.io/docs/multivariate/pmap.html} for an example in Radiant
#'
#' @param object Return value from \code{\link{pmap}}
#' @param cutoff Show only loadings with (absolute) values above cutoff (default = 0)
#' @param dec Rounding to use for output
#' @param ... further arguments passed to or from other methods
#'
#' @examples
#' result <- pmap("computer","brand","high_end:business")
#' summary(result)
#' summary(result, cutoff = .3)
#' result <- pmap("computer","brand","high_end:dated", pref = c("innovative","business"))
#' summary(result)
#' computer %>% pmap("brand","high_end:dated", pref = c("innovative","business")) %>%
#'   summary
#'
#' @seealso \code{\link{pmap}} to calculate results
#' @seealso \code{\link{plot.pmap}} to plot results
#'
#' @export
summary.pmap <- function(object,
                         cutoff = 0,
                         dec = 2,
                         ...) {

 	cat("Attribute based brand map\n")
	cat("Data        :", object$dataset, "\n")
	if (object$data_filter %>% gsub("\\s","",.) != "")
		cat("Filter      :", gsub("\\n","", object$data_filter), "\n")
	cat("Attributes  :", paste0(object$attr, collapse=", "), "\n")
	if (!is.null(object$pref) && object$pref != "")
		cat("Preferences :", paste0(object$pref, collapse=", "), "\n")
	cat("# dimensions:", object$nr_dim, "\n")
	cat("Rotation    : varimax\n")
	cat("Observations:", object$nrObs, "\n")

	cat("\nBrand - Factor scores:\n")
	round(object$fres$scores,dec) %>% print

	cat("\nAttribute - Factor loadings:\n")

	## convert loadings object to data.frame
	lds <- object$fres$loadings
	dn <- dimnames(lds)
	lds %<>% matrix(nrow = length(dn[[1]])) %>%
		set_colnames(dn[[2]]) %>% set_rownames(dn[[1]]) %>%
		data.frame

	## show only the loadings > ff_cutoff
  ind <- abs(lds) < cutoff
  print_lds <- round(lds,dec)
  print_lds[ind] <- ""
  print(print_lds)

	if (!is.null(object$pref) && object$pref != "") {
		cat("\nPreference correlations:\n")
		print(round(object$pref_cor,dec), digits = dec)
	}

  ## fit measures
	cat("\nFit measures:\n")
	colSums(lds^2) %>%
		rbind(., . / length(dn[[1]])) %>%
		rbind(., cumsum(.[2,])) %>%
		round(dec) %>%
		set_rownames(c("Eigenvalues","Variance %","Cumulative %")) %>%
		print

	cat("\nAttribute communalities:")
	data.frame(1 - object$fres$uniqueness) %>%
		set_colnames("") %>% round(dec) %>%
		print
}

#' Plot method for the pmap function
#'
#' @details See \url{https://radiant-rstats.github.io/docs/multivariate/pmap.html} for an example in Radiant
#'
#' @param x Return value from \code{\link{pmap}}
#' @param plots Components to include in the plot ("brand", "attr"). If data on preferences is available use "pref" to add preference arrows to the plot
#' @param scaling Arrow scaling in the brand map
#' @param fontsz Font size to use in plots
#' @param ... further arguments passed to or from other methods
#'
#' @examples
#' result <- pmap("computer", "brand", "high_end:business")
#' plot(result, plots = "brand")
#' plot(result, plots = c("brand", "attr"))
#' plot(result, plots = c("brand", "attr"))
#' plot(result, scaling = 1, plots = c("brand", "attr"))
#' result <- pmap("computer", "brand", "high_end:dated",
#'                pref = c("innovative", "business"))
#' plot(result, plots = c("brand", "attr", "pref"))
#'
#' @seealso \code{\link{pmap}} to calculate results
#' @seealso \code{\link{summary.pmap}} to plot results
#'
#' @importFrom wordcloud textplot
#'
#' @export
plot.pmap <- function(x,
                      plots = "",
                      scaling = 2.1,
                      fontsz = 1.3,
                      ...) {

	scaling <- as.numeric(scaling)
	object <- x; rm(x)

	std_pc <- scaling * object$pref_cor
	std_m <- scaling * object$fres$loadings
	std_scores <- object$fres$scores
	lab_buf <- 1.1

	## adding a buffer so the labels don't move off the screen
	lim <- max(abs(std_m), abs(std_scores)) * lab_buf

	# using ggplot is not an option at this time because labels are likely to overlap
	# the wordcloud with wordlayout package may be an option but it does not seem to produce the
	# desired effect
	# wctemp <- wordcloud::wordlayout(mtcars$wt, mtcars$mpg, rownames(mtcars), cex = 3)[,1:2] %>%
	# 						data.frame %>%
	# 					  set_colnames(c("wt","mpg"))
	# use geom_text and geom_points
	# http://sape.inf.usi.ch/quick-reference/ggplot2/geom_segment
	# http://docs.ggplot2.org/0.9.3.1/geom_abline.html

	if (object$nr_dim == 3) {
		op <- par(mfrow=c(3,1))
		fontsz <- fontsz + .6
	} else {
		op <- par(mfrow=c(1,1))
	}

	for (i in 1:(object$nr_dim - 1)) {
		for (j in (i + 1):object$nr_dim) {

			plot(c(-lim, lim),type = "n",xlab = "", ylab = "", axes = FALSE, asp = 1,
			     yaxt = "n", xaxt = "n", ylim = c(-lim, lim), xlim = c(-lim,lim))
			title(paste("Dimension", i, "vs Dimension", j), cex.main = fontsz)
			abline(v=0, h=0)

			object$brand

			if ("brand" %in% plots) {
				points(std_scores[, i], std_scores[, j], pch = 16, cex = .6)
				wordcloud::textplot(std_scores[, i], std_scores[, j] + (.04 * lim),
				                    object$brands, cex = fontsz, new = FALSE)
			}

			if ("attr" %in% plots) {
				wordcloud::textplot(std_m[, i] * lab_buf, std_m[ ,j] * lab_buf,
				                    object$attr, cex = fontsz,
				                    col = "darkblue", new = FALSE)
				## add arrows
				for (k in object$attr)
					arrows(0, 0, x1 = std_m[k, i], y1 = std_m[k, j], lty = "dashed",
					       length = .05)
			}

			if ("pref" %in% plots) {
				if (nrow(std_pc) > 1) {
					## textplot needs at least two coordinates
					wordcloud::textplot(std_pc[ ,i] * lab_buf, std_pc[ ,j] * lab_buf,
					                    object$pref, cex = fontsz,
					                    col = "darkred", new = FALSE)
				} else {
					text(std_pc[ ,i] * lab_buf, std_pc[ ,j] * lab_buf, object$pref,
					     cex = fontsz, col = "darkred")
				}
				for (l in object$pref) {
					arrows(0, 0, x1 = std_pc[l, i], y1 = std_pc[l, j], lty = "dashed",
					       col = "red", length=.05)
				}
			}
		}
	}

	par(op)
}
