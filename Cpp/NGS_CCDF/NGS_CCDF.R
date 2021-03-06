##################################################################
# FILENAME   : NGS_CCDF.R
# AUTHOR     : Brian Denton <dentonb@mskcc.org>
# DATE       : 08/18/2011
# DESCRIPTION: Plots the complementary CDF for depth-of-coverage
#              from next generation sequencing data. A seperate
#              CCDF is plotted for reads with base call quality
#              score Q>=10, Q>=20, Q>=30, and Q>=40.
##################################################################

# Import results from NGS_CCDF application
QUAL_counts <- read.csv( file = "example.csv", header = FALSE )
names( QUAL_counts) <- c("CHROM","POS","Q10","Q20","Q30","Q40","InExon")

# Get complementary CCDF
get_CCDF <- function( data, xmax ){
  
  x <- 1:xmax
  CCDF <- rep( 0, xmax )
  
  # Get frequency table for distribution of depth-of-coverage
  freq <- table( data )
  
  for( i in 1:xmax ){
  
	# Find the cumulative sum of frequency counts for
	# each depth-of-coverage value from 1 to i, where i = 1...xmax
	cumulativeSum <- sum( freq[as.integer(names(freq)) <= i] )
	if( is.na( cumulativeSum ) )
		cumulativeSum <- 0
	
	# Get the complementary CDF
    CCDF[i] <- 1 - cumulativeSum/length(data)
  }

  return( list( x = x, CCDF = CCDF ) )
}

maxDepthOfCoverage <- 200

Q10_CCDF <- get_CCDF( QUAL_counts$Q10, xmax = maxDepthOfCoverage  )
Q20_CCDF <- get_CCDF( QUAL_counts$Q20, xmax = maxDepthOfCoverage  )
Q30_CCDF <- get_CCDF( QUAL_counts$Q30, xmax = maxDepthOfCoverage  )
Q40_CCDF <- get_CCDF( QUAL_counts$Q40, xmax = maxDepthOfCoverage  )

Q10_CCDF.exome <- get_CCDF( QUAL_counts$Q10[QUAL_counts$InExon=="true"], xmax = maxDepthOfCoverage )
Q20_CCDF.exome <- get_CCDF( QUAL_counts$Q20[QUAL_counts$InExon=="true"], xmax = maxDepthOfCoverage )
Q30_CCDF.exome <- get_CCDF( QUAL_counts$Q30[QUAL_counts$InExon=="true"], xmax = maxDepthOfCoverage )
Q40_CCDF.exome <- get_CCDF( QUAL_counts$Q40[QUAL_counts$InExon=="true"], xmax = maxDepthOfCoverage )

pdf( file = "Example Complementary CDF.pdf", width = 11, height = 8.5 )

plot( x = Q10_CCDF.exome$x, y = Q10_CCDF.exome$CCDF, col = "green", type = "l", lty = 1, lwd = 2,
      xlim = c(1,maxDepthOfCoverage), ylim = c(0,1),
      main = "Example Complementary CDF",
      ylab = "Proportion of Genomic Positions",
      xlab = "Minimum Number of Reads Covering a Genomic Position" )
lines( x = Q20_CCDF.exome$x, y = Q20_CCDF.exome$CCDF, col = "red", lwd = 2 )
lines( x = Q30_CCDF.exome$x, y = Q30_CCDF.exome$CCDF, col = "blue", lwd = 2 )
lines( x = Q40_CCDF.exome$x, y = Q40_CCDF.exome$CCDF, col = "magenta", lwd = 2 )

lines( x = Q10_CCDF$x, y = Q10_CCDF$CCDF, col = "green", lwd = 2, lty = 9 )
lines( x = Q20_CCDF$x, y = Q20_CCDF$CCDF, col = "red", lwd = 2, lty = 9 )
lines( x = Q30_CCDF$x, y = Q30_CCDF$CCDF, col = "blue", lwd = 2,lty = 9 )
lines( x = Q40_CCDF$x, y = Q40_CCDF$CCDF, col = "magenta", lwd = 2, lty = 9 )

legend( "topright", title = "Phred Quality Score",
        legend = c( "Q10 or greater", "Q20 or greater",
        "Q30 or greater", "Q40 or greater","--------------",
		"Exome Only", "All Locations" ),
        lty = c(rep(1,4,),1,1,9), lwd = 2,
		col = c("green","red","blue","magenta","white", "black", "black") )

dev.off()

# END OF FILE
