# helper for saving figures with GNU Make

#' Export a **ggplot2** object as a pdf and a png
#'
#'Also saves in `./presentations/presentation-figs` for convenient use with **xaringan** HTML slide shows
#'
#' @param plot a **ggplot2** object
#' @param pdf_path path to which plot should be saved; if `NULL`, will call `commandArgs(trailingOnly = TRUE)[[1]]` to accept command line argument
#'
#' @return Silently writes files to disk and prints message
save_fig <- function(plot, pdf_path = NULL){
  
  if(!interactive()){
    
    library(rlang)
    
    pdf_path <- pdf_path %||% commandArgs(trailingOnly = TRUE)[[1]]
    png_path <- stringr::str_replace_all(pdf_path, "pdf", "png")
    presentation_figs_png_path <- here::here(
      "presentations", "presentation-figs", basename(png_path)
    )
    
    
    all_output_file_paths <- c(pdf_path, png_path, presentation_figs_png_path)
    
    cat("Building figures: \n")
    cat(all_output_file_paths, sep = "\n")
    cat("- - - - - - - - - - - - - - - - - - - - - - - - -", "\n\n")
    
    purrr::walk(
      .x = c(pdf_path, png_path, presentation_figs_png_path),
      .f = ggplot2::ggsave,
      plot = plot,
      height = 9*0.4,
      width = 16*0.4
      # height = 9*2/3,
      # width = 16*2/3
    )
  } else{
    print(plot)
    warning("Plot will not be saved during an interactive R session. Use Make to write plots to disk.", call. = F)
  }
  
}



#' Use for debugging a single latex tabke without needing to re-compile entire document
#'
#' @param x a kable object
#' @param file path to write to, defaults to `./debuggging/[table name].tex`
#'
#' @return writes file to disk 
#'
save_dummy_latex <- function(x, name = NULL, file = NULL){
  
  library(rlang)
  
  if(!is.null(name)){
    auto_file <- fs::path(
      "debugging", paste0(name, ".tex")
    )
  }
  
  file_to_write <- file %||% auto_file
  
  
  writeLines(
    text = c(
      "\\documentclass{article}",
      "\\usepackage{booktabs}",
      "\\usepackage{longtable}",
      "\\usepackage{array}",
      "\\usepackage{multirow}",
      "\\usepackage{wrapfig}",
      "\\usepackage{float}",
      "\\usepackage{colortbl}",
      "\\usepackage{pdflscape}",
      "\\usepackage{tabu}",
      "\\usepackage{threeparttable}",
      "\\usepackage{threeparttablex}",
      "\\usepackage[normalem]{ulem}",
      "\\usepackage[utf8]{inputenc}",
      "\\usepackage{makecell}",
      "\\usepackage{xcolor}",
      "\\n",
      "\\begin{document}",
      x,
      "\\end{docmument}"),
    con = file_to_write)
  
}



#' Title
#'
#' @param mod model object
#' @param type type I, II, or III sum of  squares to pass to `car::Anova()`. Defaults to Type III.
#' @param terms Character vector of the model terms
#' @param col_names Character vector of column names. Defaults to `c("Term", "Sum Sq.", "Deg. of Fr.",  "F-Statistic", "P-value")`
#' @param ... other arguments passed to `kableExtra::kbl()``
#'
#' @return formatted kable object
#'
format_anova_table <- function(
    mod, 
    type,terms, 
    col_names= c("Term", "Sum Sq.", "Deg. of Fr.",  "F-Statistic", "P-value"),
    ...
    ){
  
  tidy_anova_table <- car::Anova(mod = model_object, type = 3) %>% 
    broom::tidy(model_object)
  
  formatted_latex_kable <- tidy_anova_table %>% 
    dplyr::mutate(
      term = terms,
      statistic = format(statistic, digits = 1, scientific = FALSE),
      sumsq = format(sumsq, 
                     digits = 2, 
                     drop0trailing = TRUE,
                     scientific = FALSE),
      p.value = dplyr::if_else(
        p.value < 0.001,
        "<0.001",
        format(
          p.value, 
          digits = 3, 
          drop0trailing = FALSE))) %>% 
    dplyr::rename(
      Term = term, 
      `Sum of sq.` = sumsq,
      `Deg. of Fr.` = df,
      `F-statistic` = statistic, 
      `p-value` = p.value) %>% 
    kableExtra::kbl(
      format = 'latex',
      escape = FALSE,
      booktabs = TRUE,
      col.names = col_names,
      ...) %>%
    row_spec(row = c(0, 3, 4), bold = TRUE) %>%
    kableExtra::kable_styling(latex_options = 'basic')
  
}
