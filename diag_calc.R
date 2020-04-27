library("shiny")
library("neatStats")
library("MASS")
library("ggpubr")
library("pwr")
library("data.table")
library("Exact")

theme_set(theme_pubr())
normal_perfect = function(n, mean = 0, sd = 1) {
    stats::qnorm(seq(1 / n, 1 - 1 / n, length.out = n), mean, sd)
}

### --- Accuracy vs. Effect

col_names = c(
    "mean_1",
    "mean_2",
    "d_1",
    "d_2",
    "AUC_1",
    "AUC_2",
    "AUC_diff",
    "accuracy_1",
    "accuracy_2",
    "accuracy_diffs",
    "d_between"
)
results_table = data.frame(matrix(NA , nrow = 0, ncol = length(col_names)))
colnames(results_table) = col_names

d_between_guilties = seq(0.0, 1.2, by = 0.2)
d_case_control = seq(0.5, 2.5, by = 0.5) # c( 0.6, 1.0, 1.4, 1.8, 2.0 )
sd_g = 33.6
sd_i = 23.5
N = 500

for (d_gi0 in d_case_control) {
    for (d_gg0 in d_between_guilties) {
        # dd_gi0 =  mg1 / ( ( (sd_g**2 + sd_i**2)/2  ) **0.5 )
        mg1 = d_gi0 * (((sd_g ** 2 + sd_i ** 2) / 2) ** 0.5)
        # d_gg =  (mg2 - mg1) / ( ( (sd_g**2 + sd_i**2)/2  ) **0.5 )
        mg2 = d_gg0 * (((sd_g ** 2 + sd_g ** 2) / 2) ** 0.5) + mg1
        
        case1 = normal_perfect(n = N,
                                 mean = mg1,
                                 sd = sd_g)
        case2 = normal_perfect(n = N,
                                 mean = mg2,
                                 sd = sd_g)
        control1 = normal_perfect(n = N,
                                   mean = 0,
                                   sd = sd_i)
        control2 = normal_perfect(n = N,
                                   mean = 0,
                                   sd = sd_i)
        
        gi1 = t_neat(
            case1,
            control1,
            auc_added = T,
            bf_added = F,
            hush = T
        )
        gi2 = t_neat(
            case2,
            control2,
            auc_added = T,
            bf_added = F,
            hush = T
        )
        
        d_gi1 = gi1$stats["d"]
        d_gi2 = gi2$stats["d"]
        auc1 = gi1$stats["auc"]
        auc2 = gi2$stats["auc"]
        acc1 = gi1$stats["accuracy"]
        acc2 = gi2$stats["accuracy"]
        auc_diff = auc2 - auc1
        acc_diff = acc2 - acc1
        
        d_gg = t_neat(case2,
                      case1,
                      bf_added = F,
                      hush = T)$stats["d"]
        
        results_table[nrow(results_table) + 1, ] = c(mg1,
                                                     mg2,
                                                     d_gi1,
                                                     d_gi2,
                                                     auc1,
                                                     auc2,
                                                     auc_diff,
                                                     acc1,
                                                     acc2,
                                                     acc_diff,
                                                     d_gg)
    }
}


ggplot(data = results_table, aes(
    x = d_between,
    group = accuracy_1,
    color = as.factor(accuracy_1)
)) +
    geom_hline(
        yintercept = seq(0.5, 1.0, by = 0.05),
        colour = "#e6e6e6",
        size = 0.5
    ) +
    geom_line(size = 0.7, aes(y = accuracy_2), linetype = "dashed") +
    geom_line(size = 0.7,
              aes(y = accuracy_diffs - 0.1 + round(min(
                  results_table$accuracy_1
              ), 1)),
              linetype = "solid") +
    scale_color_grey(
        start = 0.7,
        end = 0.0,
        name = "d: case 1 vs. control",
        label = ro(levels(as.factor(results_table$d_1)), 1)
    ) +
    scale_y_continuous(
        breaks = round(seq(0.6, 1.0, by = 0.05), 2),
        sec.axis = sec_axis(
            ~ . + 0.1 - round(min(results_table$accuracy_1), 1),
            name = "Accuracy gain (solid lines)\n",
            breaks = round(seq(
                min(results_table$accuracy_diffs),
                max(results_table$accuracy_diffs),
                by = 0.05
            ), 2)
        )
    ) +
    theme_bw() +
    theme(
        text = element_text(family = "serif"),
        legend.position = "right",
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = "#e6e6e6", size = 0.5)
    ) +
    xlab("\nd: case 1 vs. case 2") + ylab("Accuracy: case 2 vs. control (dashed lines)\n")


#+ facet_wrap(~ Place, ncol = 3)

#roc_neat( gi1$roc_obj, gi2$roc_obj )
