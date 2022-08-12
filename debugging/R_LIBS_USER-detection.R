cat("the availiable R libraries are ",
    .libPaths(),
    sep = "\n")


cat("\nthe R_LIBS_USER environment variable when running \n
    non-interactively is: \n ", Sys.getenv("R_LIBS_USER"))
