args = commandArgs(trailingOnly=TRUE)

# test if there is at least two arguments: if not, return an error
if (length(args)<2) {
  stop("At least two arguments must be supplied ('name' (text) and 'numer' (integer) )", call.=FALSE)
}

name      <- args[1]                # read first argument as string
number    <- as.integer( args[2] )  # read second argument as integer

print(paste("Processing with name:'", name, "' and number:'", number,"'", sep = ''))
