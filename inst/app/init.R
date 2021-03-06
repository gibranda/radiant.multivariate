## urls for menu
r_url_list <- getOption("radiant.url.list")
r_url_list[["(Dis)similarity"]] <-
  list("tabs_mds" = list("Summary" = "multivariate/mds/", "Plot" = "multivariate/mds/plot/"))
r_url_list[["Attributes"]] <-
  list("tabs_pmap" = list("Summary" = "multivariate/pmap/", "Plot" = "multivariate/pmap/plot/"))
r_url_list[["Hierarchical"]] <-
  list("tabs_hclus" = list("Summary" = "multivariate/hclus/", "Plot" = "multivariate/hclus/plot/"))
r_url_list[["K-clustering"]] <-
  list("tabs_kclus" = list("Summary" = "multivariate/kclus/", "Plot" = "multivariate/kclus/plot/"))
r_url_list[["Conjoint"]] <-
  list("tabs_conjoint" = list("Summary" = "multivariate/conjoint/",
                              "Predict" = "multivariate/predict/",
                              "Plot" = "multivariate/plot/"))
options(radiant.url.list = r_url_list); rm(r_url_list)

## design menu
options(radiant.multivariate_ui =
	tagList(
	  navbarMenu("Multivariate",
      tags$head(
        tags$script(src = "www_multivariate/js/run_return.js")
      ),
	    "Maps",
	    tabPanel("(Dis)similarity", uiOutput("mds")),
      tabPanel("Attributes", uiOutput("pmap")),
	    "----", "Factor",
      tabPanel("Pre-factor", uiOutput("pre_factor")),
      tabPanel("Factor", uiOutput("full_factor")),
	    "----", "Cluster",
    	tabPanel("Hierarchical", uiOutput("hclus")),
    	tabPanel("K-clustering", uiOutput("kclus")),
	    "----", "Conjoint",
	    tabPanel("Conjoint", uiOutput("conjoint"))
    )
  )
)
