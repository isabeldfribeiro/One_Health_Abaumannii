#Importing libraries
library(openxlsx)
library(rstatix)

#Calling table
arg <- read.csv("/home/isabel.ribeiro/LACTAS-HELISSON-01/pibic/testes_estatisticos/input_args.csv")

#Number of genomes per group
total <- c(Environment=209,Animal=83,Hospital=118,Human=684)

#Separate only genes
genes_df <- arg[, -1]

#Store results
result_fisher <- data.frame()

#Counter of comparisons performed
comparison_counter <- 0

#Humans vs. Other Groups
comparisons <- list(c("Human", "Environment"),c("Human", "Animal"),
                    c("Human", "Hospital"))

#Loop by gene
for (gene in names(genes_df)) {

  #Gene presence by group
  presence <- setNames(arg[[gene]], arg$Group)
  
  #Gene absence by group
  absence <- total[names(presence)] - presence
  
  #Complete presence/absence table
  count_table <- rbind(presence, absence)
  rownames(count_table) <- c("Presence", "Absence")
  colnames(count_table) <- names(presence)
  
  #Comparisons: Humans vs. Other Groups
  for (comp in comparisons) {
    group1 <- comp[1]
    group2 <- comp[2]
    
    pres1 <- presence[group1]
    pres2 <- presence[group2]
    aus1  <- absence[group1]
    aus2  <- absence[group2]
    
    #Condition 1: one or both groups do not have any genome with the gene
    without_presence <- (pres1 == 0) || (pres2 == 0)
    
    #Condition 2: gene present in 100% of the genomes of one or both groups
    present_in_both <- (aus1 == 0) || (aus2 == 0)
    
    #If any of the conditions is true, skip this comparison
    if (without_presence || present_in_both) {
      next
    }
    
    #Contingency table
    tab <- count_table[, c(group2, group1)]
    
    #Fisher
    ft <- fisher.test(tab)
    
    #Save result
    result_fisher <- rbind(
      result_fisher,
      data.frame(
        Gene = gene,
        Group1 = group1,
        Group2 = group2,
        Odds_Ratio = unname(ft$estimate),
        IC95_inf = ft$conf.int[1],
        IC95_sup = ft$conf.int[2],
        P_value = ft$p.value
      )
    )
    
    #Accounts for the comparison performed
    comparison_counter <- comparison_counter + 1
  }
}

#FDR Correction
result_fisher$P_adj <- p.adjust(result_fisher$P_value, method = "fdr")

#Message with the total number of comparisons performed
cat("Total comparisons performed:", comparison_counter, "\n")

#Saving result file
write.csv2(result_fisher,
  "/home/isabel.ribeiro/LACTAS-HELISSON-01/pibic/testes_estatisticos/output_artigo_rtp1_args.csv",
  row.names = FALSE)





