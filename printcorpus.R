printcorpus = function(corpus, lower=1, upper=2)
{
        #print the corpus
        for(i in lower:upper)
        {
        cat(paste("[[", i, "]] ", sep=""))
        writeLines(strwrap(corpus[[i]], width=73))
        cat("\n")
        }
}